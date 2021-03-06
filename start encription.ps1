1.## Start-Encryption
2.##################################################################################################
3.## Rijndael symmetric key encryption ... with no passes on the key. Very lazy.
4.## USAGE:
5.## $encrypted = Encrypt-String "Oisin Grehan is a genius" "P@ssw0rd"
6.## Decrypt-String $encrypted "P@ssw0rd"
7.##
8.## You can choose to return an array by passing -arrayOutput to Encrypt-String
9.## I chose to use Base64 encoded strings because they're easier to save ...
10. 
11.[Reflection.Assembly]::LoadWithPartialName("System.Security")
12. 
13.function Encrypt-String($String, $Passphrase, $salt="My Voice is my P455W0RD!", $init="Yet another key", [switch]$arrayOutput)
14.{
15.   $r = new-Object System.Security.Cryptography.RijndaelManaged
16.   $pass = [Text.Encoding]::UTF8.GetBytes($Passphrase)
17.   $salt = [Text.Encoding]::UTF8.GetBytes($salt)
18. 
19.   $r.Key = (new-Object Security.Cryptography.PasswordDeriveBytes $pass, $salt, "SHA1", 5).GetBytes(32) #256/8
20.   $r.IV = (new-Object Security.Cryptography.SHA1Managed).ComputeHash( [Text.Encoding]::UTF8.GetBytes($init) )[0..15]
21.   
22.   $c = $r.CreateEncryptor()
23.   $ms = new-Object IO.MemoryStream
24.   $cs = new-Object Security.Cryptography.CryptoStream $ms,$c,"Write"
25.   $sw = new-Object IO.StreamWriter $cs
26.   $sw.Write($String)
27.   $sw.Close()
28.   $cs.Close()
29.   $ms.Close()
30.   $r.Clear()
31.   [byte[]]$result = $ms.ToArray()
32.   if($arrayOutput) {
33.      return $result
34.   } else {
35.      return [Convert]::ToBase64String($result)
36.   }
37.}
38. 
39.function Decrypt-String($Encrypted, $Passphrase, $salt="My Voice is my P455W0RD!", $init="Yet another key")
40.{
41.   if($Encrypted -is [string]){
42.      $Encrypted = [Convert]::FromBase64String($Encrypted)
43.   }
44. 
45.   $r = new-Object System.Security.Cryptography.RijndaelManaged
46.   $pass = [System.Text.Encoding]::UTF8.GetBytes($Passphrase)
47.   $salt = [System.Text.Encoding]::UTF8.GetBytes($salt)
48. 
49.   $r.Key = (new-Object Security.Cryptography.PasswordDeriveBytes $pass, $salt, "SHA1", 5).GetBytes(32) #256/8
50.   $r.IV = (new-Object Security.Cryptography.SHA1Managed).ComputeHash( [Text.Encoding]::UTF8.GetBytes($init) )[0..15]
51. 
52.   $d = $r.CreateDecryptor()
53.   $ms = new-Object IO.MemoryStream @(,$Encrypted)
54.   $cs = new-Object Security.Cryptography.CryptoStream $ms,$d,"Read"
55.   $sr = new-Object IO.StreamReader $cs
56.   Write-Output $sr.ReadToEnd()
57.   $sr.Close()
58.   $cs.Close()
59.   $ms.Close()
60.   $r.Clear()
61.}

