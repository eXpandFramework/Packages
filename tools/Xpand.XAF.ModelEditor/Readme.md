![image](https://user-images.githubusercontent.com/159464/66713086-c8c5a800-edae-11e9-9bc1-73ffc0c215fb.png)

[![image](https://xpandshields.azurewebsites.net/badge/Exclusive%20services%3F-Head%20to%20the%20dashboard-Blue)](https://github.com/sponsors/apobekiaris) ![GitHub stars](https://xpandshields.azurewebsites.net/github/stars/expandframework/devexpress.xaf?label=Star%20the%20project%20if%20you%20think%20it%20deserves%20it&style=social) ![GitHub forks](https://xpandshields.azurewebsites.net/github/forks/expandframework/Devexpress.Xaf?label=Fork%20the%20project%20to%20extend%20and%20contribute&style=social)

![](https://xpandshields.azurewebsites.net/nuget/v/Xpand.XAF.ModelEditor.svg?label=nuget.org&style=flat) ![](https://xpandshields.azurewebsites.net/nuget/dt/Xpand.XAF.ModelEditor.svg?style=flat)
# About

The `Xpand.XAF.ModelEditor` package contains a standalone version of XAF Model Editor, designed to integrate with Visual Studio, Rider, Explorer as standalone without any dependency to eXpandFramework packages. ALternatively you can use the VSIX package where the XpandModelEditor is embedded as described in [VSIX integration section](https://github.com/eXpandFramework/DevExpress.XAF/tree/master/tools/Xpand.XAF.ModelEditor#vsix-integration). 

## VSIX integration 

Having installed the VSIX package (available in the [releases page](https://github.com/eXpandFramework/eXpand/releases)) you will also get the XpandModelEditor as it is embedded and there is no need to install anything else.

In the VSIX ModelEditor integration there is an extra tool, the `XAF Solution Model List` which
is very useful when you work in VS with large projects as it uses a grid to allow fast navigation. In addition can open extra models and not only the XAF default ones. Bellow you see the AllModules.sln which contains all the modules of the main framework with some custom filter applied `.w`.

![image](https://user-images.githubusercontent.com/159464/75141828-769c7800-56fa-11ea-9498-49374bb96fae.png)

> The XAF Solution Model List in some systems may have transparency issues. To fix it uncheck the VS Menu/Options/Environment/General/Optimize Rendering...

Next you will get instructions on how to use the XpandModelEditor with Rider or Visual Studio or Explorer without the VSIX.

## Installation

Use the Package Manager, or the next command to one of your projects in your solution.

```ps1
Install-Package Xpand.XAF.ModelEditor
```

## Requirements

1. DevExpress or eXpandFramework installation is optional.
2. Visual Studio integration is done once however requires manual effort.
3. Rider integration is fully automated.
4. There is no need to install the package to more than one project in your solution or to update it if you add/remove projects.
4. The package is version agnostic in regards to DevExpress version, meaning you do not have to update when you change your DevExpress version.
5. There is no need to have Visual Studio installed if you only use Rider but dotnet core should be installed.

## How it works

`Xpand.XAF.ModelEditor` package is distributed from nuget.org as a Nuget package. After each build it will detect the used DevExpress version and will download the required DevExpress dependencies from your system feeds. So if you already have DevExpress installed there is no need for extra configuration. If not just make sure you add a feed to Nuget.config that points to valid DevExpress packages (local or remote). Subsequent builds won't download or check those dependencies but they will modify the solution bootstrappers if needed e.g. a new project added to the solution.

All downloaded dependencies for each XAF version remain inside the package installation folder under the ModelerLibDownloader\bin directory.

If it fails to detect the DevExpress version used due to either indirect references or another way of package reference configuration, then you can force by using the `DevExpressVersion` msbuild property.
### TroubleShooting

1. The work is done on each build so start from a clean build.
2. If previous step did not work delete the Nuget package from your nuget cache and try again.
3. You still have problems then enable logging by either setting the Environmental variable `ModelEditorVerbose` to 1 or the same MSBuild property to true. This will generate an execution.log inside the package directory, provide it to support with as much details as possible over the usage context..
4. For support, feedback etc. use the main project [issues](https://github.com/eXpandFramework/eXpand/issues/new/choose).

[![GitHub issues by-label](https://xpandshields.azurewebsites.net/github/issues/expandframework/expand/XpandModelEditor)](https://github.com/eXpandFramework/eXpand/issues?utf8=%E2%9C%93&q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc+label%3AXpandModelEditor) [![GitHub close issues](https://xpandshields.azurewebsites.net/github/issues-closed/eXpandFramework/eXpand/XpandModelEditor.svg)](https://github.com/eXpandFramework/eXpand/issues?utf8=%E2%9C%93&q=is%3Aissue+is%3Aclosed+sort%3Aupdated-desc+label%3AXpandModelEditor)

## Rider installation
Rider installation is ready to go without any additional steps. The Xpand.XAF.ModelEditor creates an external tool in your Settings/Custom tools.

![image](https://user-images.githubusercontent.com/159464/75139968-9f227300-56f6-11ea-98f7-47c7aab37b8d.png)

and a menu entry in the solution explorer context menu which is shown only for xafml files.
<twitter>
![image](https://user-images.githubusercontent.com/159464/75140145-06d8be00-56f7-11ea-9e0e-9b03b6e2381f.png)
</twitter>
If you prefer to work with Rider without having installed DevExpress consider the following cmdlets from the [XpandPwsh](https://github.com/eXpandFramework/XpandPwsh) module:
1. [Start-XpandProjectConverter](https://github.com/eXpandFramework/XpandPwsh/wiki/Start-XpandProjectConverter)
2. [New-XafProject](https://github.com/eXpandFramework/XpandPwsh/wiki/New-XAFProject)

## Visual Studio installation

1. Create a custom tool from your VS Tools/External Tools menu as shown:

   ![image](https://user-images.githubusercontent.com/159464/75140431-92524f00-56f7-11ea-821d-698b32e89327.png)

   Argumens: /Q /D /E:OFF /C "$(ProjectDir)Xpand.XAF.ModelEditor.bat"
2. Create a solution context menu entry following the next steps:
  
  Go to your VS Tools -> Customize ... -> Commands -> Context Menu -> Project and Solution Context Menus | Item menu

  ![image](https://user-images.githubusercontent.com/159464/75140808-51a70580-56f8-11ea-862b-1b400fbcedaa.png)

  Choose either Open or Add Command and the Tools and select the command that matches the index of your External tool you created previously.

  ![image](https://user-images.githubusercontent.com/159464/75140909-82873a80-56f8-11ea-8c0c-c48bf8cf934c.png)

  The context entry should now be visible.

  ![image](https://user-images.githubusercontent.com/159464/75141245-3b4d7980-56f9-11ea-9d41-81642c134946.png)




