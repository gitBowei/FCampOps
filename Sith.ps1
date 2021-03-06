' Script:    Master_Audit_AD_Account_Management - 2008 v4 S1S2.vbs (Version 4 Section1 and Section2 combi script) 
' Purpose:  Parse a DC's security event log and generate account management events, log and e-mail for past 24hs 
' Author:   Paperclips (The Dark Lord) 
' Email:    magiconion_M@hotmail.com 
' Date:     Feb 2011 
' Comments: Make sure relevant auditing is already set up in AD before using this script. Auditing event logs must be set up for relevant ID's to be audited 
' Notes:     
'            - 
'================================================================SECTION 1 AD Auditing MASTER REPORT GEN============================================================== 
Dim objFSO, objFolder, objFile, objWMI, objItem, objEmail 
Dim strComputer, strFileName, strFileOpen, strFolder, strPath 
Dim intEvent, colLoggedEvents, datenow, EventDate 
Dim count1, count2, count3, count4, count5, count6, count7, count8, count9, count10 
Dim count11, count12, count13, count14, count15, count16, count17, count18, count19, count20 
Dim count21, count22, count23, count24, count25 
 
count1 = 0 
count2 = 0 
count3 = 0 
count4 = 0 
count5 = 0 
count6 = 0 
count7 = 0 
count8 = 0 
count9 = 0 
count10 = 0 
count11 = 0 
count12 = 0 
count13 = 0 
count14 = 0 
count15 = 0 
count16 = 0 
count17 = 0 
count18 = 0 
count19 = 0 
count20 = 0 
count21 = 0 
count22 = 0 
count23 = 0 
count24 = 0 
count25 = 0 
 
On error resume next 
' ---------------------------------------------------Set the folder and file name------------------------------------------------------------------- 
 
strComputer = "." 
strFileName = "\AD_Account_Management_Events.txt" 
strFolder = "c:\audit_AD" 
strPath = strFolder & strFileName 
'-----------------------------------------------------Set numbers/Date------------------------------------------------------------------------------ 
 
DateNow = Now() 
' ----------------------------------------------------Create the File System Object----------------------------------------------------------------- 
 
Set objFSO = CreateObject("Scripting.FileSystemObject") 
'-----------------------------------------------------Check that the strFolder folder exists-------------------------------------------------------- 
 
If objFSO.FolderExists(strFolder) Then 
Set objFolder = objFSO.GetFolder(strFolder) 
Else 
Set objFolder = objFSO.CreateFolder(strFolder) 
End If 
 
If objFSO.FileExists(strFolder & strFileName) Then 
Set objFolder = objFSO.GetFolder(strFolder) 
Else 
Set objFile = objFSO.CreateTextFile(strFolder & strFileName) 
End If  
' ----------------------------------------------------CLEANUP -------------------------------------------------------------------------------------- 
 
set objFile = nothing 
set objFolder = nothing 
' -----------------------------------------------------Write the information to the file------------------------------------------------------------ 
 
Set strFileOpen = objFSO.CreateTextFile(strPath, True) 
 
' -----------------------------------------------------Log Header----------------------------------------------------------------------------------- 
 
strFileOpen.WriteLine("Script started at " & Datenow & " on Your DC") 
strFileOpen.WriteLine("===================================================") 
strFileOpen.WriteLine("") 
strFileOpen.WriteLine("Created by Paperclips") 
strFileOpen.WriteLine("......................") 
strFileOpen.WriteLine("") 
strFileOpen.WriteLine("IMPORTANT NOTES:") 
strFileOpen.WriteLine("----------------") 
strFileOpen.WriteLine("Sections 21,22,23,24 all related to Directory Service Objects. These 4 categories are repetative of other sections,") 
strFileOpen.WriteLine("meaning that if an object was amended, (For example the permissions changed on a user account in section 5 etc.) the") 
strFileOpen.WriteLine("event will also appear in section 24 with specific details. Thus sections 21,22,23 and 24 will log in depth changes") 
strFileOpen.WriteLine("creations, deletions, move's and permissions. Thus in this example section 5 will only notify that a change has occured") 
strFileOpen.WriteLine("and section 24 will log the exact specific change made.") 
strFileOpen.WriteLine("") 
strFileOpen.WriteLine("Thus when reviewing logs in sections 21,22,23 and 24, look at the line that says Class: to see what object was changed") 
strFileOpen.WriteLine("This will be either, user, computer, group, organisationalunit etc.....") 
strFileOpen.WriteLine("Additionally if the LDAP Display Name: variable is NTSecurityDescriptor and the Class: is OrganisationalUnit this means") 
strFileOpen.WriteLine("that the permission has changed on the OU. Additional Totals have been added for OU's in the summary report with regards") 
strFileOpen.WriteLine("to sections 21, 22, 23 and 24.") 
strFileOpen.WriteLine("") 
strFileOpen.WriteLine("") 
' -----------------------------------------------------WMI Core Section1---------------------------------------------------------------------------- 
  
Set objWMI = GetObject("winmgmts:" _ 
& "{impersonationLevel=impersonate,(Security)}!\\" _  
& strComputer & "\root\cimv2") 
Set colLoggedEvents = objWMI.ExecQuery _ 
("Select * from Win32_NTLogEvent Where Logfile = 'Security' AND EventCode = '1102'" ) 
'------------------------------------------------------Next few sections loops through ID properties------------------------------------------------ 
 
strFileOpen.WriteLine("    =====================================================================") 
strFileOpen.WriteLine("    = The Security Event Log on this Domain Controller was last cleared =") 
strFileOpen.WriteLine("    =====================================================================") 
strFileOpen.WriteLine(" ") 
For Each objItem in colLoggedEvents 
 
    EventDate = GetVBDate(objItem.TimeGenerated) 
     
    'If DateDiff("h",DateNow,EventDate) > -25 Then 
            'If objItem.EventType=4 then 
                'If objItem.EventCode =1102 Then 
                    strFileOpen.WriteLine ("Time of last clear: " & EventDate) 
                    strFileOpen.WriteLine("DC Name: " & objItem.ComputerName)  
                    strFileOpen.WriteLine("Logfile: " & objItem.SourceName)  
                    strFileOpen.WriteLine("Message: " & objItem.Message) 
                    strFileOpen.WriteLine (" ") 
                    strFileOpen.WriteLine (" ") 
                'End If 
            'End If 
    'end if 
Next 
' -----------------------------------------------------WMI Core Section2 ---------------------------------------------------------------------------- 
  
Set objWMI = GetObject("winmgmts:" _ 
& "{impersonationLevel=impersonate,(Security)}!\\" _  
& strComputer & "\root\cimv2") 
Set colLoggedEvents = objWMI.ExecQuery _ 
("Select * from Win32_NTLogEvent Where Logfile = 'Security'" ) 
'1------------------------------------------------------Next few sections loops through ID properties------------------------------------------------ 
 
strFileOpen.WriteLine("===========================================================================================") 
strFileOpen.WriteLine("= 1. User Password Change Attempts by SUBJECT in the past 24hrs (most likely by an admin) =") 
strFileOpen.WriteLine("===========================================================================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
        If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =4724 Then 
                count1 = count1 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine     ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine     ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine     (" ") 
            End If 
    end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 1.)User Password Change Attempts by SUBJECT in the past 24hrs (most likely by an admin) TOTAL = " & Count1) 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine(" ") 
'2--------------------------------------------------------------------------------------------------------------------------------------------------- 
 
strFileOpen.WriteLine("==============================================================================") 
strFileOpen.WriteLine("= 2. User Password Change Attempts by THE USER HIM/HERSELF in the past 24hrs =") 
strFileOpen.WriteLine("==============================================================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
        If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =4723 Then 
                count2 = count2 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
    end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 2.)User Password Change Attempts by THE USER HIM/HERSELF in the past 24hrs TOTAL = " & Count2) 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine(" ") 
'3--------------------------------------------------------------------------------------------------------------------------------------------------- 
 
strFileOpen.WriteLine("==============================================") 
strFileOpen.WriteLine("= 3. User Accounts Created in the past 24hrs =") 
strFileOpen.WriteLine("==============================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
    If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =4720 Then 
                count3 = count3 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
    end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 3.)User Accounts Created in the past 24hrs TOTAL = " & Count3) 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine(" ") 
'4--------------------------------------------------------------------------------------------------------------------------------------------------- 
 
strFileOpen.WriteLine("==============================================") 
strFileOpen.WriteLine("= 4. User Accounts Deleted in the past 24hrs =") 
strFileOpen.WriteLine("==============================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
    If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =4726 Then 
                count4 = count4 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
    end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 4.)User Accounts Deleted in the past 24hrs TOTAL = " & Count4) 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine(" ") 
'5--------------------------------------------------------------------------------------------------------------------------------------------------- 
 
strFileOpen.WriteLine("==============================================") 
strFileOpen.WriteLine("= 5. User Accounts Changed in the past 24hrs =") 
strFileOpen.WriteLine("==============================================") 
strFileOpen.WriteLine("") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
        If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =4738 Then 
                count5 = count5 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Important Note:    To see exactly what changed on the user object refer to events created") 
                strFileOpen.WriteLine    ("---------------    for (Directory Service Changes) later in this log for Class: User") 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
        end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 5.)User Accounts Changed in the past 24hrs TOTAL = " & Count5) 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine(" ") 
'6--------------------------------------------------------------------------------------------------------------------------------------------------- 
 
strFileOpen.WriteLine("=================================================") 
strFileOpen.WriteLine("= 6. User Accounts Locked Out in the past 24hrs =") 
strFileOpen.WriteLine("=================================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
    If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =4740 Then 
                count6 = count6 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ")     
            End If 
    end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 6.)User Accounts Locked Out in the past 24hrs TOTAL = " & Count6) 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine(" ") 
'7--------------------------------------------------------------------------------------------------------------------------------------------------- 
 
strFileOpen.WriteLine("===============================================") 
strFileOpen.WriteLine("= 7. User Accounts Unlocked in the past 24hrs =") 
strFileOpen.WriteLine("===============================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
        If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =4767 Then 
                count7 = count7 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ")     
            End If 
    end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 7.)User Accounts Unlocked in the past 24hrs TOTAL = " & Count7) 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine(" ") 
'8--------------------------------------------------------------------------------------------------------------------------------------------------- 
 
strFileOpen.WriteLine("==================================================") 
strFileOpen.WriteLine("= 8. Computer Accounts Created in the past 24hrs =") 
strFileOpen.WriteLine("==================================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
    If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =4741 Then 
                count8 = count8 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
    end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 8.)Computer Accounts Created in the past 24hrs TOTAL = " & Count8) 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine(" ") 
'9--------------------------------------------------------------------------------------------------------------------------------------------------- 
 
strFileOpen.WriteLine("==================================================") 
strFileOpen.WriteLine("= 9. Computer Accounts Deleted in the past 24hrs =") 
strFileOpen.WriteLine("==================================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
    If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =4743 Then 
                count9 = count9 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
    end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 9.)Computer Accounts Deleted in the past 24hrs TOTAL = " & Count9) 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine(" ") 
'10--------------------------------------------------------------------------------------------------------------------------------------------------- 
 
strFileOpen.WriteLine("===================================================") 
strFileOpen.WriteLine("= 10. Computer Accounts Amended in the past 24hrs =") 
strFileOpen.WriteLine("===================================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
        If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =4742 Then 
                count10 = count10 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Important Note:    To see exactly what changed on the computer object refer to events created") 
                strFileOpen.WriteLine    ("---------------    for (Directory Service Changes) later in this log for Class: Computer") 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
        end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 10.)Computer Accounts Amended in the past 24hrs TOTAL = " & Count10) 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine(" ") 
'11--------------------------------------------------------------------------------------------------------------------------------------------------- 
 
strFileOpen.WriteLine("===========================================================") 
strFileOpen.WriteLine("= 11. User or Computer Objects Disabled in the past 24hrs =") 
strFileOpen.WriteLine("===========================================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
        If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =4725 Then 
                count11 = count11 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
        end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 11.)User or Computer Objects Disabled in the past 24hrs TOTAL = " & Count11) 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine(" ") 
'12--------------------------------------------------------------------------------------------------------------------------------------------------- 
 
strFileOpen.WriteLine("==========================================================") 
strFileOpen.WriteLine("= 12. User or Computer Objects Enabled in the past 24hrs =") 
strFileOpen.WriteLine("==========================================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
        If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =4722 Then 
                count12 = count12 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
        end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 12.)User or Computer Objects Enabled in the past 24hrs TOTAL = " & Count12) 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine(" ") 
'13--------------------------------------------------------------------------------------------------------------------------------------------------- 
 
strFileOpen.WriteLine("=========================================================") 
strFileOpen.WriteLine("= 13.  Users Added to Security Groups in the past 24hrs =") 
strFileOpen.WriteLine("=========================================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
    If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =4728 Then 
                count13 = count13 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
    end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 13.)Users Added to Security Groups in the past 24hrs TOTAL = " & Count13) 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine(" ") 
'14----------------------------------------------------------------------------------------------------------------------------------------------- 
 
strFileOpen.WriteLine("==================================================") 
strFileOpen.WriteLine("= 14.  Security Groups Deleted in the past 24hrs =") 
strFileOpen.WriteLine("==================================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
    If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =4730 Then 
                count14 = count14 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
    end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 14.)Security Groups Deleted in the past 24hrs TOTAL = " & Count14) 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine(" ") 
'15------------------------------------------------------------------------------------------------------------------------------------------------- 
 
strFileOpen.WriteLine("=================================================") 
strFileOpen.WriteLine("= 15. Security Groups Created in the past 24hrs =") 
strFileOpen.WriteLine("=================================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
    If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =4727 Then 
                count15 = count15 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
    end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 15.)Security Groups Created in the past 24hrs TOTAL = " & Count15) 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine(" ") 
'16------------------------------------------------------------------------------------------------------------------------------------------------- 
 
strFileOpen.WriteLine("=========================================================") 
strFileOpen.WriteLine("= 16. Security Groups Amended/Changed in the past 24hrs =") 
strFileOpen.WriteLine("=========================================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
    If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =4737 Then 
                count16 = count16 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Important Note:    To see exactly what changed on the Group object refer to events created") 
                strFileOpen.WriteLine    ("---------------    for (Directory Service Changes) later in this log for Class: Group") 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
    end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 16.)Security Groups Amended/Changed in the past 24hrs TOTAL = " & Count16) 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine(" ") 
'17------------------------------------------------------------------------------------------------------------------------ 
 
strFileOpen.WriteLine("==========================================================") 
strFileOpen.WriteLine("= 17. Mail Distribution Groups Created in the past 24hrs =") 
strFileOpen.WriteLine("==========================================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
    If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =4749 Then 
                count17 = count17 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
    end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 17.)Mail Distribution Groups Created in the past 24hrs TOTAL = " & Count17) 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine(" ") 
'18------------------------------------------------------------------------------------------------------------------------ 
 
strFileOpen.WriteLine("==========================================================") 
strFileOpen.WriteLine("= 18. Mail Distribution Groups Deleted in the past 24hrs =") 
strFileOpen.WriteLine("==========================================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
    If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =4753 Then 
                count18 = count18 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
    end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 18.)Mail Distribution Groups Deleted in the past 24hrs TOTAL = " & Count18) 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine(" ") 
'19------------------------------------------------------------------------------------------------------------------------ 
 
strFileOpen.WriteLine("=================================================================") 
strFileOpen.WriteLine("= 19. Users Added To Mail Distribution Groups in the past 24hrs =") 
strFileOpen.WriteLine("=================================================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
    If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =4751 Then 
                count19 = count19 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
    end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 19.)Users Added To Mail Distribution Groups in the past 24hrs TOTAL = " & Count19) 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine(" ") 
'20------------------------------------------------------------------------------------------------------------------------ 
 
strFileOpen.WriteLine("==================================================================") 
strFileOpen.WriteLine("= 20. Mail Distribution Groups Amended/Changed in the past 24hrs =") 
strFileOpen.WriteLine("==================================================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
    If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =4750 Then 
                count20 = count20 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Important Note:    To see exactly what changed on the Group object refer to events created") 
                strFileOpen.WriteLine    ("---------------    for (Directory Service Changes) later in this log for Class: Group") 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
    end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 20.)Mail Distribution Groups Amended/Changed in the past 24hrs TOTAL = " & Count20) 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine(" ") 
'21------------------------------------------------------------------------------------------------------------------------ 
 
strFileOpen.WriteLine("=========================================================================") 
strFileOpen.WriteLine("= 21. Directory Service Objects Created in the past 24hrs (Check CLASS) =") 
strFileOpen.WriteLine("=========================================================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
    If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =5137 Then 
                count21 = count21 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
    end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 21.)Directory Service Objects Created in the past 24hrs (Check CLASS) TOTAL = " & Count21) 
strFileOpen.WriteLine("stop21") 
strFileOpen.WriteLine(" ") 
'22------------------------------------------------------------------------------------------------------------------------ 
 
strFileOpen.WriteLine("=======================================================================") 
strFileOpen.WriteLine("= 22. Directory Service Objects Moved in the past 24hrs (Check CLASS) =") 
strFileOpen.WriteLine("=======================================================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
    If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =5139 Then 
                count22 = count22 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
    end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 22.)Directory Service Objects Moved in the past 24hrs (Check CLASS) TOTAL = " & Count22) 
strFileOpen.WriteLine("stop22") 
strFileOpen.WriteLine(" ") 
'23------------------------------------------------------------------------------------------------------------------------ 
 
strFileOpen.WriteLine("=========================================================================") 
strFileOpen.WriteLine("= 23. Directory Service Objects Deleted in the past 24hrs (Check CLASS) =") 
strFileOpen.WriteLine("=========================================================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
    If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =5141 Then 
                count23 = count23 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
    end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 23.)Directory Service Objects Deleted in the past 24hrs (Check CLASS) TOTAL = " & Count23) 
strFileOpen.WriteLine("stop23") 
strFileOpen.WriteLine(" ") 
'24------------------------------------------------------------------------------------------------------------------------ 
 
strFileOpen.WriteLine("=================================================================================================") 
strFileOpen.WriteLine("= 24. A directory service object was modified (CHECK OBJECT CLASS) for object that was modified =") 
strFileOpen.WriteLine("=================================================================================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
    If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =5136 Then 
                count24 = count24 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
    end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 24.)A directory service object was modified (CHECK OBJECT CLASS) for object that was modified TOTAL = " & Count24) 
strFileOpen.WriteLine("stop24") 
strFileOpen.WriteLine(" ") 
'25--------------------------------------------------------------------------------------------------------------------------------------------------- 
 
strFileOpen.WriteLine("========================================================================================================================") 
strFileOpen.WriteLine("==================================") 
strFileOpen.WriteLine("= 25. EPIC LOGON FAILED ATTEMPTS =") 
strFileOpen.WriteLine("==================================") 
For Each objItem in colLoggedEvents 
    EventDate = GetVBDate(objItem.TimeGenerated) 
    If DateDiff("h",DateNow,EventDate) > -24 Then 
            If objItem.EventCode =4625 Then 
                count25 = count25 + 1 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    ("---------------------------------Start Of Entry--------------------------------") 
                strFileOpen.WriteLine    ("EventDate\Time:    " & EventDate) 
                strFileOpen.WriteLine    ("Message:            " & objItem.Message) 
                strFileOpen.WriteLine    ("----------------------------------End Of Entry---------------------------------") 
                strFileOpen.WriteLine    (" ") 
                strFileOpen.WriteLine    (" ") 
            End If 
    end if 
Next 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine("** 25.)EPIC LOGON FAILED ATTEMPTS TOTAL = " & Count25) 
strFileOpen.WriteLine(" ") 
strFileOpen.WriteLine(" ") 
'-------------------------------------backup and Clear security event log--------------------------------------------------------------------------- 
 
dtmThisDay = Day(Date) 
dtmThisMonth = Month(Date) 
dtmThisYear = Year(Date) 
strBackupName = dtmThisYear & "_" & dtmThisMonth _ 
    & "_" & dtmThisDay 
strComputer = "." 
Set objWMIService = GetObject("winmgmts:" _ 
    & "{impersonationLevel=impersonate,(Backup)}!\\" & _ 
        strComputer & "\root\cimv2") 
Set colLogFiles = objWMIService.ExecQuery _ 
    ("Select * from Win32_NTEventLogFile " _ 
        & "Where LogFileName='Security'") 
For Each objLogfile in colLogFiles 
    objLogFile.BackupEventLog("c:\audit_AD\" _ 
        & strBackupName & _ 
        "_Security.evt") 
    objLogFile.ClearEventLog() 
Next 
'--------------------------------------------------------------------------------------------------------------------------------------------------- 
 
Function GetVBDate(wd) 
  GetVBDate = DateSerial(left(wd,4),mid(wd,5,2),mid(wd,7,2))+ TimeSerial(mid(wd,9,2),mid(wd,11,2),mid(wd,13,2)) 
End Function 
'--------------------------------------------------------------------------------------------------------------------------------------------------- 
'================================================================SECTION 2 AD Auditing============================================================== 
'-----------------------------------------------------Declaring and setting variables--------------------------------------------------------------- 
WScript.Sleep(4000) 
 
Dim strEmailFrom, strEmailTo, strEmailSubject, strEmailBody, strSMTP, OUcreateCount, OUDeleteCount, OUMoveCount, OUChangeCount 
Dim PermChangeCount 
 
OUcreateCount = 0 
OUDeleteCount = 0 
OUMoveCount = 0 
OUChangeCount = 0 
PermChangeCount = 0 
 
Const ForReading=1 
 
 
Set WshNetwork = WScript.CreateObject("WScript.Network") 
StrComputer = WshNetwork.ComputerName 
 
Set objFSO = CreateObject("Scripting.FileSystemObject") 
folder = "C:\audit_AD\" 
filePath = folder & "AD_Account_Management_Events.txt"             'original log created by SECTION 1 that will be used in this script to generate the  
Set myFile = objFSO.OpenTextFile(filePath, ForReading, True)    'summary report, This file must exist for this Script to work 
 
strEmailFrom = "xx@xx.com" 
strEmailTo = "aa@aa.com; bb@bb.com" 
strEmailSubject = "Summary Of AD Activity on " & StrComputer & " for the past 24hrs - Date/TimeStamp: " & Datenow 
strSMTP = "xxx.xxx.xxx.xxx" 
 
'------------------------------------------------------Important Notes Area in Body Of E-mail------------------------------------------------------- 
strEmailBody = strEmailbody & vbCRLf & "IMPORTANT NOTES to Auditor:" 
    strEmailBody = strEmailbody & vbCRLf 
    strEmailBody = strEmailbody & vbCRLf & "Sections 21,22,23,24 all related to Directory Service Objects. These 4 categories are repetative of other sections," 
    strEmailBody = strEmailbody & vbCRLf & "meaning that if an object was amended, (For example the permissions changed on a user account in section 5 etc.) the" 
    strEmailBody = strEmailbody & vbCRLf & "event will also appear in section 24 with specific details. Thus sections 21,22,23 and 24 will log in depth changes" 
    strEmailBody = strEmailbody & vbCRLf & "creations, deletions, move's and permissions. Thus in this example section 5 will only notify that a change has occured" 
    strEmailBody = strEmailbody & vbCRLf & "and section 24 will log the exact specific change made." 
    strEmailBody = strEmailbody & vbCRLf & "" 
    strEmailBody = strEmailbody & vbCRLf & "Thus when reviewing logs in sections 21,22,23 and 24, look at the line that says Class: to see what object was changed" 
    strEmailBody = strEmailbody & vbCRLf & "This will be either, user, computer, group, organisationalunit etc....." 
    strEmailBody = strEmailbody & vbCRLf & "Additionally if the LDAP Display Name: variable is NTSecurityDescriptor and the Class: is OrganisationalUnit this means" 
    strEmailBody = strEmailbody & vbCRLf & "that the permission has changed on the OU. Additional Totals have been added for OU's in the summary report with regards to sections 21, 22, 23 and 24." 
    strEmailBody = strEmailbody & vbCRLf & "" 
    strEmailBody = strEmailbody & vbCRLf & "The Full report can be viewed at on the DC at C:\Audit_Ad" 
    strEmailBody = strEmailbody & vbCRLf 
    strEmailBody = strEmailbody & vbCRLf 
 
'------------------This section reads the original log file created in SECTION 1 and generates a summary report------------------------------------- 
Do While Not myFile.AtEndofStream 
    myLine = myFile.ReadLine 
 
    MarkersLine = left(myline,3) ' main summary markers(Will read all lines starting with "** " in log and append into email body) 
    EventLine = left(myline,19) 'eventlog (Will read all lines starting with "defined field" in original log and append into email body) 
 
    If EventLine = "Time of last clear:" Then 
            strEmailBody = strEmailbody & vbCRLf & "Security Event Log " & MyLine & " on " & StrComputer & vbCRLf 
            strEmailBody = strEmailbody & vbCRLf 
    End If 
 
    If MarkersLine = "** " Then 
        strEmailBody = strEmailbody & vbCRLf & MyLine & vbCRLf 
    End If 
 
Loop 
myFile.Close 
 
'1.---------This section reads the original log file created in SECTION 1 and generates a summary report specifically for OU Creations-------------- 
Set objFSO = CreateObject("Scripting.FileSystemObject") 
folder = "C:\audit_AD\" 
filePath = folder & "AD_Account_Management_Events.txt" 
Set myFile = objFSO.OpenTextFile(filePath, ForReading, True) 
 
blnAddToBody = False 
 
Do While Not myFile.AtEndofStream 
    myLine = myFile.ReadLine 
 
    ClassLine = "    Class:    organizationalUnit" ' Sets the class that will be searched inside the original log 
    strStartLine1 = "= 21. Directory Service Objects Created in the past 24hrs (Check CLASS) =" 
    StrEndLine1 = "stop21" 
 
    If myLine = strStartLine1 Then 
        blnAddToBody = True 
    End If 
 
    If myLine = ClassLine Then 
        If blnAddToBody = True Then 
            OUcreateCount = OUcreateCount + 1 
        end if 
    end if 
 
    if myLine = strEndLine1 Then 
        blnAddToBody = False 
    end if 
Loop 
myFile.Close 
 
'2.---------This section reads the original log file created in SECTION 1 and generates a summary report specifically for OU Moves------------------- 
Set objFSO = CreateObject("Scripting.FileSystemObject") 
folder = "C:\audit_AD\" 
filePath = folder & "AD_Account_Management_Events.txt" 
Set myFile = objFSO.OpenTextFile(filePath, ForReading, True) 
 
blnAddToBody = True 
 
Do While Not myFile.AtEndofStream 
    myLine = myFile.ReadLine 
 
    ClassLine = "    Class:    organizationalUnit" ' Sets the class that will be searched inside the original log 
    strStartLine2 = "= 22. Directory Service Objects Moved in the past 24hrs (Check CLASS) =" 
    StrEndLine2 = "stop22" 
 
    If myLine = strStartLine2 Then 
        blnAddToBody = True 
    End If 
 
    If myLine = ClassLine Then 
        If blnAddToBody = True Then 
            OUMoveCount = OUMoveCount + 1 
        end if 
    end if 
 
    if myLine = strEndLine2 Then 
        blnAddToBody = False 
    end if 
Loop 
myFile.Close 
 
'3.---------This section reads the original log file created in SECTION 1 and generates a summary report specifically for OU Deletions---------------- 
Set objFSO = CreateObject("Scripting.FileSystemObject") 
folder = "C:\audit_AD\" 
filePath = folder & "AD_Account_Management_Events.txt" 
Set myFile = objFSO.OpenTextFile(filePath, ForReading, True) 
 
blnAddToBody = False 
 
Do While Not myFile.AtEndofStream 
    myLine = myFile.ReadLine 
 
    ClassLine = "    Class:    organizationalUnit" ' Sets the class that will be searched inside the original log 
    strStartLine3 = "= 23. Directory Service Objects Deleted in the past 24hrs (Check CLASS) =" 
    StrEndLine3 = "stop23" 
 
    If myLine = strStartLine3 Then 
        blnAddToBody = True 
    End If 
 
    If myLine = ClassLine Then 
        If blnAddToBody = True Then 
            OUDeleteCount = OUDeleteCount + 1 
        end if 
    end if 
 
    if myLine = strEndLine3 Then 
        blnAddToBody = False 
    end if 
Loop 
myFile.Close 
 
'4.---------This section reads the original log file created in SECTION 1 and generates a summary report specifically for OU Changes---------------- 
Set objFSO = CreateObject("Scripting.FileSystemObject") 
folder = "C:\audit_AD\" 
filePath = folder & "AD_Account_Management_Events.txt" 
Set myFile = objFSO.OpenTextFile(filePath, ForReading, True) 
 
blnAddToBody = False 
 
Do While Not myFile.AtEndofStream 
    myLine = myFile.ReadLine 
 
    ClassLine = "    Class:    organizationalUnit" ' Sets the class that will be searched inside the original log 
    strStartLine4 = "= 24. A directory service object was modified (CHECK OBJECT CLASS) for object that was modified =" 
    StrEndLine4 =  "stop24" 
 
        If myLine = strStartLine4 Then 
        blnAddToBody = True 
    End If 
 
    If myLine = ClassLine Then 
        If blnAddToBody = True Then 
            OUChangeCount = OUChangeCount + 1 
        end if 
    end if 
 
    if myLine = strEndLine4 Then 
        blnAddToBody = False 
    end if 
Loop 
myFile.Close 
 
'============================================================END OF SUMMARY ENUMERATION============================================================= 
    strEmailBody = strEmailbody & vbCRLf 
    strEmailBody = strEmailbody & vbCRLf & "With regards to section 21: Specific OU Creations = " & OUCreateCount & vbCRLf 
    strEmailBody = strEmailbody & vbCRLf & "With regards to section 22: Specific OU Moves = " & OUMoveCount & vbCRLf 
    strEmailBody = strEmailbody & vbCRLf & "With regards to section 23: Specific OU Deletions = " & OUDeleteCount & vbCRLf 
    strEmailBody = strEmailbody & vbCRLf & "With regards to section 24: Specific OU Changes e.g. Permissions = " & OUChangeCount & vbCRLf 
 
            Set objEmail = CreateObject("CDO.Message") 
            objEmail.From = strEmailFrom 
            objEmail.To = strEmailTo 
            objEmail.Subject = strEmailSubject 
            objEmail.Textbody = strEmailBody 
            objEmail.Configuration.Fields.Item _ 
            ("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2 
            objEmail.Configuration.Fields.Item _ 
            ("http://schemas.microsoft.com/cdo/configuration/smtpserver") = strSMTP 
            objEmail.Configuration.Fields.Item _ 
                ("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 25 
            objEmail.Configuration.Fields.Update 
            objEmail.Send