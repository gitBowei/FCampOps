443 | % {$test= new-object system.Net.Sockets.TcpClient;
$wait = $test.beginConnect("portal.microsoftonline.com",$_,$null,$null);
($wait.asyncwaithandle.waitone(250,$false)); if($test.Connected)
{echo "$_ open"}else{echo "$_ closed"}} | select-string " "