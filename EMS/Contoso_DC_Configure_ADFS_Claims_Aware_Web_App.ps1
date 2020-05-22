# Use the FedUtil.exe to configure the Claims Aware Web App to trust AD FS for authorization
& 'C:\Program Files (x86)\Windows Identity Foundation SDK\v3.5\FedUtil.exe' /silent C:\DemoContent\ClaimAppSTSConfig.xml /output c:\fed.txt

# Wait two minutes after the configuration 
Start-Sleep -Seconds 120

