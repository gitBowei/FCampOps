# Get the published Web Application Proxy application for "Work Folders"
# and then set the applicaiton to use Open Authorization (OAuth) when user connect by using a Windows Store app
Get-WebApplicationProxyApplication -Name "Work Folders" | Set-WebApplicationProxyApplication  -UseOAuthAuthentication 
