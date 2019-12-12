# Works on VM in MetraTech domain

# Email SMTP server
$SMTPServer = "10.200.23.30"
$EmailFrom = "ENTDC1Backups@ericsson.com" 
$EmailTo = "brian.gillespie@ericsson.com"
$EmailSubject = "test send email"
$MesssagyBody = "Test message body"

$Message = New-Object System.Net.Mail.MailMessage $EmailFrom, $EmailTo
$Message.Subject = $EmailSubject
$Message.IsBodyHTML = $True
$message.Body = $MesssagyBody 
$SMTP = New-Object Net.Mail.SmtpClient($SMTPServer)
$SMTP.Send($Message)

