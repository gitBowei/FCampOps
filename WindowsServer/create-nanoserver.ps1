

$adminPass = ConvertTo-SecureString "Pa55word" -AsPlainText -Force
$NanoVHDPath = ".\NanoServerVM.vhd"

import-module D:\NanoBuild\NanoServerImageGenerator.psm1

New-NanoServerImage -MediaPath 'S:\OS Images\Windows Server 2016 RTM\Expanded' `
-BasePath .\Base -TargetPath $NanoVHDPath -ComputerName NanoVM `
-DeploymentType Guest -Edition Standard `
-Storage -Defender -EnableRemoteManagementPort `
-Package Microsoft-NanoServer-DSC-Package `
-UnattendPath .\unattend.xml `
-AdministratorPassword $adminPass -DomainName savilltech -ReuseDomainNode



New-NanoServerImage -Edition Standard -DeploymentType Guest -MediaPath <path to root of media> -BasePath .\Base -TargetPath .\NanoServerVM\NanoServerVM.vhd -ComputerName <computer name>

New-NanoServerImage -DeploymentType Guest `

                    -Edition Datacenter `

                    -MediaPath $path `

                    -BasePath .\Base `

                    -TargetPath $NanoVHDPath2 `

                    -MaxSize 10737418240 `

                    -ComputerName $Computername `

                    -Clustering `

                    -Package Microsoft-NanoServer-ShieldedVM-Package `

                    -Defender `

                    -EnableRemoteManagementPort `

                    -AdministratorPassword $SecurePassword

