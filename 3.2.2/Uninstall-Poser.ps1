function Uninstall-Poser {
Remove-Item $env:PowerShellHome'\Images' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $env:PowerShellHome'\Settings' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $env:PowerShellHome'\Prompts' -Recurse -Force -ErrorAction SilentlyContinue

[System.Environment]::SetEnvironmentVariable('PowerShellHome',$null,[System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable('PowerShellPrompts',$null,[System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable('PackagePublisherId',$null,[System.EnvironmentVariableTarget]::User)


$paths = @($env:PSModulePath.split(';')).GetEnumerator()
foreach($dir in $paths){
    Remove-Item "$dir/PosEr" -Recurse -Force -ErrorAction SilentlyContinue -ErrorVariable uninstallError
    if ($uninstallError -and ($true -eq (Test-Path -Path "$dir/PosEr"))){
        Write-Host @($uninstallError.Exception.Message)[0] -ForegroundColor Red
        Write-Host "A module has not been removed. `nPlease run the script again as an administrator." -ForegroundColor Magenta
        }
    }
}