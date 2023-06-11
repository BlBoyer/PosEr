# Getting Started

### *Set Up the Module*

<mark>&nbsp;*You must have [__windows terminal__](https://apps.microsoft.com/store/detail/windows-terminal/9N0DX20HK701) to use this module.&nbsp;</mark>

1. Once you have terminal installed, open a new instance of '__Windows Powershell__', or use the keyboard shortcut '__Ctrl + Shift + 1__'.

2. Copy the module into your modules directory. You can find the directories availiable using the command:

```pwsh
$env:PSModulePath
```

1. Then use the following command to import the module,

```pwsh
Import-Module PosEr
```

The module contains four functions for your use:

* Set-Environment
* New-Settings
* Add-Settings
* Switch-Profile

Use the __`'Set-Environment'`__ command and supply the '__PowerShellProfilePath__' parameter with the folder you have your PowerShell profile script in.  
The module will then create environment variables and folders to use.  
Use the __`'New-Settings'`__ command to run the initial setup for the terminal settings. If this is not done, it will automatically run when attempting to use the module the first time.  
&nbsp;

### *Setting Defaults*

This module will setup a folder for __'oh-my-posh'__ prompts, <font color="magenta">but it is not required to use it</font>. If you don't have it, you can get it [__here__](https://ohmyposh.dev/).  
You should install nerdfonts if you plan on using __'oh-my-posh'__.  

Find the '__Prompts__' folder. You can add your prompt themes here for later use with the module.
&nbsp;

<mark>*You can use aliases for the following commands, see [*__Aliases__*](#use-the-aliases).</mark>

### *Run the Add-Settings Command*

To change the default settings, you can use the __`'Add_Settings'`__ command like this:  

```pwsh
Add-Settings defaults [-option] [value]
```

<mark>Hint:</mark>
<font color=Magenta>Using the __Add-Settings__ or __Switch-Profile__ commands without a setting name will default to 'defaults'.</font>  

The options are:

* <font color="cyan">initCols</font>
* <font color="cyan">initRows</font>
* <font color="cyan">newTabPlacement</font>
* <font color="cyan">tabWidthMode</font>
* <font color="cyan">theme</font>
* <font color="cyan">useAcrylicTab</font>
* <font color="cyan">newTabAttach</font>
* <font color="cyan">tabBg</font>
* <font color="cyan">tabCloseButton</font>
* <font color="cyan">tabStyleUnfocused</font>
* <font color="cyan">windowTheme</font>
* <font color="cyan">contrastAdjust</font>
* <font color="cyan">backgroundImage</font>
* <font color="cyan">bgTransparency</font>
* <font color="cyan">bellOptions</font>
* <font color="cyan">colorScheme</font>
* <font color="cyan">closeTabBehavior</font>
* <font color="cyan">cursorHeight</font>
* <font color="cyan">cursorShape</font>
* <font color="cyan">elevate</font>
* <font color="cyan">fontFace</font>
* <font color="cyan">fontSize</font>
* <font color="cyan">fontWeight</font>
* <font color="cyan">intenseStyle</font>
* <font color="cyan">transparency</font>
* <font color="cyan">padding</font>
* <font color="cyan">scrollbar</font>
* <font color="cyan">suppressTitleChange</font>
* <font color="cyan">inputSnap</font>
* <font color="cyan">tabTitle</font>
* <font color="cyan">acrylicBg</font>
* <font color="cyan">atlasEngine</font>

To save settings, there are two profiles available that can be created with the __`'Add-Settings'`__ command- `'local'` and `'presentation'`. Supply values for as many parameters as you desire per call.

<font color=magenta>__*Don't supply values for options you wish to use their defaults for.__</font>  
&nbsp;

### *Run the Switch-Profile Command*

To use one of the profiles, use the __`'Switch-Profile'`__ command. Syntax:

```pwsh
Switch-Profile [setting_name]
```

Available options are `'defaults'`, `'local'`, & `'presentation'`.  
&nbsp;

### *Use the Aliases*

Aliases are provide to make the setting functions faster at the keyboard. For the __`'Add-Settings'`__ command, use the alias __`'pps'`__; For the __`'Switch-Profile'`__ command, use the alias __`'chp'`__.  

Examples:  

```pwsh
pps -fontSize 18 -fontWeight 'Bold'
pps local -transparency 30
pps presentation -colorScheme "Tango Dark"
chp presentation
```

The parameters have aliases that can be used as well:  

```pwsh
pps -fs 14 -ff 'Cambridge'
pps presentation -cs 'Vintage'
```

### *Switches*

* <font color="orange">r</font>
* <font color="orange">nc</font>
* <font color="orange">omp</font>

*Use __`'pps -r'`__ with the '__local__' or '__presentation__' setting to reset the values to defaults.  
*Use __`'pps -nc'`__ with the '__defaults__' setting to skip confirmation of changing the module's default values.
*Use __`'pps -omp'`__ to set the oh-my-posh prompt theme.

#### Setting the prompt theme

In your profile.ps1 you should have the following line for loading your '__oh-my-posh__' theme:  
`oh-my-posh init pwsh --config $env:PowerShellPrompts\<theme name>.json | Invoke-Expression`  

<font color="red">*__This line needs to be the first line in your profile.ps1 file in order to work properly with this module.__</font>

Using the __`'-omp'`__ switch will edit this for you.  
&nbsp;  

### *Help*

In order to view the help documentation:

1. Explicitly import the '__Poser__' module

   ```pwsh
   Import-Module Poser
   ```

2. Use the __`'Get-Help'`__ cmdlet:

   ```pwsh
   Get-Help Set-Environment -detailed
   Get-Help Add-Settings -detailed
   Get-Help Switch-Profile -detailed
   ```

<font color=green>Note:</font> You do not need to explicitly import the '__Poser__' module in order to use it, as long as it is set up according to this guide. To keep the help file available consistently, consider adding the import statement to your powershell profile.
