$from= "laura.campo@campohenriquezlab.onmicrosoft.com"
$to= "fabian.campo@campohenriquezlab.onmicrosoft.com"
$subject= "mensaje de prueba"
$body= "Prueba enviando desde un SMTP Relay"
$smtpserver= "campohenriquezlab.mail.protection.outlook.com"
$SMTPPort= "25"
Send-MailMessage -From $from -To $to -Subject $subject -Body $body -SmtpServer $smtpserver -Port $SMTPPort