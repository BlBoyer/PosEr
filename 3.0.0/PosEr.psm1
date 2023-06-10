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

function New-Settings {
    Write-Host "Adding New Settings" -ForegroundColor Cyan
    $PSSettings = Get-Content -Raw "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_$env:PowerShellVersion\LocalState\settings.json" | ConvertFrom-Json
    <#mod settings to all values#>
    Add-Member -InputObject $PSSettings -MemberType NoteProperty -Name defaultProfile -Value "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}" -Force
    Add-Member -InputObject $PSSettings -MemberType NoteProperty -Name initialCols -Value $PRDefaultParameterValues."Add-Settings:initCols" -Force
    Add-Member -InputObject $PSSettings -MemberType NoteProperty -Name initialRows -Value $PRDefaultParameterValues."Add-Settings:initRows" -Force
    Add-Member -InputObject $PSSettings -MemberType NoteProperty -Name newTabPosition -Value $PRDefaultParameterValues."Add-Settings:newTabPlacement" -Force
    Add-Member -InputObject $PSSettings -MemberType NoteProperty -Name tabWidthMode -Value $PRDefaultParameterValues."Add-Settings:tabWidthMode" -Force
    Add-Member -InputObject $PSSettings -MemberType NoteProperty -Name theme -Value $PRDefaultParameterValues."Add-Settings:theme" -Force
    Add-Member -InputObject $PSSettings -MemberType NoteProperty -Name useAcrylicInTabRow -Value $PRDefaultParameterValues."Add-Settings:useAcrylicTab" -Force
    Add-Member -InputObject $PSSettings -MemberType NoteProperty -Name windowingBehavior -Value $PRDefaultParameterValues."Add-Settings:newTabAttach" -Force
    $PSSettings.themes[$PSSettings.themes.Count-1] = [PSCustomObject]@{
        <#we may put name key here,just to make sure it is custom, or if it doesn't work without it#>
            name = $PRDefaultParameterValues."Add-Settings:theme"
            tab = [PSCustomObject]@{
              background = $PRDefaultParameterValues."Add-Settings:tabBg"
              showCloseButton = $PRDefaultParameterValues."Add-Settings:tabCloseButton"
              unfocusedBackground = $PRDefaultParameterValues."Add-Settings:tabStyleUnfocused"
            }
            window = [PSCustomObject]@{
              applicationTheme = $PRDefaultParameterValues."Add-Settings:windowTheme"
            }
    }
    $PSSettings.profiles.defaults = [PSCustomObject]@{
        adjustIndistinguishableColors = $PRDefaultParameterValues."Add-Settings:contrastAdjust"
        backgroundImage = $PRDefaultParameterValues."Add-Settings:backgroundImage"
        backgroundImageOpacity = $PRDefaultParameterValues."Add-Settings:bgTransparency"
        bellStyle = $PRDefaultParameterValues."Add-Settings:bellOptions"
        colorScheme = $PRDefaultParameterValues."Add-Settings:colorScheme"
        closeOnExit = $PRDefaultParameterValues."Add-Settings:closeTabBehavior"
        cursorHeight = $PRDefaultParameterValues."Add-Settings:cursorHeight"
        cursorShape = $PRDefaultParameterValues."Add-Settings:cursorShape"
        elevate = $PRDefaultParameterValues."Add-Settings:elevate"
        font = [PSCustomObject]@{
            face = $PRDefaultParameterValues."Add-Settings:fontFace"
            size = $PRDefaultParameterValues."Add-Settings:fontSize"
            weight = $PRDefaultParameterValues."Add-Settings:fontWeight"
        }
        intenseTextStyle = $PRDefaultParameterValues."Add-Settings:intenseStyle"
        opacity = $PRDefaultParameterValues."Add-Settings:transparency"
        padding = $PRDefaultParameterValues."Add-Settings:padding"
        scrollbarState = $PRDefaultParameterValues."Add-Settings:scrollbar"
        suppressApplicationTitle = $PRDefaultParameterValues."Add-Settings:suppressTitleChange"
        snapOnInput = $PRDefaultParameterValues."Add-Settings:inputSnap"
        tabTitle = $PRDefaultParameterValues."Add-Settings:tabTitle"
        useAcrylic = $PRDefaultParameterValues."Add-Settings:acrylicBg"
        useAtlasEngine = $PRDefaultParameterValues."Add-Settings:atlasEngine"
    }
    <#set content to two file or do one, then the other#>
    $outputFile = "$env:PowerShellHome\Settings\local.json" 
    $PSSettings | ConvertTo-Json -Depth 100 | Set-Content $outputFile
    $outputFile = "$env:PowerShellHome\Settings\presentation.json" 
    $PSSettings | ConvertTo-Json -Depth 100 | Set-Content $outputFile
    $outputFile = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_$env:PowerShellVersion\LocalState\settings.json"
    $PSSettings | ConvertTo-Json -Depth 100 | Set-Content $outputFile
    $outputFile = $null
}
function Add-Settings {
    param(
        [Parameter(
            HelpMessage="Allowed values: 'presentation', 'local', 'defaults'"
            )]
        [ValidateSet('presentation', 'local', 'defaults')]
        [string] $settingName = 'defaults',
    <#settings#>
        [Parameter()]
        [Alias("col")]
        [ValidateRange(10,180)]
        [int] $initCols,

        [Parameter()]
        [Alias("row")]
        [ValidateRange(10,80)]
        [int] $initRows,

        
        [Parameter()]
        [Alias("tabp")]
        [ValidateSet("afterCurrentTab","afterLastTab")]
        [string] $newTabPlacement,
        
        [Parameter()]
        [Alias("twm")]
        [ValidateSet("compact","equal","titleLength")]
        [string] $tabWidthMode,
        
        [Alias("th")]
        [ValidateSet("dark", "light", "system", "custom")]
        [Parameter()]
        [string] $theme,
        
        [Parameter()]
        [Alias("act")]
        [bool] $useAcrylicTab,
        
        [Parameter()]
        [Alias("nta")]
        [ValidateSet("useAnyExisting", "useExisting","useNew")]
        [string] $newTabAttach,

    <#themes accessed by index#>
        <#values can be 'accent' 'terminalBackground' or rrggbb or rrggbbaa color#>
        [Parameter()]
        [Alias("tbg")]
        [string] $tabBg,

        [Parameter()]
        [Alias("tcb")]
        [ValidateSet("always","hover","never")]
        [string] $tabCloseButton,

        <#values can be 'accent' 'terminalBackground' or rrggbb or rrggbbaa color#>
        [Parameter()]
        [Alias("tsu")]
        [string] $tabStyleUnfocused,

        <#used for controls#>
        [Parameter()]
        [Alias("wth")]
        [ValidateSet("dark","light","system")]
        [string] $windowTheme,

    <#defaults#>
    
        [Parameter()]
        [Alias("ca")]
        [ValidateSet("indexed", "always", "never")]
        [string] $contrastAdjust,

        [Parameter()]
        [Alias("bgi")]
        [ValidateScript({Test-Path $_})]
        [string] $backgroundImage,
        
        [Parameter()]
        [Alias("bgt")]
        [ValidateRange(0.0, 1.0)]
        [float] $bgTransparency,

        [Parameter()]
        [Alias("bell")]
        [ValidateScript({@("audible", "taskbar", "window").Contains($_)})]
        [string[]] $bellOptions,
        
        [Parameter()]
        [Alias("cs")]
        [ValidateSet("Campbell", "Campbell Powershell", "One Half Dark", "One Half Light",
        "Solarized Dark", "Solarized Light", "Tango Dark", "Tango Light", "Vintage")]
        [string] $colorScheme,

        [Parameter()]
        [Alias("ctb")]
        [ValidateSet("never", "automatic", "always", "graceful")]
        [string] $closeTabBehaviour,
        
        [Parameter()]
        [Alias("ch")]
        [ValidateRange(0,100)]
        [int]
        $cursorHeight,
        
        [Parameter()]
        [Alias("cu")]
        [ValidateSet("bar", "doubleUnderscore", "emptyBox", "filledBox", "underscore", "vintage")]
        [string]
        $cursorShape,

        [Parameter()]
        [Alias("su")]
        [bool]
        $elevate,
        
        [Parameter()]
        [Alias("ff")]
        [string] $fontFace,
        
        [Parameter()]
        [Alias("fs")]
        [ValidateRange(8,20)]
        [int] $fontSize,
        
        [Parameter()]
        [Alias("fw")]
        [ValidateSet("Thin", "Extra-Light", 'Light', "Semi-Light", "Normal", "Medium", "Semi-Bold", 
        "Bold", "Extra-Bold", "Black", "Extra-Black", "Custom")]
        [string] $fontWeight,
        
        [Parameter()]
        [Alias("istyle")]
        [ValidateSet("all","bright","bold","none")]
        [string]
        $intenseStyle,
        
        [Parameter()]
        [Alias("ty")]
        [ValidateRange(0,100)]
        [int] $transparency,
        
        [Parameter()]
        [Alias("pd")]
        [ValidateRange(0,30)]
        [int]
        $padding,

        [Parameter()]
        [Alias("scroll")]
        [ValidateSet('always','hidden','visible')]
        [string]
        $scrollbar,

        [Parameter()]
        [Alias("supt")]
        [bool]
        $supressTitleChange,

        [Parameter()]
        [Alias("alta")]
        [bool] $altGrAliasing,        
        
        [Parameter()]
        [Alias("snap")]
        [bool]
        $inputSnap,
   
        [Parameter()]
        [Alias("title")]
        [ValidateScript({$_.Length -le 30 })]
        [string]
        $tabTitle,

        [Parameter()]
        [Alias("acbg")]
        [bool]
        $acrylicBg,

        [Parameter()]
        [Alias("ae")]
        [bool]
        $atlasEngine,

        [Parameter()]
        [switch] $omp,

        [Parameter()]
        [switch] $h,

        [Parameter()]
        [switch] $r,

        [Parameter()]
        [switch] $nc
    )

    <#if files do not exist, run setup#>
    if (!(Test-Path -Path "$env:PowerShellHome\Settings\local.json") -or !(Test-Path -Path "$env:PowerShellHome\Settings\presentation.json")){
        Write-Host "No Settings Present" -ForegroundColor Magenta
        New-Settings
        return
    }
   
    if($h){
        Get-Content "$PSScriptRoot\help\settings-help.txt" 
        return
    }

    if($null -eq $env:PowerShellHome){
        Set-Environment
    }

    if($omp){
        <#execute prompt function#>
        Set-OhMyPrompt
    }

    $PSSettings = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_$env:PowerShellVersion\LocalState\settings.json"
    <#get settingName object, if null, get current $PSSettings object#>
    if ($settingName -ine 'defaults'){
        $SettingsObject = Get-Content -Raw "$env:PowerShellHome\Settings\$settingName.json" -ErrorAction SilentlyContinue | ConvertFrom-Json
    }
    if($null -eq $settingsObject){
        $SettingsObject = Get-Content -Raw $PSSettings | ConvertFrom-Json
    }

    <#if $r switch, replace all#>
    if($r){
        $host.UI.RawUI.ForegroundColor = 'Green'
        if(!$nc){
            $continue = Read-Host "Reset all settings to defaults?(y/n)"
        } else {
            $continue ='y'
        }
        if($continue -ieq 'y'){
            $SettingsObject.initialCols = $PRDefaultParameterValues."Add-Settings:initCols"
            $SettingsObject.initialRows = $PRDefaultParameterValues."Add-Settings:initRows"
            $SettingsObject.newTabPosition = $PRDefaultParameterValues."Add-Settings:newTabPlacement"
            $SettingsObject.tabWidthMode = $PRDefaultParameterValues."Add-Settings:tabWidthMode"
            $SettingsObject.theme = $PRDefaultParameterValues."Add-Settings:theme"
            $SettingsObject.useAcrylicInTabRow = $PRDefaultParameterValues."Add-Settings:useAcrylicTab"
            $SettingsObject.windowingBehavior = $PRDefaultParameterValues."Add-Settings:newTabAttach"
            <#Select-Where name is settings definition#>
            $SettingsObject.themes[$SettingsObject.themes.Count-1] = [PSCustomObject]@{
                <#we may put name key here,just to make sure it is custom, or if it doesn't work without it#>
                    name = $PRDefaultParameterValues."Add-Settings:theme"
                    tab = [PSCustomObject]@{
                      background = $PRDefaultParameterValues."Add-Settings:tabBg"
                      showCloseButton = $PRDefaultParameterValues."Add-Settings:tabCloseButton"
                      unfocusedBackground = $PRDefaultParameterValues."Add-Settings:tabStyleUnfocused"
                    }
                    window = [PSCustomObject]@{
                      applicationTheme = $PRDefaultParameterValues."Add-Settings:windowTheme"
                    }
            }
            $SettingsObject.profiles.defaults = [PSCustomObject]@{
                adjustIndistinguishableColors = $PRDefaultParameterValues."Add-Settings:contrastAdjust"
                backgroundImage = $PRDefaultParameterValues."Add-Settings:backgroundImage"
                backgroundImageOpacity = $PRDefaultParameterValues."Add-Settings:bgTransparency"
                bellStyle = $PRDefaultParameterValues."Add-Settings:bellOptions"
                colorScheme = $PRDefaultParameterValues."Add-Settings:colorScheme"
                closeOnExit = $PRDefaultParameterValues."Add-Settings:closeTabBehavior"
                cursorHeight = $PRDefaultParameterValues."Add-Settings:cursorHeight"
                cursorShape = $PRDefaultParameterValues."Add-Settings:cursorShape"
                elevate = $PRDefaultParameterValues."Add-Settings:elevate"
                font = [PSCustomObject]@{
                    face = $PRDefaultParameterValues."Add-Settings:fontFace"
                    size = $PRDefaultParameterValues."Add-Settings:fontSize"
                    weight = $PRDefaultParameterValues."Add-Settings:fontWeight"
                }
                intenseTextStyle = $PRDefaultParameterValues."Add-Settings:intenseStyle"
                opacity = $PRDefaultParameterValues."Add-Settings:transparency"
                padding = $PRDefaultParameterValues."Add-Settings:padding"
                scrollbarState = $PRDefaultParameterValues."Add-Settings:scrollbar"
                suppressApplicationTitle = $PRDefaultParameterValues."Add-Settings:suppressTitleChange"
                snapOnInput = $PRDefaultParameterValues."Add-Settings:inputSnap"
                tabTitle = $PRDefaultParameterValues."Add-Settings:tabTitle"
                useAcrylic = $PRDefaultParameterValues."Add-Settings:acrylicBg"
                useAtlasEngine = $PRDefaultParameterValues."Add-Settings:atlasEngine"
            }
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
            <#settings#>
        if($initCols -ne $SettingsObject.initialCols -and $PSBoundParameters.ContainsKey('initialCols')){
            $SettingsObject.initialCols = $initialCols
        }
        if($initRows -ne $SettingsObject.initialRows -and $PSBoundParameters.ContainsKey('initialRows')){
            $SettingsObject.initialRows = $initialRows
        }
        if($newTabPlacement -ne $SettingsObject.newTabPosition -and $PSBoundParameters.ContainsKey('newTabPlacement')){
            $SettingsObject.newTabPosition = $newTabPosition
        }
        if($tabWidthMode -ne $SettingsObject.tabWidthMode -and $PSBoundParameters.ContainsKey('tabWidthMode')){
            $SettingsObject.tabWidthMode = $tabWidthMode
        }
        if($useAcrylicTab -ne $SettingsObject.useAcrylicInTabRow -and $PSBoundParameters.ContainsKey('useAcrylicTab')){
            $SettingsObject.useAcrylicInTabRow = $useAcrylicTab
        }
        if($theme -ne $SettingsObject.theme -and $PSBoundParameters.ContainsKey('theme')){
            $SettingsObject.theme = $theme}
            <#themes[index].tab#>
        if($tabBg -ne $SettingsObject.themes[$SettingsObject.themes.Count-1].tab.background -and $PSBoundParameters.ContainsKey('tabBg')){
            $SettingsObject.themes[$SettingsObject.themes.Count-1].tab.background = $tabBg
        }
        if($tabCloseButton -ne $SettingsObject.themes[$SettingsObject.themes.Count-1].tab.showCloseButton -and $PSBoundParameters.ContainsKey('tabCloseButton')){
            $SettingsObject.themes[$SettingsObject.themes.Count-1].tab.showCloseButton = $tabCloseButton
        }
        if($tabStyleUnfocused -ne $SettingsObject.themes[$SettingsObject.themes.Count-1].tab.unfocusedBackground -and $PSBoundParameters.ContainsKey('tabStyleUnfocused')){
            $SettingsObject.themes[$SettingsObject.themes.Count-1].tab.unfocusedBackground = $tabStyleUnfocused
        }
              <#themes[index].window#>
        if($windowTheme -ne $SettingsObject.themes[$SettingsObject.themes.Count-1].window.applicationTheme -and $PSBoundParameters.ContainsKey('windowTheme')){
            $SettingsObject.themes[$SettingsObject.themes.Count-1].window.applicationTheme = $windowTheme}
            <#defaults#>
        if($adjustIndistinguishableColors -ne $SettingsObject.profiles.defaults.adjustIndistinguishableColors -and $PSBoundParameters.ContainsKey('contrastAdjust')){
            $SettingsObject.profiles.defaults.adjustIndistinguishableColors = $adjustIndistinguishableColors
        }
        if($bgTransparency -ne $SettingsObject.profiles.defaults.backgroundImageOpacity -and $PSBoundParameters.ContainsKey('bgTransparency')){
            $SettingsObject.profiles.defaults.backgroundImageOpacity = $bgTransparency}
            if($bellStyle -ne $SettingsObject.profiles.defaults.bellStyle -and $PSBoundParameters.ContainsKey('bellOptions')){
                $SettingsObject.profiles.defaults.bellStyle = $bellStyle
            }
        if($colorScheme -ne $SettingsObject.profiles.defaults.colorScheme -and $PSBoundParameters.ContainsKey('colorScheme')){
            $SettingsObject.profiles.defaults.colorScheme = $colorScheme}
        if($closeTabBehavior -ne $SettingsObject.profiles.defaults.closeOnExit -and $PSBoundParameters.ContainsKey('closeTabBehavior')){
            $SettingsObject.profiles.defaults.closeOnExit = $closeTabBehavior
        }
        if($cursorHeight -ne $SettingsObject.profiles.defaults.cursorHeight -and $PSBoundParameters.ContainsKey('cursorHeight')){
            $SettingsObject.profiles.defaults.cursorHeight = $cursorHeight
        }
        if($cursorShape -ne $SettingsObject.profiles.defaults.cursorShape -and $PSBoundParameters.ContainsKey('cursorShape')){
            $SettingsObject.profiles.defaults.cursorShape = $cursorShape
        }
        if($elevate -ne $SettingsObject.profiles.defaults.elevate -and $PSBoundParameters.ContainsKey('elevate')){
            $SettingsObject.profiles.defaults.elevate = $elevate
        }
        if($fontFace -ne $SettingsObject.profiles.defaults.font.face -and $PSBoundParameters.ContainsKey('fontFace')){
            $SettingsObject.profiles.defaults.font.face = $fontFace}
        if($fontSize -ne $SettingsObject.profiles.defaults.font.size -and $PSBoundParameters.ContainsKey('fontSize')){
            $SettingsObject.profiles.defaults.font.size = $fontSize}
        if($fontWeight -ne $SettingsObject.profiles.defaults.font.weight -and $PSBoundParameters.ContainsKey('fontWeight')){
            $SettingsObject.profiles.defaults.font.weight = $fontWeight}
        if($intenseTextStyle -ne $SettingsObject.profiles.defaults.intenseTextStyle -and $PSBoundParameters.ContainsKey('intenseStyle')){
            $SettingsObject.profiles.defaults.intenseTextStyle = $intenseTextStyle
        }
        if($transparency -ne $SettingsObject.profiles.defaults.opacity -and $PSBoundParameters.ContainsKey('transparency')){
            $SettingsObject.profiles.defaults.opacity = $transparency}
        if($padding -ne $SettingsObject.profiles.defaults.padding -and $PSBoundParameters.ContainsKey('padding')){
            $SettingsObject.profiles.defaults.padding = $padding
        }
        if($scrollbarState -ne $SettingsObject.profiles.defaults.scrollbarState -and $PSBoundParameters.ContainsKey('scrollbar')){
            $SettingsObject.profiles.defaults.scrollbarState = $scrollbarState
        }
        if($suppressTitleChange -ne $SettingsObject.profiles.defaults.suppressApplicationTitle -and $PSBoundParameters.ContainsKey('suppressTitleChange')){
            $SettingsObject.profiles.defaults.suppressApplicationTitle = $suppressTitleChange
        }
        if($snapOnInput -ne $SettingsObject.profiles.defaults.snapOnInput -and $PSBoundParameters.ContainsKey('inputSnap')){
            $SettingsObject.profiles.defaults.snapOnInput = $snapOnInput
        }
        if($tabTitle -ne $SettingsObject.profiles.defaults.tabTitle -and $PSBoundParameters.ContainsKey('tabTitle')){
            $SettingsObject.profiles.defaults.tabTitle = $tabTitle
        }
        if($useAcrylic -ne $SettingsObject.profiles.defaults.useAcrylic -and $PSBoundParameters.ContainsKey('acrylicBg')){
            $SettingsObject.profiles.defaults.useAcrylic = $useAcrylic
        }
        if($useAtlasEngine -ne $SettingsObject.profiles.defaults.useAtlasEngine -and $PSBoundParameters.ContainsKey('atlasEngine')){
            $SettingsObject.profiles.defaults.useAtlasEngine = $useAtlasEngine
        }
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
            if($PSBoundParameters.ContainsKey('initCols')){$defaultParams[1] = "`t'Add-Settings:initCols'='$initCols"}
            if($PSBoundParameters.ContainsKey('initRows')){$defaultParams[2] = "`t'Add-Settings:initRows'='$initRows"}
            if($PSBoundParameters.ContainsKey('newTabPlacement')){$defaultParams[3] = "`t'Add-Settings:newTabPlacement'='$newTabPlacement"}
            if($PSBoundParameters.ContainsKey('tabWidthMode')){$defaultParams[4] = "`t'Add-Settings:tabWidthMode'='$tabWidthMode"}
            if($PSBoundParameters.ContainsKey('theme')){$defaultParams[5] = "`t'Add-Settings:theme'='$theme"}
            if($PSBoundParameters.ContainsKey('useAcrylicTab')){$defaultParams[6] = "`t'Add-Settings:useAcrylicTab'='$useAcrylicTab"}
            if($PSBoundParameters.ContainsKey('newTabAttach')){$defaultParams[7] = "`t'Add-Settings:newTabAttach'='$newTabAttach"}
            if($PSBoundParameters.ContainsKey('tabBg')){$defaultParams[8] = "`t'Add-Settings:tabBg'='$tabBg"}
            if($PSBoundParameters.ContainsKey('tabCloseButton')){$defaultParams[9] = "`t'Add-Settings:tabCloseButton'='$tabCloseButton"}
            if($PSBoundParameters.ContainsKey('tabStyleUnfocused')){$defaultParams[10] = "`t'Add-Settings:tabStyleUnfocused'='$tabStyleUnfocused"}
            if($PSBoundParameters.ContainsKey('windowTheme')){$defaultParams[11] = "`t'Add-Settings:windowTheme'='$windowTheme"}
            if($PSBoundParameters.ContainsKey('contrastAdjust')){$defaultParams[12] = "`t'Add-Settings:contrastAdjust'='$contrastAdjust"}
            if($PSBoundParameters.ContainsKey('bgTransparency')){$defaultParams[13] = "`t'Add-Settings:bgTransparency'='$bgTransparency"}
            if($PSBoundParameters.ContainsKey('bellOptions')){$defaultParams[14] = "`t'Add-Settings:bellOptions'='$bellOptions"}
            if($PSBoundParameters.ContainsKey('colorScheme')){$defaultParams[15] = "`t'Add-Settings:colorScheme'='$colorScheme"}
            if($PSBoundParameters.ContainsKey('cursorHeight')){$defaultParams[16] = "`t'Add-Settings:cursorHeight'='$cursorHeight"}
            if($PSBoundParameters.ContainsKey('cursorShape')){$defaultParams[17] = "`t'Add-Settings:cursorShape'='$cursorShape"}
            if($PSBoundParameters.ContainsKey('fontFace')){$defaultParams[18] = "`t'Add-Settings:fontFace'='$fontFace"}
            if($PSBoundParameters.ContainsKey('fontSize')){$defaultParams[19] = "`t'Add-Settings:fontSize'='$fontSize"}
            if($PSBoundParameters.ContainsKey('fontWeight')){$defaultParams[20] = "`t'Add-Settings:fontWeight'='$fontWeight"}
            if($PSBoundParameters.ContainsKey('intenseStyle')){$defaultParams[21] = "`t'Add-Settings:intenseStyle'='$intenseStyle"}
            if($PSBoundParameters.ContainsKey('transparency')){$defaultParams[22] = "`t'Add-Settings:transparency'='$transparency"}
            if($PSBoundParameters.ContainsKey('padding')){$defaultParams[23] = "`t'Add-Settings:padding'='$padding"}
            if($PSBoundParameters.ContainsKey('scrollbar')){$defaultParams[24] = "`t'Add-Settings:scrollbar'='$scrollbar"}
            if($PSBoundParameters.ContainsKey('suppressTitleChange')){$defaultParams[25] = "`t'Add-Settings:suppressTitleChange'='$suppressTitleChange"}
            if($PSBoundParameters.ContainsKey('acrylicBg')){$defaultParams[26] = "`t'Add-Settings:acrylicBg'='$acrylicBg"}
            if($PSBoundParameters.ContainsKey('atlasEngine')){$defaultParams[27] = "`t'Add-Settings:atlasEngine'='$atlasEngine"}
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