$sourceFile = 'C:\Users\fcampo\Downloads\Proxy_09_13_2017.zip'
$targetFolder = 'C:\Users\fcampo\Downloads\'
 
[System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
[System.IO.Compression.ZipFile]::ExtractToDirectory($sourceFile, $targetFolder)

#From <https://alexandrebrisebois.wordpress.com/2016/11/05/unzip-a-file-in-powershell-the-easy-way/> 