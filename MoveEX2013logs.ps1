# ------------------------ 
# MoveEX2013logs.ps1 
# ------------------------ 
# 
# Version 1.0 by KSB 
# 
# This script will move all of the configurable logs for Exchange 2013 from the C: drive 
# to the L: drive.  The folder subtree and paths on L: will stay the same as they were on C: 
# 
# Get the name of the local computer and set it to a variable for use later on. 
$exchangeservername = $env:computername 
# Move the standard log files for the TransportService to the same path on the L: drive that they were on C: 
Set-TransportService -Identity $exchangeservername ` 
-ConnectivityLogPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\Connectivity" ` 
-MessageTrackingLogPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\MessageTracking" ` 
-IrmLogPath "f:\Program Files\Microsoft\Exchange Server\V15\Logging\IRMLogs" ` 
-ActiveUserStatisticsLogPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ActiveUsersStats" ` 
-ServerStatisticsLogPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ServerStats" ` 
-ReceiveProtocolLogPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ProtocolLog\SmtpReceive" ` 
-RoutingTableLogPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\Routing" ` 
-SendProtocolLogPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ProtocolLog\SmtpSend" ` 
-QueueLogPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\QueueViewer" ` 
-WlmLogPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\WLM" ` 
-PipelineTracingPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\PipelineTracing" ` 
-AgentLogPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\AgentLog"
# move the path for the PERFMON logs from the C: drive to the L: drive 
logman -stop ExchangeDiagnosticsDailyPerformanceLog 
logman -update ExchangeDiagnosticsDailyPerformanceLog -o "f:\Program Files\Microsoft\Exchange Server\V15\Logging\Diagnostics\DailyPerformanceLogs\ExchangeDiagnosticsDailyPerformanceLog"
logman -start ExchangeDiagnosticsDailyPerformanceLog 
logman -stop ExchangeDiagnosticsPerformanceLog 
logman -update ExchangeDiagnosticsPerformanceLog -o "f:\Program Files\Microsoft\Exchange Server\V15\Logging\Diagnostics\PerformanceLogsToBeProcessed\ExchangeDiagnosticsPerformanceLog"
logman -start ExchangeDiagnosticsPerformanceLog 
# Get the details on the EdgeSyncServiceConfig and store them in a variable for use in setting the path 
$EdgeSyncServiceConfigVAR=Get-EdgeSyncServiceConfig 
# Move the Log Path using the variable we got 
Set-EdgeSyncServiceConfig -Identity $EdgeSyncServiceConfigVAR.Identity -LogPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\EdgeSync"
# Move the standard log files for the FrontEndTransportService to the same path on the L: drive that they were on C: 
Set-FrontendTransportService  -Identity $exchangeservername ` 
-AgentLogPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\AgentLog" ` 
-ConnectivityLogPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\Connectivity" ` 
-ReceiveProtocolLogPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpReceive" ` 
-SendProtocolLogPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpSend"
# MOve the log path for the IMAP server 
Set-ImapSettings -LogFileLocation "f:\Program Files\Microsoft\Exchange Server\V15\Logging\Imap4"
# Move the logs for the MailBoxServer 
Set-MailboxServer -Identity $exchangeservername ` 
-CalendarRepairLogPath "f:\Program Files\Microsoft\Exchange Server\V15\Logging\Calendar Repair Assistant" ` 
-MigrationLogFilePath  "f:\Program Files\Microsoft\Exchange Server\V15\Logging\Managed Folder Assistant"
# Move the standard log files for the MailboxTransportService to the same path on the L: drive that they were on C: 
Set-MailboxTransportService -Identity $exchangeservername ` 
-ConnectivityLogPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Mailbox\Connectivity" ` 
-MailboxDeliveryAgentLogPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Mailbox\AgentLog\Delivery" ` 
-MailboxSubmissionAgentLogPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Mailbox\AgentLog\Submission" ` 
-ReceiveProtocolLogPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Mailbox\ProtocolLog\SmtpReceive" ` 
-SendProtocolLogPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Mailbox\ProtocolLog\SmtpSend" ` 
-PipelineTracingPath "f:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Mailbox\PipelineTracing"
# MOve the log path for the POP3 server 
Set-PopSettings -LogFileLocation "f:\Program Files\Microsoft\Exchange Server\V15\Logging\Pop3"