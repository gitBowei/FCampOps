# Enable Routing and Remote Access
RegEdit.exe /s "C:\Contoso Configuration Scripts\EnableRAS.reg"
RegEdit.exe /s "C:\Contoso Configuration Scripts\EnableIncomingConnections.reg"

# Add Remote Access Server to Active Directory
netsh.exe ras add registeredserver

# Configure the Remote Access Server VPN component
netsh.exe ras set authmode mode = standard
netsh.exe ras delete authtype type = PAP
netsh.exe ras delete authtype type = MD5CHAP
netsh.exe ras delete authtype type = MSCHAPv2
netsh.exe ras delete authtype type = EAP
netsh.exe ras delete authtype type = CERT
netsh.exe ras add authtype type = MSCHAPv2
netsh.exe ras add authtype type = EAP
netsh.exe ras delete link type = SWC
netsh.exe ras delete link type = LCP
netsh.exe ras add link type = SWC
netsh.exe ras add link type = LCP
netsh.exe ras delete multilink type = MULTI
netsh.exe ras add multilink type = MULTI
netsh.exe ras set conf confstate = enabled
netsh.exe ras set type ipv4rtrtype = lananddd ipv6rtrtype = none rastype = ipv4
netsh.exe ras set wanports device = "WAN Miniport (SSTP)" rasinonly = enabled ddinout = disabled ddoutonly = disabled maxports = 128 
netsh.exe ras set wanports device = "WAN Miniport (IKEv2)" rasinonly = enabled ddinout = enabled ddoutonly = disabled maxports = 128 
netsh.exe ras set wanports device = "WAN Miniport (PPTP)" rasinonly = enabled ddinout = enabled ddoutonly = disabled maxports = 128 
netsh.exe ras set wanports device = "WAN Miniport (L2TP)" rasinonly = enabled ddinout = enabled ddoutonly = disabled maxports = 128 
netsh.exe ras set wanports device = "WAN Miniport (PPPOE)" ddoutonly = enabled

netsh.exe ras set user name = Administrator dialin = policy cbpolicy = none 
netsh.exe ras set user name = Guest dialin = policy cbpolicy = none 

netsh.exe ras set ikev2connection idletimeout = 5 nwoutagetime = 30
netsh.exe ras set ikev2saexpiry saexpirytime = 480 sadatasizelimit = 32767

# Configure RAS diagnostics component
netsh.exe ras diagnostics set rastracing component = * state = disabled
netsh.exe ras diagnostics set modemtracing state = disabled
netsh.exe ras diagnostics set cmtracing state = disabled
netsh.exe ras diagnostics set securityeventlog state = disabled
netsh.exe ras diagnostics set loglevel events = warn
 
# Configure Remote Access IPv4 component
netsh.exe ras ip delete pool
netsh.exe ras ip set negotiation mode = allow
netsh.exe ras ip set access mode = all
netsh.exe ras ip set addrreq mode = deny
netsh.exe ras ip set broadcastnameresolution mode = enabled
netsh.exe ras ip set addrassign method = auto
netsh.exe ras ip set preferredadapter name = "Contoso Network"

# Configure Remote Access IPv6 component
netsh.exe ras ipv6 set negotiation mode = deny
netsh.exe ras ipv6 set access mode = all
netsh.exe ras ipv6 set routeradvertise mode = enabled
netsh.exe ras ipv6 set prefix prefix = ::

# Configure Remote Access AAAA component
netsh.exe ras aaaa set authentication provider = windows
netsh.exe ras aaaa set accounting provider = windows
netsh.exe ras aaaa delete authserver name = *
netsh.exe ras aaaa delete acctserver name = *

# Enable Windows Firewall rules for VPN connections
netsh.exe advfirewall firewall set rule name = "Routing and Remote Access (GRE-In)"  new enable=yes
netsh.exe advfirewall firewall set rule name = "Routing and Remote Access (L2TP-In)" new enable=yes
netsh.exe advfirewall firewall set rule name = "Routing and Remote Access (PPTP-In)" new enable=yes

# Change the Routing and Remote Access service startup type
Set-Service -Name "RemoteAccess" -StartupType "Automatic"

# Retstart the Routing and Remote Access service
Restart-Service -Name "RemoteAccess"

# Import the Network Policy and Access Services configuration

netsh.exe nps import filename="C:\DemoContent\NPS_Configuration.xml"

# Retstart the Routing and Remote Access service
Restart-Service -Name "RemoteAccess"
