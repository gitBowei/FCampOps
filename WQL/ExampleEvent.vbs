strComputer = "." 
Set objWMIService = GetObject("winmgmts:\\" _
    & strComputer & "\root\CIMV2") 
Set colItems = objWMIService.ExecQuery( _
    "SELECT * FROM Win32_NTLogEvent " _
    & "WHERE Logfile = 'Application'",,48)