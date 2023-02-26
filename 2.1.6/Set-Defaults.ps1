$defaultsHashTable = Import-PowerShellDataFile -Path "$PSScriptRoot\settings.psd1"
$PSDefaultParameterValues = $defaultsHashTable
<#cannot import objects with dynamic variables, should set this the Add-Settings script#>
$PSDefaultParameterValues.Add("Add-Settings:backgroundImage", "$PSScriptRoot\img\background.jpg")
<#reset if environment has been set#>
$PSDefaultParameterValues["Add-Settings:backgroundImage"] = "$env:PowerShellHome\Images\background.jpg"
write-host $PSDefaultParameterValues."Add-Settings:opacity"