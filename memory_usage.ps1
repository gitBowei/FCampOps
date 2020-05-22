
# * * * * * * * * * * * * Physical Memory Usage: Top 5 Processes* * * * * * * * * * * * * * * * * * * * * * * * 

		[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")

		$scriptpath = Split-Path -parent $MyInvocation.MyCommand.Definition

		#frame

		   $MemoryUsageChart1 = New-object System.Windows.Forms.DataVisualization.Charting.Chart

		   $MemoryUsageChart1.Width = 800

		   $MemoryUsageChart1.Height = 400

		   $MemoryUsageChart1.BackColor = [System.Drawing.Color]::White
		 
		#header 

		   [void]$MemoryUsageChart1.Titles.Add("Physical Memory Usage: Top 5 Processes")

		   $MemoryUsageChart1.Titles[0].Font = "segoeuilight,20pt"

		   $MemoryUsageChart1.Titles[0].Alignment = "topLeft"
		 
		   $chartarea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea

		   $chartarea.Name = "ChartArea1"
		   
		   $MemoryUsageChart1.ChartAreas.Add($chartarea)
			  
			[void]$MemoryUsageChart1.Series.Add("data1")
		   
		   $MemoryUsageChart1.Series["data1"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Pie

			$Processes = Get-Process | Sort-Object -Property WS | Select-Object Name,PM,VM -Last 5
			$ProcessList = @(foreach($Proc in $Processes){$Proc.Name + "`n"+[math]::floor($Proc.PM/1MB)})
			$Placeholder = @(foreach($Proc in $Processes){$Proc.PM})

			$MemoryUsageChart1.Series["data1"].Points.DataBindXY($ProcessList, $Placeholder)
		 
		   $MemoryUsageChart1.SaveImage("z:\Physical_Memory_Usage.png","png")
   
# * * * * * * * * * * * * Virtual Memory Usage: Top 5 Processes* * * * * * * * * * * * * * * * * * * * * * * * 
   
		[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")

		$scriptpath = Split-Path -parent $MyInvocation.MyCommand.Definition

		#frame

		   $MemoryUsageChart2 = New-object System.Windows.Forms.DataVisualization.Charting.Chart

		   $MemoryUsageChart2.Width = 800

		   $MemoryUsageChart2.Height = 400

		   $MemoryUsageChart2.BackColor = [System.Drawing.Color]::White
		 
		#header 

		   [void]$MemoryUsageChart2.Titles.Add("Virtual Memory Usage: Top 5 Processes")

		   $MemoryUsageChart2.Titles[0].Font = "segoeuilight,20pt"

		   $MemoryUsageChart2.Titles[0].Alignment = "topLeft"
		 
		   $chartarea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea

		   $chartarea.Name = "ChartArea1"
		   
		   $MemoryUsageChart2.ChartAreas.Add($chartarea)
			  
			[void]$MemoryUsageChart2.Series.Add("data2")
		   
		   $MemoryUsageChart2.Series["data2"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Pie

			$Processes = Get-Process | Sort-Object -Property WS | Select-Object Name,PM,VM -Last 5
			$ProcessList = @(foreach($Proc in $Processes){$Proc.Name + "`n"+[math]::floor($Proc.VM/1MB)})
			$Placeholder = @(foreach($Proc in $Processes){$Proc.VM})

			$MemoryUsageChart2.Series["data2"].Points.DataBindXY($ProcessList, $Placeholder)
		 
		   $MemoryUsageChart2.SaveImage("z:\Virtual_Memory_Usage.png","png")