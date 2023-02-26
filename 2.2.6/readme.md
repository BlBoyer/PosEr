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
&nbsp;

### *Setting Defaults*

This module will setup a folder for __'oh-my-posh'__ prompts, <font color="magenta">but it is not required to use it</font>. If you don't have it, you can get it [__here__](https://ohmyposh.dev/).  
You should install nerdfonts if you plan on using __'oh-my-posh'__.  

Find the '__Prompts__' folder. You can add your prompt themes here, and use your profile to set the prompt. For example:  
`oh-my-posh init pwsh --config $env:PowerShellPrompts\currentTheme.json | Invoke-Expression`  
&nbsp;

<mark>*You can use aliases for the following commands, see [*__Aliases__*](#use-the-aliases).</mark>

### *Run the Add-Settings Command*

To change the default settings, you can use the __`'Add_Settings'`__ command like this:  

<pre>Add-Settings defaults [-option] [value]</pre>
Use the __`'-h'`__ option to view help contents.  

<mark>Hint:</mark>
<font color=Magenta>Using the __Add-Settings__ or __Switch-Profile__ commands without a setting name will default to 'defaults'.</font>  
<pre>Add-Settings [-option] [value]</pre>
The options are:

- <font color=cyan>backgroundImage</font>
- <font color="cyan">bgTransparency</font>
- <font color="cyan">colorScheme</font>
- <font color="cyan">fontFace</font>
- <font color="cyan">fontSize</font>
- <font color="cyan">fontWeight</font>
- <font color="cyan">transparency</font>
- <font color="cyan">theme</font>

To save settings, there are two profiles available that can be created with the __`'Add-Settings'`__ command- `'local'` and `'presentation'`. Supply values for as many parameters as you desire per call.

<font color=magenta>__*Don't supply values for options you wish to use their defaults for.__</font>  
&nbsp;

### *Run the Switch-Profile Command*

To use one of the profiles, use the __`'Switch-Profile'`__ command. Syntax:

<pre>Switch-Profile [setting_name]</pre>

Available options are `'local'` and `'presentation'`.  

*You must initialize the setting values with the __`'Add-Settings'`__ command before trying to use them.

### *Use the Aliases*

Aliases are provide to make the setting functions faster at the keyboard. For the __`'Add-Settings'`__ command, use the alias __`'pps'`__; For the __`'Switch-Profile'`__ command, use the alias __`'chp'`__.  

Examples:  
<pre>
pps -fontSize 18 -fontWeight 'Bold'
pps local -transparency 30
pps presentation -colorScheme "Tango Dark"
chp presentation
</pre>

<mark></mark>

The parameters have aliases that can be used as well:  
<pre>
pps -fs 14 -ff 'Cambridge'
pps presentation -cs 'Vintage'
</pre>

*Use __`'pps -h'`__ to view full list of setting commands.
