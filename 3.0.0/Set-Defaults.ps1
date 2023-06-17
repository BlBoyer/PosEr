$defaultsHashTable = Import-PowerShellDataFile -Path "$PSScriptRoot\settings.psd1"
if(Test-Path "$env:PowerShellHome\Settings\settings.psd1"){
    $defaultsHashTable = Import-PowerShellDataFile -Path "$env:PowerShellHome\Settings\settings.psd1"
}
$PRDefaultParameterValues = $defaultsHashTable
<#cannot import objects with dynamic variables, should set this the Add-Settings script#>
$PRDefaultParameterValues.Add("Add-Settings:backgroundImage", "$PSScriptRoot\img\background.jpg")
<#reset if environment has been set#>
$PRDefaultParameterValues["Add-Settings:backgroundImage"] = "$env:PowerShellHome\Images\background.jpg"

$PRDefaultParameterValues.Add("Add-Settings:tabTitle", "$env:Username - devConsole")