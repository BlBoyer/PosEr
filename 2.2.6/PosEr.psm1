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
        [Alias("bgi")]
        [Parameter()]
        [string] $backgroundImage,
        [Alias("gbt")]
        [Parameter()]
        [float] $bgTransparency,
        [Alias("cs")]
        [Parameter()]
        [string] $colorScheme,
        [Alias("ff")]
        [Parameter()]
        [string] $fontFace,
        [Alias("fs")]
        [Parameter()]
        [int] $fontSize,
        [Alias("fw")]
        [Parameter()]
        [string] $fontWeight,
        [Alias("ty")]
        [Parameter()]
        [int] $transparency,
        [Alias("th")]
        [Parameter()]
        [string] $theme,
        [Parameter()]
        [switch] $h,
        [Parameter()]
        [switch] $r,
        [Parameter()]
        [switch] $nc
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

    <#if $r switch, replace all ungivens to loaded defaults, otherwise only use values in given array#>
    if($r){
        $host.UI.RawUI.ForegroundColor = 'Green'
        if(!$nc){
            $continue = Read-Host "Reset all other settings to defaults?(y/n)"
        } else {
            $continue ='y'
        }
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
        <#update the settings object#>
        .$PSScriptRoot/Set-Defaults
        if($backgroundImage -ne $PSDefaultParameterValues."Add-Settings:backgroundImage"){
            $SettingsObject.profiles.defaults.backgroundImage = $backgroundImage
            <#copy both and pt new img in folder#>
            $date = Get-Date -format 'MM-dd-yyyy_hhmmss'
            Copy-Item -Path $PSDefaultParameterValues."Add-Settings:backgroundImage" `
            -Destination "$env:PowerShellHome\Images\$date.jpg"
            Copy-Item -Path $backgroundImage `
            -Destination $PSDefaultParameterValues."Add-Settings:backgroundImage"
        }
        if($bgTransparency -ne $PSDefaultParameterValues."Add-Settings:bgTransparency"){
            $SettingsObject.profiles.defaults.backgroundImageOpacity = $bgTransparency}
        if($colorScheme -ne $PSDefaultParameterValues."Add-Settings:colorScheme"){
            $SettingsObject.profiles.defaults.colorScheme = $colorScheme}
        if($fontFace -ne $PSDefaultParameterValues."Add-Settings:fontFace"){
            $SettingsObject.profiles.defaults.font.face = $fontFace}
        if($fontSize -ne $PSDefaultParameterValues."Add-Settings:fontSize"){
            $SettingsObject.profiles.defaults.font.size = $fontSize}
        if($fontWeight -ne $PSDefaultParameterValues."Add-Settings:fontWeight"){
            $SettingsObject.profiles.defaults.font.weight = $fontWeight}
        if($transparency -ne $PSDefaultParameterValues."Add-Settings:transparency"){
            $SettingsObject.profiles.defaults.opacity = $transparency}
        if($theme -ne $PSDefaultParameterValues."Add-Settings:theme"){
            $SettingsObject.theme = $theme}
    }
    <#update default settings object file#>
    if($settingName -eq 'defaults'){
        $host.UI.RawUI.ForegroundColor = 'Green'
        if(!$nc){
            $continue = Read-Host "Your given values will overwrite your default values, continue?(y/n)"
        } else {
            $continue = 'y'
        }
        if ($continue -ieq "y"){
            $outputFile = $PSSettings
            $defaultParams = Get-Content -Path $PSScriptRoot\settings.psd1 
            <#mod object needs to change only defined values#>
            if($null -ne $bgTransparency){
                $defaultParams[2] = "`t'Add-Settings:bgTransparency'=$bgTransparency"}
            if($null -ne $colorScheme){
                $defaultParams[3] = "`t'Add-Settings:colorScheme'='$colorScheme'"}
            if($null -ne $fontFace){
                $defaultParams[4] = "`t'Add-Settings:fontFace'='$fontFace'"}
            if($null -ne $fontSize){
                $defaultParams[5] = "`t'Add-Settings:fontSize'=$fontSize"}
            if($null -ne $fontWeight){
                $defaultParams[6] = "`t'Add-Settings:fontWeight'='$fontWeight'"}
            if($null -ne $transparency){
                $defaultParams[7] = "`t'Add-Settings:transparency'=$transparency"}
            if($null -ne $theme){
                $defaultParams[8] = "`t'Add-Settings:theme'='$theme'"}
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
    param(
        [ValidateSet('presentation', 'local', 'defaults')]
        [Parameter(
            Mandatory=$true,
            HelpMessage="Allowed values: 'presentation', 'local', 'defaults"
        )]
        [string] $settingName,
        [Parameter()]
        [switch] $h
    )

    if($h){
        Get-Content "$PSScriptRoot\help\profiles-help.txt"
        return
    }
    if($settingName -eq 'defaults'){
        <#we should only do this, if the defaults aren't in the session, why don't we run the defaults script?#>
        <#$PSDefaultParameterValues = (Get-Variable -Name PSDefaultParameterValues -Scope 2).Value#>
        .$PSSCriptRoot/Set-Defaults
        return pps defaults -r -nc
        <#the grandparent scope never changes because a new instance isn't created after setting the values#>
        <#we just need to reset the session values or run set-defaults after the file has been written#>
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