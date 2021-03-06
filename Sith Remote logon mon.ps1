' Script:    Process_Monitor.vbs 
' Purpose:  Live process monitoring script that will trigger an e-mail to a recipient if a certain process is started 
' Author:   Paperclips (The Dark Lord) 
' Email:    magiconion_M@hotmail.com 
' Date:     Feb 2011 
' Comments: This particular monitor monitors the LogonUI process on Win7 
' Notes:    -  
 
strComputer = "." 'you can type any remote computername here 
Set objNetwork = CreateObject("WScript.Network") 
 
Set objWMIService = GetObject("winmgmts:" & _ 
    "{impersonationLevel=Impersonate}!\\" & _ 
    strComputer & "\root\cimv2") 
'---------------------------------------------------------------------------------------LogonUI process------------------------------------------------------------------------------------------------ 
Set colMonitoredProcesses = objWMIService.ExecNotificationQuery("SELECT * FROM __InstanceCreationEvent Within 5 WHERE TargetInstance Isa ""Win32_Process"" And TargetInstance.Name = 'LogonUI.exe'") 
Do While True 
    Set objProcess = colMonitoredProcesses.NextEvent 
    Set Items = objWMIService.ExecQuery("select * from win32_process where Name = 'LogonUI.exe'") 
        For Each objProcess in Items 
                colProperties = objProcess.GetOwner(strNameOfUser) 
        Next 
 
       ' Email variables: 
    strServer = "xxx.xxx.xxx.xxx" 
    strTo = "aa@bb.com" 
    strFrom = "cc@dd.com" 
    strSubject = "LogonUI.exe detected on " & StrComputer & ". Process owner is: " & strNameOfUser & ". Processes monitored by "& objNetwork.Username 
    strBody =  StrComputer & " locked OK. This is a live monitor notification. A process 'LogonUI.exe' has triggered this notification signaling that this computer is in the process of being unlocked." & VbCrLf 
    SendEmail strServer, strTo, strFrom, strSubject, strBody, "" 
Loop 
'---------------------------------------------------------------------------------------Mail Sub------------------------------------------------------------------------------------------------ 
Sub SendEmail(strServer, strTo, strFrom, strSubject, strBody, strAttachment) 
        Dim objMessage 
         
        Set objMessage = CreateObject("CDO.Message") 
        objMessage.To = strTo 
        objMessage.From = strFrom 
        objMessage.Subject = strSubject 
        objMessage.TextBody = strBody 
          If strAttachment <> "" Then objMessage.AddAttachment strAttachment 
           
        '==This section provides the configuration information for the remote SMTP server. 
        objMessage.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2 
        'Name or IP of Remote SMTP Server 
        objMessage.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = strServer 
        'Server port (typically 25) 
        objMessage.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 25       
        objMessage.Configuration.Fields.Update 
        '==End remote SMTP server configuration section== 
  
        objMessage.Send 
        Set objMessage = Nothing 
End Sub