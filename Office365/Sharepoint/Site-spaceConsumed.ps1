#Config Parameters

$AdminSiteURL="https://ikoalosaurus-admin.sharepoint.com"

$ReportOutput="C:\Temp\SPOStorage.csv"



#Get Credentials to connect to SharePoint Admin Center

$Cred = Get-Credential



#Connect to SharePoint Online Admin Center

Connect-SPOService -Url $AdminSiteURL –Credential $Cred



#Get all Site collections

$SiteCollections = Get-SPOSite -Limit All

Write-Host "Total Number of Site collections Found:"$SiteCollections.count -f Yellow



#Array to store Result

$ResultSet = @()



Foreach($Site in $SiteCollections)

{

    Write-Host "Processing Site Collection :"$Site.URL -f Yellow

    #Send the Result to CSV

    $Result = new-object PSObject

    $Result| add-member -membertype NoteProperty -name "SiteURL" -Value $Site.URL

    $Result | add-member -membertype NoteProperty -name "Allocated" -Value $Site.StorageQuota

    $Result | add-member -membertype NoteProperty -name "Used" -Value $Site.StorageUsageCurrent

    $Result | add-member -membertype NoteProperty -name "Warning Level" -Value  $site.StorageQuotaWarningLevel

    $Result | add-member -membertype NoteProperty -name "Title" -Value $Site.Title

    $Result | add-member -membertype NoteProperty -name "Url" -Value $Site.Url

    $Result | add-member -membertype NoteProperty -name "LastContentModifiedDate" -Value $Site.LastContentModifiedDate

    $Result | add-member -membertype NoteProperty -name "Status" -Value $Site.Status

    $Result | add-member -membertype NoteProperty -name "LocaleId" -Value $Site.LocaleId

    $Result | add-member -membertype NoteProperty -name "LockState" -Value $Site.LockState

    $Result | add-member -membertype NoteProperty -name "StorageQuota" -Value $Site.StorageQuota

    $Result | add-member -membertype NoteProperty -name "StorageQuotaWarningLevel" -Value $Site.StorageQuotaWarningLevel

    $Result | add-member -membertype NoteProperty -name "Used" -Value $Site.StorageUsageCurrent

    $Result | add-member -membertype NoteProperty -name "CompatibilityLevel" -Value $Site.CompatibilityLevel

    $Result | add-member -membertype NoteProperty -name "Template" -Value $Site.Template

    $Result | add-member -membertype NoteProperty -name "SharingCapability" -Value $Site.SharingCapability

    $ResultSet += $Result

}



#Export Result to csv file

$ResultSet |  Export-Csv $ReportOutput -notypeinformation



Write-Host "Site Quota Report Generated Successfully!" -f Green