‘ *******************************************************************
 ‘ Gets Azure credit remaining
 ‘ Lineral Solutions, 2014
 ‘ *******************************************************************

‘ parse arguments
 Set args = WScript.Arguments
 If args.Length = 3 Then
 subscriptionId = args(0)
 userName = args(1)
 userPasswd = args(2)
 filterField = “filter:*”
 ElseIf args.Length = 4 Then
 subscriptionId = args(0)
 userName = args(1)
 userPasswd = args(2)
 filterField = args(3)
 Else
 WScript.Echo “Error: cli parameters must be %subscriptionId% %userName% %password% [filter:credit|days|burnrate]” & vbCrLf & _
 vbCrLf & _
 “Example” & vbCrLf & _
 “C:\> Get-AzureCreditInfo 12345678-ABCD-JKLM-WXYZ-123456789012 claire@hotmail.com MyPasSW0rd7? & vbCrLf & _
 “C:\> Get-AzureCreditInfo 12345678-ABCD-JKLM-WXYZ-123456789012 claire@hotmail.com MyPasSW0rd7 filter:credit”

WScript.Quit
 End If

‘ — script variables
 targetUrl = “https://account.windowsazure.com/Subscriptions/Statement?subscriptionId=” & subscriptionId
 loginPageTitle = “Sign in to your Microsoft account”  ‘ identifier for login page
 timeoutThreshold = 30 ‘ seconds
 waitInterval = 3 ‘ each wait interval, in secs
 ‘ — /script variables

‘ — global vars
 internalErrCode = 0
 koTimer = 0
 ‘ — /global vars

On Error Resume Next

‘ create ie object
 Set ie = CreateObject(“InternetExplorer.Application”)
 ie.Navigate targetUrl
 ie.Visible = False

If Err.Number <> 0 Then
 WScript.Echo “Error: ” & Err.Description
 ie.Quit
 ie = Nothing
 WScript.Quit
 End If

‘ load target url
 Do While (ie.Busy)
 WScript.Sleep (waitInterval * 1000)
 koTimer = koTimer + (waitInterval * 1000)
 If (timeoutThreshold * 1000) < koTimer Then
 ie.Stop
 internalErrCode = 1
 Exit Do
 End If
 Loop

If internalErrCode <> 0 Then
 WScript.Echo “Error: ” & “timeout.”
 ie.Quit
 ie = Nothing
 WScript.Quit
 End If

‘ handle for direction to login page
 If ie.Document.title = loginPageTitle Then
 ie.Document.all.login.Value = userName
 ie.Document.all.passwd.Value = userPasswd
 ie.Document.all.SI.Click
 ie.Document.getElementById(“idSIButton9?).Click

If Err.Number <> 0 Then
 ‘    WScript.Echo “Error: ” & Err.Description
 ‘    ie = Nothing
 ‘    WScript.Quit
 Err.Clear
 End If

Do While (ie.Busy)
 WScript.Sleep (waitInterval * 1000)
 koTimer = koTimer + (waitInterval * 1000)
 If (timeoutThreshold * 1000) < koTimer Then
 ie.Stop
 internalErrCode = 1
 Exit Do
 End If
 Loop

If internalErrCode <> 0 Then
 WScript.Echo “Error: timeout”
 ie.Quit
 ie = Nothing
 WScript.Quit
 End If
 End If

‘ test whether we’re in, then get the bits that matters.
 If ie.LocationUrl <> targetUrl Then
 WScript.Echo “Error: bad redirection”
 ie.Quit
 ie = Nothing
 WScript.Quit
 End If

creditLeft = ie.Document.getElementsByClassName(“usage-meter-consumed”)(0).innerHTML
 creditBurnRate = ie.Document.getElementsByClassName(“burn-rate-message”)(0).innerHTML
 creditDaysLeft = ie.Document.getElementsByClassName(“credit-info”)(0).innerHTML

If Err.Number <> 0 Then
 WScript.Echo “Error: ” & Err.Description
 ie.Quit
 ie = Nothing
 WScript.Quit
 End If

‘ clean up
 ie.Quit
 ie = Nothing

‘ format and output results
 creditLeft = TrimTextBlock(creditLeft)
 creditDaysLeft = TrimTextBlock(creditDaysLeft)
 creditBurnRate = TrimTextBlock(creditBurnRate)

Select Case filterField
 Case “filter:*”
 WScript.Echo “CreditLeft/ ” & creditLeft
 WScript.Echo “DaysLeft/ ” & creditDaysLeft
 WScript.Echo “BurnRate/ ” & creditBurnRate

Case “filter:credit”
 WScript.Echo creditLeft

Case “filter:days”
 WScript.Echo creditDaysLeft

Case “filter:burnrate”
 WScript.Echo creditBurnRate

Case Else
 WScript.Echo “CreditLeft/ ” & creditLeft
 WScript.Echo “DaysLeft/ ” & creditDaysLeft
 WScript.Echo “BurnRate/ ” & creditBurnRate

End Select
 ”’ <summary>
 ”’ Trims off characters in the following order:
 ”’ CrLf, Cr, Lf, Tab, Space
 ”’ </summary>
 Function TrimTextBlock(text)
 text = TrimAny(text, vbCrLf)
 text = TrimAny(text, vbCr)
 text = TrimAny(text, vbLf)
 text = TrimAny(text, vbTab)
 text = TrimAny(text, ” “)

TrimTextBlock = text
 End Function

”’ <summary>
 ”’ Same as Trim, but you can specify the trim character/string other than white space
 ”’ </summary>
 Function TrimAny(text, trimString)
 text = LTrimAny(text, trimString)
 text = RTrimAny(text, trimString)

TrimAny = text
 End Function

”’ <summary>
 ”’ Same as LTrim, but you can specify the trim character/string other than white space
 ”’ </summary>
 Function LTrimAny(text, trimString)
 Do
 i = InStr(text, trimString)
 If i = 1 Then
 text = Right(text, Len(text) – Len(trimString))
 Else
 Exit Do
 End If
 Loop

LTrimAny = text
 End Function

”’ <summary>
 ”’ Same as RTrim, but you can specify the trim character/string other than white space
 ”’ </summary>
 Function RTrimAny(text, trimString)
 Do
 i = InStrRev(text, trimString)
 If i = Len(text) Then
 text = Left(text, Len(text) – Len(trimString))
 Else
 Exit Do
 End If
 Loop

RTrimAny = text
 End Function
