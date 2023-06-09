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
    if(!$PSBoundParameters.ContainsKey('PowerShellProfilePath') -eq $PowerShellProfilePath){
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
    <#mod validater set to default paremeter with |options|#>
function Add-Settings {
    param(
        [ValidateSet('presentation', 'local', 'defaults')]
        [Parameter(
            HelpMessage="Allowed values: 'presentation', 'local', 'defaults'"
        )]
        [string] $settingName = 'defaults',
        [Alias("bgi")]
        [Parameter()]
        [string] $backgroundImage,
        [Alias("bgt")]
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
        [switch] $p,
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

    if($p){
        <#execute prompt function#>
        Set-OhMyPrompt
    }

    $PSSettings = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_$env:PowerShellVersion\LocalState\settings.json"
    <#get settingName object, if null, get current $PSSettings object#>
    if ($settingName -ine 'defaults'){
        $SettingsObject = Get-Content -Raw "$env:PowerShellHome\Settings\$settingName.json" | ConvertFrom-Json -ErrorAction SilentlyContinue
    }
    if($null -eq $settingsObject){
    $SettingsObject = Get-Content -Raw $PSSettings | ConvertFrom-Json}

    <#if $r switch, replace all#>
    if($r){
        $host.UI.RawUI.ForegroundColor = 'Green'
        if(!$nc){
            $continue = Read-Host "Reset all settings to defaults?(y/n)"
        } else {
            $continue ='y'
        }
        if($continue -ieq 'y'){
            $SettingsObject.profiles.defaults = [PSCustomObject]@{
                backgroundImage = $PRDefaultParameterValues."Add-Settings:backgroundImage"
                backgroundImageOpacity = $PRDefaultParameterValues."Add-Settings:bgTransparency"
                colorScheme = $PRDefaultParameterValues."Add-Settings:colorScheme"
                font = [PSCustomObject]@{
                    face = $PRDefaultParameterValues."Add-Settings:fontFace"
                    size = $PRDefaultParameterValues."Add-Settings:fontSize"
                    weight = $PRDefaultParameterValues."Add-Settings:fontWeight"
                }
                opacity = $PRDefaultParameterValues."Add-Settings:transparency"
            }
            $SettingsObject.theme = $PRDefaultParameterValues."Add-Settings:theme"
        } else {
            return
        }
    } else {
        <#update the settings object#>
        .$PSScriptRoot/Set-Defaults
        if($backgroundImage -ne $settingsObject.profiles.defaults.backgroundImage -and $PSBoundParameters.ContainsKey('backgroundImage')){
            $SettingsObject.profiles.defaults.backgroundImage = $backgroundImage
            <#copy both and put new img in folder#>
            $date = Get-Date -format 'MM-dd-yyyy_hhmmss'
            Copy-Item -Path $PRDefaultParameterValues."Add-Settings:backgroundImage" `
            -Destination "$env:PowerShellHome\Images\$date.jpg"
            Copy-Item -Path $backgroundImage `
            -Destination $PRDefaultParameterValues."Add-Settings:backgroundImage"
        }

        if($bgTransparency -ne $SettingsObject.profiles.defaults.backgroundImageOpacity -and $PSBoundParameters.ContainsKey('bgTransparency')){
            $SettingsObject.profiles.defaults.backgroundImageOpacity = $bgTransparency}
        if($colorScheme -ne $SettingsObject.profiles.defaults.colorScheme -and $PSBoundParameters.ContainsKey('colorScheme')){
            $SettingsObject.profiles.defaults.colorScheme = $colorScheme}
        if($fontFace -ne $SettingsObject.profiles.defaults.font.face -and $PSBoundParameters.ContainsKey('fontFace')){
            $SettingsObject.profiles.defaults.font.face = $fontFace}
        if($fontSize -ne $SettingsObject.profiles.defaults.font.size -and $PSBoundParameters.ContainsKey('fontSize')){
            $SettingsObject.profiles.defaults.font.size = $fontSize}
        if($fontWeight -ne $SettingsObject.profiles.defaults.font.weight -and $PSBoundParameters.ContainsKey('fontWeight')){
            $SettingsObject.profiles.defaults.font.weight = $fontWeight}
        if($transparency -ne $SettingsObject.profiles.defaults.opacity -and $PSBoundParameters.ContainsKey('transparency')){
            $SettingsObject.profiles.defaults.opacity = $transparency}
        if($theme -ne $SettingsObject.theme -and $PSBoundParameters.ContainsKey('theme')){
            $SettingsObject.theme = $theme}
    }
    <#update default settings object file#>
    if($settingName -ieq 'defaults'){
        $host.UI.RawUI.ForegroundColor = 'Green'
        if(!$nc){
            $continue = Read-Host "Your given values will overwrite your default values, continue?(y/n)"
        } else {
            $continue = 'y'
        }
        if ($continue -ieq "y"){
            $outputFile = $PSSettings
            $defaultParams = Get-Content -Path $PSScriptRoot\settings.psd1 
            if($PSBoundParameters.ContainsKey('bgTransparency')){
                $defaultParams[1] = "`t'Add-Settings:bgTransparency'=$bgTransparency"}
            if($PSBoundParameters.ContainsKey('colorScheme')){
                $defaultParams[2] = "`t'Add-Settings:colorScheme'='$colorScheme'"}
            if($PSBoundParameters.ContainsKey('fontFace')){
                $defaultParams[3] = "`t'Add-Settings:fontFace'='$fontFace'"}
            if($PSBoundParameters.ContainsKey('fontSize')){
                $defaultParams[4] = "`t'Add-Settings:fontSize'=$fontSize"}
            if($PSBoundParameters.ContainsKey('fontWeight')){
                $defaultParams[5] = "`t'Add-Settings:fontWeight'='$fontWeight'"}
            if($PSBoundParameters.ContainsKey('transparency')){
                $defaultParams[6] = "`t'Add-Settings:transparency'=$transparency"}
            if($PSBoundParameters.ContainsKey('theme')){
                $defaultParams[7] = "`t'Add-Settings:theme'='$theme'"}
            $defaultParams | Set-Content -Path $PSScriptRoot\settings.psd1 -Force
        } else {
            return
        }
    } else {
        $outputFile = "$env:PowerShellHome\Settings\$settingName.json" 
    }

    <# necessary Depth level 3, this is subject to change if the powershell settings file obtains further nested values #>
    $SettingsObject | ConvertTo-Json -Depth 100 | Set-Content $outputFile
    
    if($settingName -ine 'defaults'){
        Switch-Profile($settingName)
    }
}

function Switch-Profile {
    param(
        [ValidateSet('presentation', 'local', 'defaults')]
        [Parameter(
            HelpMessage="Allowed values: 'presentation', 'local', 'defaults"
        )]
        [string] $settingName = 'defaults',
        [Parameter()]
        [switch] $h
    )

    if($h){
        Get-Content "$PSScriptRoot\help\profiles-help.txt"
        return
    }
    if($settingName -eq 'defaults'){
        .$PSSCriptRoot/Set-Defaults
        return pps defaults -r -nc
    }
    Copy-Item -Path "$env:PowerShellHome\Settings\$settingName.json" `
     -Destination "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_$env:PowerShellVersion\LocalState\settings.json" `
     -ErrorAction SilentlyContinue -ErrorVariable noCopy
    if($noCopy){
        Write-Host `n "No saved profile settings for this option found." `n -ForegroundColor Magenta
    }
} 

function Set-OhMyPrompt(){
    <#get filenames for themes#>
    $themes = Get-Item -Path "$env:PowershellPrompts/*" -Include *.json
    $names = $themes | Get-ItemPropertyValue -Name BaseName
    Write-Output $names "`n"
    $selection = Read-Host "Please select an option (1-$($themes.Count))"
    
    switch ($selection) {
        { $_ -ge 1 -and $_ -le $themes.Count } {
            $index = [int]$selection - 1
            $selectedOption = $themes[$index]
            write-output "changing posh prompt: $names[$index]"
            # Perform actions based on the selected option
            $myProfile = @(Get-Content -Path $Profile)
            $myProfile[0] = "oh-my-posh init pwsh --config $selectedOption | Invoke-Expression"
            $myProfile | Set-Content -Path $Profile -Force
            . $Profile
            <#$ompTheme = $null#>
        }
        default {
            Write-Host "Invalid selection. Please try again."
        }
    }
}

New-Alias -Name chp  -Value Switch-Profile -Description 'Change between profiles.'
New-Alias -Name pps -Value Add-Settings -Description 'Modify settings for profiles.'
Export-ModuleMember -Function * -Alias *