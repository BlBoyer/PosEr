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

    Copy-Item -Path "$PSScriptRoot\img\background.png" -Destination "$env:PowerShellHome\Images\background.jpg"
}
    <#mod validatee set to default paremter with |options|#>
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
        [switch] $h,
        [Parameter()]
        [switch] $r
    )
    
    if($h){
        Get-Content "$PSScriptRoot\help\settings-help.txt" 
        return
    }
    if($null -eq $env:PowerShellHome){
        Set-Environment
    }

    $PSSettings = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_$env:PowerShellVersion\LocalState\settings.json"

    $SettingsObject = Get-Content -Raw $PSSettings | ConvertFrom-Json

    <#if $r switch, replace all ungivens to defaults, otherwise only use values in given array#>
    <#we can check against defaults#>
    if($r){
        $continue = Read-Host "Reset all other settings to defaults?(y/n)"
        if($continue -ieq 'y'){
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
        } else {
            return
        }
    } else {
        $defaultParameterValues = (Get-Variable -Name PSDefaultParameterValues -Scope 2).Value
        <#just update the object where val isn't default, duh#>
        if($backgroundImage -ne $defaultParameterValues."Add-Settings:backgroundImage"){
        $SettingsObject.profiles.defaults.backgroundImage = $backgroundImage}
        if($bgTransparency -ne $defaultParameterValues."Add-Settings:bgTransparency"){
            $SettingsObject.profiles.defaults.backgroundImageOpacity = $bgTransparency}
        if($colorScheme -ne $defaultParameterValues."Add-Settings:colorScheme"){
            $SettingsObject.profiles.defaults.colorScheme = $colorScheme}
        if($fontFace -ne $defaultParameterValues."Add-Settings:fontFace"){
            $SettingsObject.profiles.defaults.font.face = $fontFace}
        if($fontSize -ne $defaultParameterValues."Add-Settings:fontSize"){
            $SettingsObject.profiles.defaults.font.size = $fontSize}
        if($fontWeight -ne $defaultParameterValues."Add-Settings:fontWeight"){
            $SettingsObject.profiles.defaults.font.weight = $fontWeight}
        if($transparency -ne $defaultParameterValues."Add-Settings:transparency"){
            $SettingsObject.profiles.defaults.opacity = $transparency}
        if($theme -ne $defaultParameterValues."Add-Settings:theme"){
            $SettingsObject.theme = $theme}
    }

    if($settingName -eq 'defaults'){
        $continue = Read-Host "Your given values will overwrite your default values, continue?(y/n)"
        if ($continue -ieq "y"){
            $outputFile = $PSSettings
            $defaultParams = Get-Content -Path $PSScriptRoot\settings.psd1 
            <#mod object needs to change only defined values#>
            if($null -ne $bgTransparency){
                $defaultParams[2] = "'Add-Settings:bgTransparency'=$bgTransparency"}
            if($null -ne $colorScheme){
                $defaultParams[3] = "'Add-Settings:colorScheme'='$colorScheme'"}
            if($null -ne $fontFace){
                $defaultParams[4] = "'Add-Settings:fontFace'='$fontFace'"}
            if($null -ne $fontSize){
                $defaultParams[5] = "'Add-Settings:fontSize'=$fontSize"}
            if($null -ne $fontWeight){
                $defaultParams[6] = "'Add-Settings:fontWeight'='$fontWeight'"}
            if($null -ne $transparency){
                $defaultParams[7] = "'Add-Settings:transparency'=$transparency"}
            if($null -ne $theme){
                $defaultParams[8] = "'Add-Settings:theme'='$theme'"}
            $defaultParams | Set-Content -Path $PSScriptRoot\settings.psd1 -Force
        } else {
            return
        }
    } else {
        $outputFile = "$env:PowerShellHome\Settings\$settingName.json" 
    }

    <# necessary Depth level 3, this is subject to change if the powershell settings file obtains further nested values #>
    $SettingsObject | ConvertTo-Json -Depth 100 | Set-Content $outputFile
    
    if($settingName -ne 'defaults'){
        Switch-Profile($settingName)
    }
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
    Copy-Item -Path "$env:PowerShellHome\Settings\$settingName.json" `
     -Destination "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_$env:PowerShellVersion\LocalState\settings.json" `
     -ErrorAction SilentlyContinue -ErrorVariable noCopy
    if($noCopy){
        Write-Host `n "No saved profile settings for this option found." `n -ForegroundColor Magenta
    }
} 

New-Alias -Name chp  -Value Switch-Profile -Description 'Change between profiles.'
New-Alias -Name pps -Value Add-Settings -Description 'Modify settings for profiles.'
Export-ModuleMember -Function * -Alias *