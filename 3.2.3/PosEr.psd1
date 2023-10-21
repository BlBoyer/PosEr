@{
    ModuleVersion = '3.2.3'
    Author = 'Ben Boyer'
    Description = 'Powershell Profile Editor for Windows Terminal'
    RootModule = 'PosEr.psm1'
    FunctionsToExport = '*','New-Settings', 'Uninstall-Poser'
    AliasesToExport = '*'
    ScriptsToProcess = 'Set-Defaults.ps1'
}