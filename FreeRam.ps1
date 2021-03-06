1.function Get-FreeRam {
2.#.Synopsis
3.#  Gets the FreePhysicalMemory from the specified computer(s)
4.#.Parameter ComputerName
5.#  The name(s) of the computer(s) to get the Free Ram (FreePhysicalMemory) for.
6.#.Example
7.#   Get-FreeRam SDI-JBennett, Localhost
8.#
9.# Computer              FreePhysicalMemory
10.# --------              ------------------
11.# SDI-JBENNETT                     4180364
12.# SDI-JBENNETT                     4179764
13.[CmdletBinding()]
14.param(
15.  [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
16.  [string[]]$ComputerName='localhost'
17.)
18.process {
19.  Get-WmiObject -ComputerName $ComputerName Win32_OperatingSystem |
20.  Select-Object -Property @{name="Computer";expression={$_.__SERVER}}, FreePhysicalMemory
21.}
22.}

