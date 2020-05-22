Function Remove-SPOListSelectedItems { 
<# 
    .Synopsis 
    Remove all or selected items from list 
      
    .DESCRIPTION 
    Deletes all or selected items from list on site 
 
    .PARAMETER URL 
    URL address of site 
 
    .PARAMETER Credential 
    Credential to connect to site 
 
    .PARAMETER CLAMQuery 
    CLAM query to select items. You can use ClamDesigner 2013 to build them  
 
    .PARAMETER ListName 
    Name of list from whitch to delete items 
     
    .EXAMPLE 
    The following will try to add Mike Tyson to site collection administrators on Jhon Kowalki OneDrive 
 
 
    $MyQuery=@" 
            <Leq> 
                <FieldRef Name='EndDate' /> 
                <Value Type='DateTime'>2017-12-31T12:00:00Z</Value> 
            </Leq> 
    "@ 
 
    Clear-SPOListItems -Url https://teanant.sharepointonline.com/sites/site -ListName MyList -Credential $credential 
 
#> 
param( 
[string]$URL, 
[PSCredential]$credential, 
[string]$ListName, 
[Parameter(Mandatory=$false, HelpMessage="Put yout CLAM Query here")] 
    [string]$CLAMQuery="" 
) 
 
#Variables 
#Get list of all items from list 
$TempItems=@() #Temporary table to hold up to 5000 items 
$SiteListItems=@() #Table to hold all items 
$start_id=0 #Id from whitch to start getting items 
$end_id=5000 #First Id limit  
 
#Get content of Main List 
Write-Host "Connecting to site $URL to get list os SPO sites" -ForegroundColor Cyan 
$DestinationSiteConnection = New-Object Microsoft.SharePoint.Client.ClientContext($URL) 
$ConnectionCredential = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Credential.UserName, $Credential.Password) 
$DestinationSiteConnection.Credentials = $ConnectionCredential 
 
################################################################# 
#Get last item 
Write-Host "Getting data from list: $ListName" -ForegroundColor Cyan 
$SharePointSiteList = $DestinationSiteConnection.Web.Lists.GetByTitle($ListName) 
$DestinationSiteConnection.Load($SharepointSiteList) 
Execute-SPOQuery $DestinationSiteConnection 
 
$qCommand = @" 
            <View Scope="RecursiveAll"> 
                <Query> 
                    <OrderBy><FieldRef Name='ID' Ascending='False' /></OrderBy> 
                </Query> 
                <RowLimit Paged="TRUE">1</RowLimit> 
            </View> 
"@ 
$DestinationSiteQuery = New-Object Microsoft.SharePoint.Client.CamlQuery 
$DestinationSiteQuery.ViewXml = $qCommand  
$SiteListItems = $SharePointSiteList.getItems($DestinationSiteQuery) 
$DestinationSiteConnection.Load($SiteListItems) 
Execute-SPOQuery $DestinationSiteConnection 
$LastItemID=$SiteListItems[0].Id 
$SiteListItems=$null 
 
#Get all items 
While ($start_id -lt $LastItemID){ 
if(($CLAMQuery -eq $null) -or ($CLAMQuery -eq "")){ 
#Write-Host "Building query no CLAMQuery provided..." 
    $qCommand = @" 
            <View Scope="RecursiveAll"> 
                <Query> 
                <Where> 
                    <And> 
                    <Gt><FieldRef Name='ID'></FieldRef><Value Type='Number'>$start_id</Value></Gt> 
                    <Leq><FieldRef Name='ID'></FieldRef><Value Type='Number'>$end_id</Value></Leq> 
                    </And> 
                </Where> 
                </Query> 
                <RowLimit Paged="TRUE">5000</RowLimit> 
            </View> 
"@  
} 
else { 
$qCommand = @" 
            <View Scope="RecursiveAll"> 
                <Query> 
                <Where> 
                    <And> 
                        <And> 
                        <Gt><FieldRef Name='ID'></FieldRef><Value Type='Number'>$start_id</Value></Gt> 
                        <Leq><FieldRef Name='ID'></FieldRef><Value Type='Number'>$end_id</Value></Leq> 
                        </And> 
                        $CLAMQuery 
                    </And> 
                </Where> 
                </Query> 
                <RowLimit Paged="TRUE">5000</RowLimit> 
            </View> 
"@ 
} 
        
    $DestinationSiteQuery = New-Object Microsoft.SharePoint.Client.CamlQuery 
    $DestinationSiteQuery.ViewXml = $qCommand  
    $TempItems = $SharePointSiteList.getItems($DestinationSiteQuery) 
    $DestinationSiteConnection.Load($TempItems) 
    Execute-SPOQuery $DestinationSiteConnection 
    $SiteListItems += $TempItems 
 
$start_id=$end_id 
$end_id+=5000     
} 
 
Write-Host "Items do delte: $($SiteListItems.count)" -ForegroundColor Yellow 
 
$i=1 
ForEach ($ItemToDelete in $SiteListItems){ 
    Write-Progress -Id 1 -Activity "Deleting items" -Status "Deleting $i of $($SiteListItems.Count)" -CurrentOperation "Deleting item ID: $($ItemToDelete.Id), Name: $($ItemToDelete["FileRef"])" -PercentComplete ($i / $($SiteListItems.Count)*100) 
    $ItemToDelete.DeleteObject() 
    Execute-SPOQuery $DestinationSiteConnection 
    $i++ 
} 
 
}