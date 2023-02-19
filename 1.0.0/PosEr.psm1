<#Setup Environment Variables and dir structure if it doesn't exist#>
<#
.SYNOPSIS
This module contains three functions to allow you to easily create and switch between Powershell profile settings.
It uses the default settings for Powershell and modifies them accordingly, instead of creating multiple profiles.
It can easily be adapted to create multiple profiles, or modify other profile settings as well.
#>
function Set-Environment {
    param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = "Must be a valid directory, default is USERPROFILE\Documents\WindowsPowerShell"
        )]
        [string] $PowerShellProfilePath,
        [Parameter()]
        [switch] $h
    )

    if($h){
        Get-Content "$PSScriptRoot\help\environment-help.txt"
        return
    }
    if($null -eq $PowerShellProfilePath){
        $PowerShellProfilePath = '$env:USERPROFILE\Documents\WindowsPowerShell'
    }
    $pkgId = Get-AppPackage Microsoft.WindowsTerminal | Select-Object -ExpandProperty PublisherId

    [System.Environment]::SetEnvironmentVariable('PowerShellHome','$PowerShellProfilePath',[System.EnvironmentVariableTarget]::User)
    [System.Environment]::SetEnvironmentVariable('PowerShellScripts','$PowerShellProfilePath\Scripts',[System.EnvironmentVariableTarget]::User)
    [System.Environment]::SetEnvironmentVariable('PowerShellPrompts','$PowerShellProfilePath\Prompts',[System.EnvironmentVariableTarget]::User)
    [System.Environment]::SetEnvironmentVariable('PowerShellVersion',$pkgId,[System.EnvironmentVariableTarget]::User)
    <#Directories#>
    mkdir -p $env:PowerShellScripts
    mkdir -p $env:PowerShellPrompts
    mkdir -p $env:PowerShellHome'\Images'
    mkdir -p $env:PowerShellHome'\Settings'
}
    
function Add-Settings {
    param(
        [ValidateSet('presentation', 'local', 'defaults')]
        [Parameter(
            Mandatory=$true,
            HelpMessage="Allowed values: 'presentation', 'local', 'defaults'"
        )]
        [string] $settingName,
        [Parameter()]
        [string] $backgroundImage,
        [Parameter()]
        [float] $bgTransparency,
        [Parameter()]
        [string] $colorScheme,
        [Parameter()]
        [string] $fontFace,
        [Parameter()]
        [int] $fontSize,
        [Parameter()]
        [string] $fontWeight,
        [Parameter()]
        [int] $transparency,
        [Parameter()]
        [string] $theme,
        [Parameter()]
        [switch] $h
    )
    
    if($h){
        Get-Content "$PSScriptRoot\help\settings-help.txt" 
        return
    }
    if($null -eq $env:PowerShellHome){
        Set-Environment
    }
    if($null -or '' -eq $backgroundImage){
        $backgroundImage = $env:PowerShellHome+'\Images\background.jpg'
    }
    if($null -or 0 -eq $bgTransparency){
        $bgTransparency = 0.7
    }
    if($null -or '' -eq $colorScheme){
        $colorScheme = 'Vintage'
    }
    if($null -or '' -eq $fontFace){
        $fontFace = 'ShureTechMono NF'
    }
    if($null -or 0 -eq $fontSize){
        $fontSIze = 13
    }
    if($null -or '' -eq $fontWeight){
        $fontWeight = 'medium'
    }
    if($null -or 0 -eq $transparency){
        $transparency = 80
    }
    if($null -or '' -eq $theme){
        $theme = 'dark'
    }

    $PSSettings = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_$env:PowerShellVersion\LocalState\settings.json"

    $SettingsObject = Get-Content -Raw $PSSettings | ConvertFrom-Json

    $SettingsObject.profiles.defaults = [PSCustomObject]@{
        backgroundImage =  $backgroundImage
        backgroundImageOpacity =  $bgTransparency
        colorScheme = $colorScheme
        font =  [PSCustomObject]@{
            face =  $fontFace
            size = $fontSize
            weight = $fontWeight
        }
        opacity = $transparency
    }
    $SettingsObject.theme = $theme

    if($settingName -eq 'defaults'){
        $outputFile = $PSSettings
    } else {
        $outputFile = "$env:PowerShellHome\Settings\$settingName.json" 
    }

    <# necessary Depth level 3, this is subject to change if the powershell settings file obtains further nested values #>
    $SettingsObject | ConvertTo-Json -Depth 100 | Set-Content $outputFile
}

function Switch-Profile {
    <#Get content from setting path, set content to settings path#>
    param(
        [ValidateSet('presentation', 'local')]
        [Parameter(
            Mandatory=$true,
            HelpMessage="Allowed values: 'presentation', 'local'"
        )]
        [string] $settingName,
        [Parameter()]
        [switch] $h
    )

    if($h){
        Get-Content "$PSScriptRoot\help\profiles-help.txt"
        return
    }
    Copy-Item -Path "$env:PowerShellHome\Settings\$ps.json" -Destination "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_$env:PowerShellVersion\LocalState\settings.json"
}
New-Alias -Name chp  -Value Switch-Profile -Description 'Change between profiles.'
New-Alias -Name pps -Value Add-Settings -Description 'Modify settings for profiles.'
Export-ModuleMember -Function * -Alias *