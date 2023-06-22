Remove-Item $env:PowerShellHome'\Images' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $env:PowerShellHome'\Settings' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $env:PowerShellHome'\Prompts' -Recurse -Force -ErrorAction SilentlyContinue

[System.Environment]::SetEnvironmentVariable('PowerShellHome',$null,[System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable('PowerShellPrompts',$null,[System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable('PackagePublisherId',$null,[System.EnvironmentVariableTarget]::User)

$paths = @($env:PSModulePath.split(';')).GetEnumerator()
foreach($dir in $paths){
    Remove-Item "$dir/PosEr" -Recurse -Force -ErrorAction SilentlyContinue -ErrorVariable $checkAdmin
    if ($checkAdmin){
        write-host $checkAdmin
        }
    }