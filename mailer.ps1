Function Mailer ($emailTo)
<# This is a simple function that that sends a message.
The variables defined below can be passed as parameters by taking them out 
and putting then in the parentheseis above.

i.e. "Function Mailer ($subject)"

#>

{
   $message = @"
                                
Some stuff that is meaningful 

Thank you,
IT Department
Cotendo Corporation
it@cotendo.com
"@       

$emailFrom = "noreply@<yourdomain>.com"
$subject="<Your Text Here>"
$smtpserver="<your mailhost>.<yourdomain>.com"
$smtp=new-object Net.Mail.SmtpClient($smtpServer)
$smtp.Send($emailFrom, $emailTo, $subject, $message)
}
