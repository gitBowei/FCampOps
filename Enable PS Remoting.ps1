1.#Run winrm quickconfig defaults
2.echo Y | winrm quickconfig
3. 
4.#Run enable psremoting command with defaults
5.enable-psremoting -force
6. 
7.#Enabled Trusted Hosts for Universial Access
8.cd wsman:
9.cd localhost\client
10.Set-Item TrustedHosts * -force
11.restart-Service winrm
12.echo "Complete"
