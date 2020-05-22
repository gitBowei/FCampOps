﻿#Generated Form Function
function GenerateForm {
########################################################################
# Code Generated By: SAPIEN Technologies PrimalForms (Community Edition) v1.0.10.0
# Version History: 1.1 - 18/07/2012
# Generated By: Stefan van der Zyl, BITMARCK Technik GmbH
# Description: 
# This script searches the MessageTrackingLog of all HUB Server in your Organization at one time.
# You have to enter valid SMTP Addresses, if you are looking for a special Mail, or leave the default entry to search the whole TrackingLog.
# Requires: PowerShell V2, Exchange 2010 Management Shell
########################################################################

#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
#endregion

#region Generated Form Objects
$form1 = New-Object System.Windows.Forms.Form
$checkBox1 = New-Object System.Windows.Forms.CheckBox
$label3 = New-Object System.Windows.Forms.Label
$comboBox1 = New-Object System.Windows.Forms.ComboBox
$label2 = New-Object System.Windows.Forms.Label
$label1 = New-Object System.Windows.Forms.Label
$dataGrid1 = New-Object System.Windows.Forms.DataGrid
$dateTimePicker2 = New-Object System.Windows.Forms.DateTimePicker
$dateTimePicker1 = New-Object System.Windows.Forms.DateTimePicker
$textBox2 = New-Object System.Windows.Forms.TextBox
$textBox1 = New-Object System.Windows.Forms.TextBox
$button1 = New-Object System.Windows.Forms.Button
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
#endregion Generated Form Objects

#----------------------------------------------
#Generated Event Script Blocks
#----------------------------------------------
#Provide Custom Code for events specified in PrimalForms.

$processData= 
{
#TODO: Place custom script here
	
	#This section determine the date and puts it in a working format
	$array = New-Object System.Collections.ArrayList
	$date1 = get-Date -date $dateTimePicker1.value -uformat "%m/%d/%Y 00:00:01"
	$date3 = [System.DateTime]$date1
	$date2 = get-Date -date $dateTimePicker2.value -uformat "%m/%d/%Y 23:59:59"  
	$date4 = [System.DateTime]$date2
		
	if ($Choice -eq "BADMAIL" -or $Choice -eq "DEFER" -or $Choice -eq "DELIVER" -or $Choice -eq "SEND" -or $Choice -eq "DSN" -or $Choice -eq "FAIL" -or $Choice -eq "POISONMESSAGE" -or $Choice -eq "RECEIVE" -or $Choice -eq "REDIRECT" -or $Choice -eq "RESOLVE" -or $Choice -eq "SUBMIT" -or $Choice -eq "TRANSFER" -or $Choice -eq "EXPAND")
		{
			$Event = "$choice"
		}
	else
		{
			$Event = ""
		}
		
	#This section runs the Exchange CMDLET, you can choose, whether you fill the fields with valid SMTP Addresses or leave the fileds blank or with default entry
	if ( $Event -ne "")
	{	
		if (($textBox2.text -eq "" -or $textBox2.text -eq "Recipients_MailAddress") -and ($textBox1.text -eq "" -or $textBox1.text -eq "Senders_MailAddress" ))
		{
			$ausgabe = Get-TransportServer  | Get-MessageTrackingLog -start $date3 -end $date4 -EventID $Event -resultsize unlimited | Select-object Timestamp, EventID, serverhostname, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject | sort $sort
		}
		elseif ($textBox2.text -eq "" -or $textBox2.text -eq "Recipients_MailAddress")
		{
			$ausgabe = Get-TransportServer  | Get-MessageTrackingLog -sender $textbox1.text -start $date3 -end $date4 -EventID $Event -resultsize unlimited | Select-object Timestamp, EventID, serverhostname, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject | sort $sort	
		}
		elseif ($textBox1.text -eq "" -or $textBox1.text -eq "Senders_MailAddress")
		{
			$ausgabe = Get-TransportServer  | Get-MessageTrackingLog -Recipients $textbox2.text -start $date3 -end $date4 -EventID $Event -resultsize unlimited | Select-object Timestamp, EventID, serverhostname, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject | sort $sort
		} 
		elseif ($textBox2.text -ne "" -or $textBox2.text -ne "Recipients_MailAddress" -and $textBox1.text -ne "" -or $textBox1.text -ne "Senders_MailAddress" )
		{
			$ausgabe = Get-TransportServer  | Get-MessageTrackingLog -Recipients $textbox2.text -sender $textbox1.text -start $date3 -end $date4 -EventID $Event -resultsize unlimited | Select-object Timestamp, EventID, serverhostname, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject | sort $sort
		}
	}
	else
	{	
		if(($textBox2.text -eq "" -or $textBox2.text -eq "Recipients_MailAddress") -and ($textBox1.text -eq "" -or $textBox1.text -eq "Senders_MailAddress"))
		{
			$ausgabe = Get-TransportServer  | Get-MessageTrackingLog -start $date3 -end $date4 -resultsize unlimited | Select-object Timestamp, EventID, serverhostname, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject | sort $sort
		}
		elseif ($textBox2.text -eq "" -or $textBox2.text -eq "Recipients_MailAddress")
		{
			$ausgabe = Get-TransportServer  | Get-MessageTrackingLog -sender $textbox1.text -start $date3 -end $date4 -resultsize unlimited | Select-object Timestamp, EventID, serverhostname, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject | sort $sort	
		}
		elseif ($textBox1.text -eq "" -or $textBox1.text -eq "Senders_MailAddress")
		{
			$ausgabe = Get-TransportServer  | Get-MessageTrackingLog -Recipients $textbox2.text -start $date3 -end $date4 -resultsize unlimited | Select-object Timestamp, EventID, serverhostname, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject | sort $sort
		} 
		elseif ($textBox2.text -ne "" -or $textBox2.text -ne "Recipients_MailAddress" -and $textBox1.text -ne "" -or $textBox1.text -ne "Senders_MailAddress" )
		{
			$ausgabe = Get-TransportServer  | Get-MessageTrackingLog -Recipients $textbox2.text -sender $textbox1.text -start $date3 -end $date4 -resultsize unlimited | Select-object Timestamp, EventID, serverhostname, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject | sort $sort
		}
	}
	$array.addrange($ausgabe)
	$dataGrid1.datasource = $array
	$form1.refresh()
}

$handler_checkBox1_CheckedChanged=
{
#TODO: Place custom script here

}

$handler_label3_Click= 
{
#TODO: Place custom script here

}

$handler_textBox1_TextChanged= 
{
#TODO: Place custom script here

}

$handler_label1_Click= 
{
#TODO: Place custom script here

}

$handler_dataGrid1_Navigate= 
{
#TODO: Place custom script here

}

$handler_comboBox1_SelectedIndexChanged= 
{
#TODO: Place custom script here
	$Choice = $comboBox1.selectedItem.ToString()
}

$handler_form1_Load= 
{
#TODO: Place custom script here

}

$OnLoadForm_StateCorrection=
{#Correct the initial state of the form to prevent the .Net maximized form issue
	$form1.WindowState = $InitialFormWindowState
}

#----------------------------------------------
#region Generated Form Code
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 853
$System_Drawing_Size.Width = 1288
$form1.ClientSize = $System_Drawing_Size
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$form1.ForeColor = [System.Drawing.Color]::FromArgb(255,0,0,0)
$form1.Name = "form1"
$form1.Text = "MessageTracking"
$form1.add_Load($handler_form1_Load)

$label3.DataBindings.DefaultDataSourceUpdateMode = 0
$label3.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",11.25,0,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 783
$System_Drawing_Point.Y = 28
$label3.Location = $System_Drawing_Point
$label3.Name = "label3"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 70
$label3.Size = $System_Drawing_Size
$label3.TabIndex = 18
$label3.Text = "EventID"
$label3.add_Click($handler_label3_Click)

$form1.Controls.Add($label3)

$comboBox1.DataBindings.DefaultDataSourceUpdateMode = 0
$comboBox1.FormattingEnabled = $True
$comboBox1.Items.Add("")|Out-Null
$comboBox1.Items.Add("SEND")|Out-Null
$comboBox1.Items.Add("DELIVER")|Out-Null
$comboBox1.Items.Add("RECEIVE")|Out-Null
$comboBox1.Items.Add("FAIL")|Out-Null
$comboBox1.Items.Add("DSN")|Out-Null
$comboBox1.Items.Add("RESOLVE")|Out-Null
$comboBox1.Items.Add("EXPAND")|Out-Null
$comboBox1.Items.Add("REDIRECT")|Out-Null
$comboBox1.Items.Add("TRANSFER")|Out-Null
$comboBox1.Items.Add("SUBMIT")|Out-Null
$comboBox1.Items.Add("POISONMESSAGE")|Out-Null
$comboBox1.Items.Add("DEFER")|Out-Null
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 859
$System_Drawing_Point.Y = 27
$comboBox1.Location = $System_Drawing_Point
$comboBox1.Name = "comboBox1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 21
$System_Drawing_Size.Width = 121
$comboBox1.Size = $System_Drawing_Size
$comboBox1.TabIndex = 17
$comboBox1.add_SelectedIndexChanged($handler_comboBox1_SelectedIndexChanged)

$form1.Controls.Add($comboBox1)

$label2.DataBindings.DefaultDataSourceUpdateMode = 0
$label2.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",11.25,0,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 480
$System_Drawing_Point.Y = 53
$label2.Location = $System_Drawing_Point
$label2.Name = "label2"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 54
$label2.Size = $System_Drawing_Size
$label2.TabIndex = 12
$label2.Text = "Ende"

$form1.Controls.Add($label2)

$label1.DataBindings.DefaultDataSourceUpdateMode = 0
$label1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",11.25,0,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 480
$System_Drawing_Point.Y = 25
$label1.Location = $System_Drawing_Point
$label1.Name = "label1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 54
$label1.Size = $System_Drawing_Size
$label1.TabIndex = 11
$label1.Text = "Start"
$label1.add_Click($handler_label1_Click)

$form1.Controls.Add($label1)

$dataGrid1.AllowSorting = $true
$dataGrid1.Anchor = 15
$dataGrid1.DataBindings.DefaultDataSourceUpdateMode = 0
$dataGrid1.DataMember = ""
$dataGrid1.HeaderForeColor = [System.Drawing.Color]::FromArgb(255,0,0,0)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 9
$System_Drawing_Point.Y = 108
$dataGrid1.Location = $System_Drawing_Point
$dataGrid1.Name = "dataGrid1"
$dataGrid1.PreferredColumnWidth = 250
$dataGrid1.ReadOnly = $True
$dataGrid1.RowHeaderWidth = 60
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 733
$System_Drawing_Size.Width = 1267
$dataGrid1.Size = $System_Drawing_Size
$dataGrid1.TabIndex = 9
$dataGrid1.add_Navigate($handler_dataGrid1_Navigate)

$form1.Controls.Add($dataGrid1)

$dateTimePicker2.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 540
$System_Drawing_Point.Y = 53
$dateTimePicker2.Location = $System_Drawing_Point
$dateTimePicker2.Name = "dateTimePicker2"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 200
$dateTimePicker2.Size = $System_Drawing_Size
$dateTimePicker2.TabIndex = 8

$form1.Controls.Add($dateTimePicker2)

$dateTimePicker1.CustomFormat = "MM/DD/YYYY 00:00:01"
$dateTimePicker1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 540
$System_Drawing_Point.Y = 26
$dateTimePicker1.Location = $System_Drawing_Point
$dateTimePicker1.Name = "dateTimePicker1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 200
$dateTimePicker1.Size = $System_Drawing_Size
$dateTimePicker1.TabIndex = 7

$form1.Controls.Add($dateTimePicker1)

$textBox2.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 30
$System_Drawing_Point.Y = 60
$textBox2.Location = $System_Drawing_Point
$textBox2.Name = "textBox2"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 433
$textBox2.Size = $System_Drawing_Size
$textBox2.TabIndex = 4
$textBox2.Text = "Recipients_MailAddress"

$form1.Controls.Add($textBox2)

$textBox1.DataBindings.DefaultDataSourceUpdateMode = 0
$textBox1.ForeColor = [System.Drawing.Color]::FromArgb(255,0,0,0)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 30
$System_Drawing_Point.Y = 25
$textBox1.Location = $System_Drawing_Point
$textBox1.Name = "textBox1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 434
$textBox1.Size = $System_Drawing_Size
$textBox1.TabIndex = 3
$textBox1.Text = "Senders_MailAddress"
$textBox1.add_TextChanged($handler_textBox1_TextChanged)

$form1.Controls.Add($textBox1)


$button1.DataBindings.DefaultDataSourceUpdateMode = 0
$button1.ForeColor = [System.Drawing.Color]::FromArgb(255,0,0,0)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 859
$System_Drawing_Point.Y = 55
$button1.Location = $System_Drawing_Point
$button1.Name = "button1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 28
$System_Drawing_Size.Width = 83
$button1.Size = $System_Drawing_Size
$button1.TabIndex = 1
$button1.Text = "GO!"
$button1.UseVisualStyleBackColor = $True
$button1.add_Click($processData)

$form1.Controls.Add($button1)

#endregion Generated Form Code

#Save the initial state of the form
$InitialFormWindowState = $form1.WindowState
#Init the OnLoad event to correct the initial state of the form
$form1.add_Load($OnLoadForm_StateCorrection)
#Show the Form
$form1.ShowDialog()| Out-Null

} #End Function

#Call the Function
GenerateForm