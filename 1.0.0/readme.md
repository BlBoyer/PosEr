# Getting Started
### *Set Up the Module*
<mark>&nbsp;*You must have [__windows terminal__](https://apps.microsoft.com/store/detail/windows-terminal/9N0DX20HK701) to use this module.&nbsp;</mark>  

Copy the module into your modules directory. You can find the directories availiable using the command:
<pre>PWSH> $env:PSModulePath</pre>
Then use,
<pre>PWSH> Import-Module PosEr</pre>  

The module contains three functions:
* Set-Environment
* Add-Settings
* Switch-Profile

Each function can be used with the  __`'-h'`__ switch to display command parameters and information.  

Use the __`'Set-Environment'`__ command and supply the '__PowerShellProfilePath__' parameter with the folder you have your PowerShell profile script in.  
The module will then create environment variables and folders to use.
### *Setting Defaults*
This module is setup for use with __'oh-my-posh'__, <font color="magenta">but it is not required</font>. If you don't have it, you can get it [__here__](https://ohmyposh.dev/).  
You should install nerdfonts if you haven't already.  

Find the '__Prompts__' folder. You can add your prompt themes here, and use your profile to set the prompt. For example:  
`oh-my-posh init pwsh --config $env:PowerShellPrompts\currentTheme.json | Invoke-Expression`

Find the __'Images'__ folder, in your PowerShell profile directory.  
Here you can add a background image, name it: '*background.jpg*'. This will be the default image for your console.  

### *Run the Add-Settings Command*
