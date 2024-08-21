############################### This Script Monitors the Server SSL Certificates and Triggers the Expiration Email Alerts ###############################

# Name:       CertificateMonitoring.ps1
# Written by: Swapnil Yavalkar
# Date:       2-May-2022
# Author:     Swapnil Yavalkar

# Modification History:     
   
#      Date         Name                 Description
# ------------ -------------------- ----------------------
# 2-May-202  Swapnil Yavalkar          Created

$Server_URLs = @("https://prod.abc.com/", "https://dev.prod.com/")
$number_of_days_till_expiration = 90
$smtp = ""
$from = ""
$to = ""
$cc = ""
$subject = ""

$team = "Admin Team"

ForEach ($URL in $Server_URLs){
    [System.Net.ServicePointManager]::SecurityProtocol = @("Tls12","Tls11","Tls","Ssl3")
	[Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
	$req = [Net.HttpWebRequest]::Create($URL)
	$req.GetResponse() | Out-Null

	$output = [PSCustomObject]@{
	   URL = $URL
	   'Cert Start Date' = $req.ServicePoint.Certificate.GetEffectiveDateString()
	   'Cert End Date' = $req.ServicePoint.Certificate.GetExpirationDateString()
	}

	############ Send Alert Emails ############

	$today = (GET-DATE)
	$new_date_object = New-TimeSpan -Start $today -End $output.'Cert End Date'

	$days_left_before_expiration = $new_date_object.Days

	if ($days_left_before_expiration -le $number_of_days_till_expiration){
		
		$temp1 = $req.ServicePoint.Certificate.Subject.Split(",")
		$temp2 = $temp1[0] # Getting only CN value from Subject.
		$temp3 = $temp2.Split("=")
		$cn_name_server = $temp3[1].ToUpper() # Getting only Server FQDN.
		$cert_exp_date = $output.'Cert End Date'
        $subject = "CERTIFICATE EXPIRATION ALERT: $cn_name_server"
        $body = @'
                 <body>
        <p>Hi Team,
            <br><br>Below Certificate is going to expire soon, please find below details for the same and renew it at the earliest.
            <br>
                <table border="1" style="width:100%">
                  <tr>
                    <th style="color:white; background-color:#0f12ba">Server</th>
                    <th style="color:white; background-color:#0f12ba">Certificate Expiration Date</th> 
                    <th style="color:white; background-color:#0f12ba">Days Left Until Expiration</th>
                  </tr>
                  <tr>
                    <td style="text-align:center">{0}</td>
                    <td style="text-align:center">{1}</td> 
                    <td style="text-align:center">{2}</td>
                  </tr>
                </table>
                <br>Regards,<br>{3}
         </body>
'@ -f $URL, $cert_exp_date, $days_left_before_expiration, $team
	    Send-MailMessage -SmtpServer $smtp -From $from -To $to -Cc $cc -Subject $subject -Body $body -BodyAsHtml
		
	}

}