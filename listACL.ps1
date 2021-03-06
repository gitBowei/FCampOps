1.#######################################
2.# TITLE: listACL.ps1                  #
3.# AUTHOR: Santiago Fernandez Mu&#241;oz    #
4.#                                     #
5.# DESC: This script generate a HTML   #
6.# report show all ACLs asociated with #
7.# a Folder tree structure starting in #
8.# root specified by the user          #
9.#######################################
10.        
11.param ([string] $computer = 'localhost',
12.                [string] $path = $(if ($help -eq $false) {Throw "A path is needed."}),
13.                [int] $level = 0,
14.                [string] $scope = 'administrator', 
15.                [switch] $help = $false,
16.                [switch] $debug = $false
17.        )
18.        
19.#region Initializations and previous checkings
20.#region Initialization
21.$allowedLevels = 10
22.$Stamp = get-date -uformat "%Y%m%d"
23.$report = "$PWD\$computer.html"
24.$comparison = ""
25.$UNCPath = "\\" + $computer + "\" + $path + "\"
26.#endregion
27. 
28.#region Previous chekings
29.#require -version 2.0
30.if ($level -gt $allowedLevels -or $level -lt 0) {Throw "Level out of range."}
31.if ($computer -eq 'localhost' -or $computer -ieq $env:COMPUTERNAME) { $UNCPath = $path }
32.switch ($scope) {
33.        micro {
34.                $comparison = '($acl -notlike "*administrator*" -and $acl -notlike "*BUILTIN*" -and $acl -notlike "*NT AUTHORITY*")'
35.        }
36.        user {
37.                $comparison = '($acl -notlike "*administrator*" -and $acl -notlike "*BUILTIN*" -and $acl -notlike "*IT*" -and $acl -notlike "*NT AUTHORITY*" -and $acl -notlike "*All*")'
38.        }
39.}
40.#endregion
41.#endregion
42. 
43.#region Function definitions
44.function drawDirectory([ref] $directory) {
45.        $dirHTML = '
46.        <div class="'
47.                if ($directory.value.level -eq 0) { $dirHTML += 'he0_expanded' } else { $dirHTML += 'he' + $directory.value.level } 
48.                $dirHTML += '"><span class="sectionTitle" tabindex="0">Folder ' + $directory.value.Folder.FullName + '</span></div>
49.                <div class="container"><div class="he' + ($directory.value.level + 1) + '"><span class="sectionTitle" tabindex="0">Access Control List</span></div>
50.                        <div class="container">
51.                                <div class="heACL">
52.                                        <table class="info3" cellpadding="0" cellspacing="0">
53.                                                <thead>
54.                                                        <th scope="col"><b>Owner</b></th>
55.                                                        <th scope="col"><b>Privileges</b></th>
56.                                                </thead>
57.                                                <tbody>'
58.                foreach ($itemACL in $directory.value.ACL) {
59.                        $acls = $null
60.                        if ($itemACL.AccessToString -ne $null) {
61.                                $acls = $itemACL.AccessToString.split("`n")
62.                        }
63.                        $dirHTML += '<tr><td>' + $itemACL.Owner + '</td>
64.                        <td>
65.                        <table>
66.                                <thead>
67.                                        <th>User</th>
68.                                        <th>Control</th>
69.                                        <th>Privilege</th>
70.                                </thead>
71.                                <tbody>'
72.                        foreach ($acl in $acls) {
73.                                $temp = [regex]::split($acl, "(?<!(,|NT))\s{1,}")
74.                                if ($debug) {
75.                                        write-host "ACL(" $temp.gettype().name ")[" $temp.length "]: " $temp
76.                                }
77.                                if ($temp.count -eq 1) {
78.                                        continue
79.                                }
80.                                if ($scope -ne 'administrator') {
81.                                        if ( Invoke-Expression $comparison ) {
82.                                                $dirHTML += "<tr><td>" + $temp[0] + "</td><td>" + $temp[1] + "</td><td>" + $temp[2] + "</td></tr>"
83.                                        }
84.                                } else {
85.                                        $dirHTML += "<tr><td>" + $temp[0] + "</td><td>" + $temp[1] + "</td><td>" + $temp[2] + "</td></tr>"
86.                                }
87.                        }
88.                        $dirHTML += '</tbody>
89.                                                </table>
90.                                                </td>
91.                                                </tr>'
92.                }
93.$dirHTML += '
94.                                                </tbody>
95.                                        </table>
96.                                </div>
97.                        </div>
98.                </div>'
99.        return $dirHTML
100.}
101. 
102.#endregion
103. 
104.#region Printing help message
105.if ($help) {
106.        Write-Host @"
107./··················································\
108.· Script gather access control lists per directory ·
109.\··················································/
110. 
111.USAGE: ./listACL -computer <machine or IP> 
112.                -path <path>
113.                -level <0-10>
114.                -help:[$false]
115.        
116.PARAMETERS:
117.        computer [OPTIONAL]     - Computer name or IP addres where folder is hosted (Default: localhost)
118.        path [REQUIRED]         - Folder's path to query.
119.        level [OPTIONAL]        - Level of folders to go down in the query. Allowd values are between 0 and $allowedLevels.
120.                                  0 show that there's no limit in the going down (Default: 0)
121.        scope [OPTIONAL]        - Sets the amount of information showd in the report. Allowd values are: 
122.                                 · user, show important information to the user.
123.                                 · micro, show user scope information plus important information for the IT Department.
124.                                 · administrator, show all information.
125.        help [OPTIONAL]         - This help.
126."@
127.        exit 0
128.        
129.}
130.#endregion
131. 
132.if (Test-Path $report)
133. {
134.  Remove-item $report
135. }
136. 
137.#To normalize I check if last character in the path is the folder separator character
138.if ($path.Substring($path.Length - 1,1) -eq "\") { $path = $path.Substring(0,$path.Length - 1) }
139. 
140.#region Header, style and javascript functions needed by the html report
141.@"
142.<html dir="ltr" xmlns:v="urn:schemas-microsoft-com:vml" gpmc_reportInitialized="false">
143.<head>
144.<meta http-equiv="Content-Type" content="text/html; charset=UTF-16" />
145.<title>Access Control List for $path in $computer</title>
146.<!-- Styles -->
147.<style type="text/css">
148.                body{ background-color:#FFFFFF; border:1px solid #666666; color:#000000; font-size:68%; font-family:MS Shell Dlg; margin:0px 0px 10px 0px; }
149. 
150.               table{ font-size:100%; table-layout:fixed; width:100%; }
151. 
152.               td,th{ overflow:visible; text-align:left; vertical-align:top; white-space:normal; }
153. 
154.               .title{ background:#FFFFFF; border:none; color:#333333; display:block; height:24px; margin:0px 0px -1px 0px; padding-top:4px; position:relative; table-layout:fixed; width:100%; z-index:5; }
155. 
156.               .he0_expanded{ background-color:#FEF7D6; border:1px solid #BBBBBB; color:#3333CC; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:0px; margin-right:0px; padding-left:8px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
157. 
158.               .he1_expanded{ background-color:#A0BACB; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:10px; margin-right:0px; padding-left:8px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
159. 
160.               .he1{ background-color:#A0BACB; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:10px; margin-right:0px; padding-left:8px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
161. 
162.               .he2{ background-color:#C0D2DE; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:20px; margin-right:0px; padding-left:8px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
163. 
164.               .he3{ background-color:#D9E3EA; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:30px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
165. 
166.               .he4{ background-color:#E8E8E8; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:40px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
167. 
168.               .he4h{ background-color:#E8E8E8; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:45px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
169. 
170.               .he4i{ background-color:#F9F9F9; border:1px solid #BBBBBB; color:#000000; display:block; font-family:MS Shell Dlg; font-size:100%; margin-bottom:-1px; margin-left:45px; margin-right:0px; padding-bottom:5px; padding-left:21px; padding-top:4px; position:relative; width:100%; }
171. 
172.               .he5{ background-color:#E8E8E8; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:50px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
173. 
174.               .he5h{ background-color:#E8E8E8; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; padding-left:11px; padding-right:5em; padding-top:4px; margin-bottom:-1px; margin-left:55px; margin-right:0px; position:relative; width:100%; }
175. 
176.               .he5i{ background-color:#F9F9F9; border:1px solid #BBBBBB; color:#000000; display:block; font-family:MS Shell Dlg; font-size:100%; margin-bottom:-1px; margin-left:55px; margin-right:0px; padding-left:21px; padding-bottom:5px; padding-top: 4px; position:relative; width:100%; }
177. 
178.               .he6{ background-color:#E8E8E8; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:55px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
179. 
180.                                .he7{ background-color:#E8E8E8; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:60px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
181.                                
182.                                .he8{ background-color:#E8E8E8; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:65px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
183.                                
184.                                .he9{ background-color:#E8E8E8; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:70px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
185.                                
186.                                .he10{ background-color:#E8E8E8; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:75px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
187.                                
188.                                .he11{ background-color:#E8E8E8; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:80px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
189.                                
190.                                .heACL { background-color:#ECFFD7; border:1px solid #BBBBBB; color:#000000; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:90px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
191.                                
192.                                DIV .expando{ color:#000000; text-decoration:none; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:normal; position:absolute; right:10px; text-decoration:underline; z-index: 0; }
193. 
194.               .he0 .expando{ font-size:100%; }
195. 
196.               .info, .info3, .info4, .disalign{ line-height:1.6em; padding:0px 0px 0px 0px; margin:0px 0px 0px 0px; }
197. 
198.               .disalign TD{ padding-bottom:5px; padding-right:10px; }
199. 
200.               .info TD{ padding-right:10px; width:50%; }
201. 
202.               .info3 TD{ padding-right:10px; width:33%; }
203. 
204.               .info4 TD, .info4 TH{ padding-right:10px; width:25%; }
205.                                
206.                                .info5 TD, .info5 TH{ padding-right:0px; width:20%; }
207. 
208.               .info TH, .info3 TH, .info4 TH, .disalign TH{ border-bottom:1px solid #CCCCCC; padding-right:10px; }
209. 
210.               .subtable, .subtable3{ border:1px solid #CCCCCC; margin-left:0px; background:#FFFFFF; margin-bottom:10px; }
211. 
212.               .subtable TD, .subtable3 TD{ padding-left:10px; padding-right:5px; padding-top:3px; padding-bottom:3px; line-height:1.1em; width:10%; }
213. 
214.               .subtable TH, .subtable3 TH{ border-bottom:1px solid #CCCCCC; font-weight:normal; padding-left:10px; line-height:1.6em;  }
215. 
216.               .subtable .footnote{ border-top:1px solid #CCCCCC; }
217. 
218.               .subtable3 .footnote, .subtable .footnote{ border-top:1px solid #CCCCCC; }
219. 
220.               .subtable_frame{ background:#D9E3EA; border:1px solid #CCCCCC; margin-bottom:10px; margin-left:15px; }
221. 
222.               .subtable_frame TD{ line-height:1.1em; padding-bottom:3px; padding-left:10px; padding-right:15px; padding-top:3px; }
223. 
224.               .subtable_frame TH{ border-bottom:1px solid #CCCCCC; font-weight:normal; padding-left:10px; line-height:1.6em; }
225. 
226.               .subtableInnerHead{ border-bottom:1px solid #CCCCCC; border-top:1px solid #CCCCCC; }
227. 
228.               .explainlink{ color:#000000; text-decoration:none; cursor:pointer; }
229. 
230.               .explainlink:hover{ color:#0000FF; text-decoration:underline; }
231. 
232.               .spacer{ background:transparent; border:1px solid #BBBBBB; color:#FFFFFF; display:block; font-family:MS Shell Dlg; font-size:100%; height:10px; margin-bottom:-1px; margin-left:43px; margin-right:0px; padding-top: 4px; position:relative; }
233. 
234.               .filler{ background:transparent; border:none; color:#FFFFFF; display:block; font:100% MS Shell Dlg; line-height:8px; margin-bottom:-1px; margin-left:43px; margin-right:0px; padding-top:4px; position:relative; }
235. 
236.               .container{ display:block; position:relative; }
237. 
238.               .rsopheader{ background-color:#A0BACB; border-bottom:1px solid black; color:#333333; font-family:MS Shell Dlg; font-size:130%; font-weight:bold; padding-bottom:5px; text-align:center; }
239. 
240.               .rsopname{ color:#333333; font-family:MS Shell Dlg; font-size:130%; font-weight:bold; padding-left:11px; }
241. 
242.               .gponame{ color:#333333; font-family:MS Shell Dlg; font-size:130%; font-weight:bold; padding-left:11px; }
243. 
244.               .gpotype{ color:#333333; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; padding-left:11px; }
245. 
246.               #uri    { color:#333333; font-family:MS Shell Dlg; font-size:100%; padding-left:11px; }
247. 
248.               #dtstamp{ color:#333333; font-family:MS Shell Dlg; font-size:100%; padding-left:11px; text-align:left; width:30%; }
249. 
250.               #objshowhide { color:#000000; cursor:pointer; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; margin-right:0px; padding-right:10px; text-align:right; text-decoration:underline; z-index:2; }
251. 
252.               #gposummary { display:block; }
253. 
254.               #gpoinformation { display:block; }
255. 
256.</style>
257.</head>
258.<body>
259.<table class="title" cellpadding="0" cellspacing="0">
260.<tr><td colspan="2" class="gponame">Access Control List for $path on machine $computer</td></tr>
261.<tr>
262.   <td id="dtstamp">Data obtained on: $(Get-Date)</td>
263.   <td><div id="objshowhide" tabindex="0"></div></td>
264.</tr>
265.</table>
266.<div class="filler"></div>
267."@ | Set-Content $report
268.#endregion
269. 
270.#region Information gathering
271.$colFiles = Get-ChildItem -path $UNCPath -Filter *. -Recurse -force -Verbose | Sort-Object FullName
272.$colACLs = @()
273.#We start going through the path pointed out by the user
274.foreach($file in $colFiles)
275.{
276.#To control the current level in the tree we are in it's needed to count the number of separator characters
277.#contained in the path. However in order to make the count correctly it's needed to delete the path 
278.#provided by the user (the parent). Once the parent has been deleted, the rest of the full name will be 
279.#string used to do the level count.
280.#It's needed to use a REGEX object to get ALL separator character matches.
281.$matches = (([regex]"\\").matches($file.FullName.substring($path.length, $file.FullName.length - $path.length))).count
282.if ($level -ne 0 -and ($matches - 1) -gt $level) {
283.        continue
284.}
285.if ($debug) {
286.        Write-Host $file.FullName "->" $file.Mode 
287.}
288.if ($file.Mode -notlike "d*") {
289.        continue
290.}
291.$myobj = "" | Select-Object Folder,ACL,level
292.$myobj.Folder = $file
293.$myobj.ACL = Get-Acl $file.FullName
294.$myobj.level = $matches - 1
295.$colACLs += $myobj
296.}
297.#endregion
298. 
299.#region Setting up the report
300.        '<div class="gposummary">' | Add-Content $report
301.        
302.        for ($i = 0; $i -lt $colACLs.count; $i++) {
303.                drawDirectory ([ref] $colACLs[$i]) | Add-Content $report
304.        }
305.        '</div></body></html>' | Add-Content $report
306.        
307.#endregion

