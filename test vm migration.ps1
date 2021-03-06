$vv = get-vm testsql17b | get-view
$si = Get-View ServiceInstance -Server $global:DefaultVIServers[1]
$hs = get-vmhost infesx52*
$hv = $hs | Get-View
$pool = $vv.ResourcePool
$vmMoRef = $vv.MoRef
$hsMoRef = $hv.MoRef
$si = Get-View ServiceInstance -Server $global:DefaultVIServers[1] # this turned out to be futile, later line returns multi objects anyway...
$VmProvCheck = get-view $si.Content.VmProvisioningChecker # don't know why it grabbed multiple objs, one for each vCenter
$RavVmProvCheck = $VmProvCheck[0] # This is the object we need for the VC instance in question
$results = $RavVmProvCheck.CheckMigrate( $vmMoRef, $hsMoRef, $pool, $null, $null )

