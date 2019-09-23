#==================| Satnaam Waheguru Ji |===============================  
#             
#            Author  :  Aman Dhally   
#            E-Mail  :  amandhally@gmail.com   
#            website :  www.amandhally.net   
#            twitter :   @AmanDhally   
#            blog    : http://newdelhipowershellusergroup.blogspot.in/  
#            facebook: http://www.facebook.com/groups/254997707860848/   
#            Linkedin: http://www.linkedin.com/profile/view?id=23651495   
#   
#            Creation Date    : 09-12-2013
#            File    :          
#            Purpose :   	
#            Version : 1   
#           
#  
#            My Pet Spider :          /^(o.o)^\    
#========================================================================  

##Note ====> Before running this script, make sure you have RSAT tool installed.

#Immport Module Active Directory
Import-Module ActiveDirectory -ErrorAction 'Stop'

# Days after password expire, Change the Day's as per your Default Paaaword Expiration group Policy
[int]$totalDays = 90

# TOday
$todayDate =  Get-Date


#Password expiredCollection
$passwordExpiredCollection = @()

# Email Option and Value 

$smtp = "Your-ExchnageServer"
$subject = "Chnage your Password Soon"

# filtering user from AD
$adUsers = Get-ADUser -Filter {(ObjectClass -eq "user") -and (EmailAddress -ne "$null")  -and (PasswordNeverExpires -eq "False") -and (Enabled -eq $true) } -Properties PasswordNeverExpires,PasswordLastSet,PasswordExpired,LockedOut,EmailAddress

foreach ( $aduser in $adUsers)

        {
    
           if ($aduser.PasswordLastSet -ne $null) { 

            
            [datetime]$lastPasswordSet = $aduser.PasswordLastSet
            $timeSpan = New-TimeSpan  (Get-date -Date $lastPasswordSet.Date )
            $expirationTime = $totalDays - $timeSpan.Days
           
            }


            Switch ($expirationTime)
            {


            7  {
                    $dateAfter7Days = (Get-Date).AddDays(7).ToShortDateString().ToString()
               		$passwordExpiring7Days  += $aduser.Name + ";" + $aduser.EmailAddress + ";" + $expirationTime + ";" + $dateAfter7Days
            
                }
			

            
            
            }

            #switch stop


            # If User password is expired.

            if ( $aduser.PasswordExpired -eq $true ) 
                
                {
            
                    $passwordExpiredCollection += $aduser.Name + ";" + $aduser.EmailAddress + ";" + $expirationTime + "`n"
            
                }



        
        }



# Splitting


if ( $passwordExpiring7Days -ne $null ) {

        foreach ( $7name in $passwordExpiring7Days  ) {


            $7userCollection = $7name -split ";"
            $7userName = $7userCollection[0]
            $7userEmail = $7userCollection[1]
            $7pass = $7userCollection[2]
            $7day = $7userCollection[3]


            Write-Host "Dear $7userName, your emailid is $7userEmail , you password is expiring in $7pass days." -ForegroundColor Green

            $body = "Dear $7userName, <br>"
            
            $body += "<br>"
            $body += "Your password is due to expire in  <b><font color=red> $7pass days</b></font>. Please ensure you have changed it before then.<br>"
            $body += "<br>"

            $body += "Regards<br>"
            $body += "I.T. Team<br>"
            $body += "<br>"
            $body += "<br>"
            $body += "<b>How to change your password:</b><br>"
            $body += "    1. Press CTRL+ALT+DELETE, and then click Change a password.<br>"
            $body += "    2. Type your old password, type your new password, type your new password again to confirm it, and then press ENTER.<br>"

			# if you want to send an email, please un-comment the below line.
            #Send-MailMessage -to $7userEmail -From "YourID@YourDomain.com"  -SmtpServer $smtp -Body $body -BodyAsHtml -Subject $subject  -Priority high -Encoding UTF8
			
			
		
            }

}


# sending list of password expired.
 
 $body = ""
 $body += $passwordExpiredCollection

 Write-Warning "Users those passwords are already expired ========"	
 Write-Host $passwordExpiredCollection	

# if you want to send an email, please un-comment the below line.
 #Send-MailMessage -to "YOURID@YourDomain.com" -SmtpServer $smtp -From "SCTIPTER@YourDomain.com" -Body $body -Subject "Password those are already expired"

