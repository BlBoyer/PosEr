@{
    ModuleVersion = '3.1.1'
    Author = 'Ben Boyer'
    Description = 'Powershell Profile Editor for Windows Terminal'
    RootModule = 'PosEr.psm1'
    FunctionsToExport = '*','New-Settings'
    AliasesToExport = '*'
    ScriptsToProcess = 'Set-Defaults.ps1'
}