1.[reflection.assembly]::loadwithpartialname("Microsoft.SharePoint")
2.$cs = [microsoft.sharepoint.administration.spwebservice]::ContentService
3.$global:largeListThreshhold = 2000
4. 
5.function Is-Admin([Microsoft.SharePoint.SPRoleAssignment]$roleAssignment)
6.{
7.        return (($roleAssignment.roledefinitionbindings | where { ($_.BasePermissions.ToString() -match "ManageLists|ManageWeb|FullMask") }) -ne $null)
8.}
9. 
10.function Write-ListDetails($list,$web,$site)
11.{
12.        $fields = @()
13.        $fields += $list.Title
14.        $fields += $list.RootFolder
15.        $fields += ($list.ContentTypes | select -first 1).Name
16.        $fields += ($list.ContentTypes | select -first 1).Id.ToString()
17.        $fields += ($list.ContentTypes | select -first 1).Id.Parent.ToString()
18.        $fields += $list.Items.NumberOfFields
19.        $fields += $list.Items.Count
20.        $fields += $list.Created
21.        $fields += $list.LastItemModifiedDate
22.        
23.        $listAdmins = @()
24.        $listAdmins += $list.RoleAssignments | where { Is-Admin $_ }
25.         if ($list.RoleAssignments.Count -gt 0 -and $listAdmins.Count -gt 0)
26.        {
27.                $fields += $listAdmins[0].Member.Name
28.                $fields += $listAdmins[0].Member.Email
29.                $fields += [string]::Join("; ", @($listAdmins | % { $_.Member.ToString() } ))
30.        } else {
31.                $fields += ""
32.                $fields += ""
33.                $fields += ""
34.        }
35.        $fields += $web.Url
36.        $fields += $web.Title
37.        $fields += $site.Url
38.        
39.        [string]::Join("`t", $fields)
40.}
41. 
42.function Enumerate-LargeListsInSite($siteCollection)
43.{
44.        foreach ($web in $siteCollection.AllWebs) {
45.                $web.Lists | where { $_.Items.Count -gt $global:largeListThreshhold } | foreach { Write-ListDetails -list $_ -web $web -site $siteCollection }
46.                
47.                $web.Dispose()
48.        }
49.}
50. 
51.function List-FieldNames
52.{
53.        $fieldNames = @()
54.        $fieldNames += "ListTitle"
55.        $fieldNames += "ListRootFolderURL"
56.        $fieldNames += "ContentType1Name"
57.        $fieldNames += "ContentType1ID"
58.        $fieldNames += "ContentType1ParentID"
59.        $fieldNames += "NumberOfFields"
60.        $fieldNames += "Items"
61.        $fieldNames += "CreatedDate"
62.        $fieldNames += "LastItemModifiedDate"
63.        $fieldNames += "ListAdmin1Name"
64.        $fieldNames += "ListAdmin1Email"
65.        $fieldNames += "AllListAdmins"
66.        $fieldNames += "WebURL"
67.        $fieldNames += "WebTitle"
68.        $fieldNames += "SiteURL"
69.        
70.        return [string]::Join("`t", $fieldNames)
71.}
72. 
73.function Enumerate-LargeLists
74.{
75.        List-FieldNames
76.                
77.        $webApplications = $cs.WebApplications | foreach { $_ }
78.        foreach ($webApplication in $webApplications) {
79.                $webApplication.Sites | foreach {
80.                        Enumerate-LargeListsInSite -siteCollection $_
81.                        
82.                        $_.Dispose()
83.                }
84.        }
85.}
86. 
87. 
88.#USAGE: paste contents into PowerShell window; call "Enumerate-LargeLists > yourtextfilename.txt"
89.#then paste contents of text file into Excel spreadsheet. Output is 
90.#intended to be perused and analyzed in Excel.

