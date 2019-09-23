#requires -version 2
      
function Connect-PSVUG
{

	$rs=[RunspaceFactory]::CreateRunspace()
	$rs.ApartmentState = "STA"
	$rs.ThreadOptions = "ReuseThread"
	$rs.Open()
	$ps = [PowerShell]::Create()
	$ps.Runspace = $rs
	
	$null = $ps.AddScript({
	
		Add-Type -AssemblyName PresentationFramework

		$window = New-Object Windows.Window
		$window.Title = 'PowerShell Freenode IRC channel'
		$window.WindowStartupLocation = 'CenterScreen'

		$wb = New-Object Windows.Controls.WebBrowser
		$wb.Source='http://webchat.freenode.net/?channels=powershell'

		$grid = New-Object Windows.Controls.Grid
		$grid.Children.Add($wb)
		$window.Content = $grid 

		$window.Add_Loaded({	
			$window.Activate()		
		})

		$window.Add_KeyUp({
			if($_.Key -eq 'T' -AND [Windows.Input.ModifierKeys]::Alt)
			{
				$window.Topmost=!$window.Topmost
			}
		})

		$null = $window.ShowDialog()

	}).BeginInvoke()
}