---

# Tableau Server SSL Certificate Monitoring Script

This PowerShell script is designed to monitor the SSL certificates of specified Tableau Server URLs and send email alerts if the certificates are close to expiration. The script checks the certificate expiration dates and triggers an email notification if a certificate is due to expire within 90 days.

## Prerequisites

Before using this script, ensure that you have the following:

- **PowerShell**: The script is written in PowerShell, so you need to have PowerShell installed on the machine where the script will be executed.
- **SMTP Server Details**: You will need to provide your SMTP server details to send email notifications.
- **Access to Tableau Server URLs**: The script must have access to the specified Tableau Server URLs to retrieve SSL certificate information.

## How to Use the Script

### 1. Clone the Repository

First, clone the repository containing the script to your local machine:

```bash
git clone https://github.com/yourusername/your-repo-name.git
cd your-repo-name
```

### 2. Open the Script

Open the `CertificateMonitoring.ps1` script in your preferred text editor or PowerShell IDE.

### 3. Configure the Script

Before running the script, you need to configure the following variables within the script:

- **$Tableau_Server_URLs**: Update this array with the URLs of the Tableau servers you want to monitor. Example:
  ```powershell
  $Tableau_Server_URLs = @("https://prod.abc.com/", "https://dev.prod.com/")
  ```

- **$smtp**: Specify your SMTP server address. Example:
  ```powershell
  $smtp = "smtp.yourdomain.com"
  ```

- **$from**: Define the email address from which the alerts will be sent. Example:
  ```powershell
  $from = "alerts@yourdomain.com"
  ```

- **$to**: Define the recipient email addresses for the alerts. Use commas to separate multiple addresses. Example:
  ```powershell
  $to = "admin1@yourdomain.com,admin2@yourdomain.com"
  ```

- **$cc**: (Optional) Specify any CC recipients. Example:
  ```powershell
  $cc = "manager@yourdomain.com"
  ```

- **$team**: Customize the team name to be displayed in the alert email. Example:
  ```powershell
  $team = "Tableau Admin Team"
  ```

### 4. Manually run the Script or Schedule it using Windows Task Scheduler.

- Once you've configured the script, you can run it using PowerShell:

```powershell
.\CertificateMonitoring.ps1
```

**OR**

- To automate the script execution, you can schedule it using Windows Task Scheduler.
    - Search for "Task Scheduler" in the Windows Start menu and open it.
    - Create a New Task:
    - Click on "Create Task..." from the right-hand Actions pane.
    - Name: Give the task a meaningful name, e.g., "Tableau SSL Certificate Monitoring."
    - Security Options: Choose "Run whether user is logged on or not" and check "Run with highest privileges.
    - Triggers Tab: Click "New..." to create a new trigger.
    - Begin the task: Choose "On a schedule."
    - Settings: Set the desired schedule (e.g., daily, weekly).
    - Advanced settings: Configure any additional settings like repeat intervals or delays if necessary.
    - Actions Tab: Click "New..." to create a new action.
      - Action: Select "Start a Program."
      - Program/script: Enter powershell.exe.
      - Add arguments: Enter the path to your script:
          Code: ExecutionPolicy Bypass -File "C:\path\to\CertificateMonitoring.ps1"
      - Conditions Tab: Configure any conditions like only running on AC power or network availability if required.
      - Settings Tab: Configure additional settings such as allowing the task to run on demand or stopping it if it runs for too long.
      - Save the Task:
      - Click "OK" to save the task. If prompted, enter your Windows credentials.

### 5. Check Email Alerts

If any of the certificates are due to expire within 90 days, the script will send an email alert to the specified recipients with the following details:
- Tableau Server URL
- Certificate Expiration Date
- Days Left Until Expiration

### Script Workflow

1. **SSL Certificate Retrieval**: The script iterates over each Tableau Server URL specified in the `$Tableau_Server_URLs` array and retrieves the SSL certificate details.

2. **Expiration Check**: It calculates the number of days left before each certificate expires.

3. **Email Alert Trigger**: If a certificate is due to expire within 90 days, the script sends an email alert to the configured recipients.

## Troubleshooting

- **No Email Received**: Ensure that the SMTP server details are correct and that the script has permission to send emails.
- **Certificate Not Found**: Verify that the specified Tableau Server URLs are correct and accessible.

## Script Overview

Here is a brief overview of key parts of the script:

```powershell
$Tableau_Server_URLs = @("https://prod.abc.com/", "https://dev.prod.com/") # List of Tableau Server URLs to monitor
$smtp = ""  # SMTP server for sending emails
$from = ""  # From email address
$to = ""    # To email addresses
$cc = ""    # CC email addresses
$subject = ""  # Email subject line

$team = "Tableau Admin Team"  # Name of the team sending the alert
```

The script then loops through each URL, retrieves the certificate details, calculates the days remaining before expiration, and triggers an email alert if necessary.

```powershell
ForEach ($URL in $Tableau_Server_URLs) {
    # Set security protocols and bypass SSL certificate validation
    [System.Net.ServicePointManager]::SecurityProtocol = @("Tls12","Tls11","Tls","Ssl3")
	[Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

    # Create a web request to retrieve the certificate
	$req = [Net.HttpWebRequest]::Create($URL)
	$req.GetResponse() | Out-Null

    # Create a custom object with the certificate details
	$output = [PSCustomObject]@{
	   URL = $URL
	   'Cert Start Date' = $req.ServicePoint.Certificate.GetEffectiveDateString()
	   'Cert End Date' = $req.ServicePoint.Certificate.GetExpirationDateString()
	}

    # Calculate the number of days left before expiration
	$today = (GET-DATE)
	$new_date_object = New-TimeSpan -Start $today -End $output.'Cert End Date'
	$days_left_before_expiration = $new_date_object.Days

    # If the certificate is expiring within 90 days, send an alert email
	if ($days_left_before_expiration -le 90) {
		# Email body and sending logic
	    Send-MailMessage -SmtpServer $smtp -From $from -To $to -Cc $cc -Subject $subject -Body $body -BodyAsHtml
	}
}
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Contributions

Contributions are welcome! Please fork this repository and submit a pull request with your changes.

---

Make sure to update the URLs, SMTP details, and any other specific information in the script to match your environment.
