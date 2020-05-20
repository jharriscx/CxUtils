# CxSAST Included

CxSAST utility that includes and excludes source code based on a `.gitignore` file syntax.

## Installing

All files in the `./scripts` directory need to be placed into the Checkmarx Executable folder on the CxSAST Manager.

*Default: `C:\Program Files\Checkmarx\Executables`*

Once these are installed, navigate to `Settings -> Pre & Post Scan Actions` and create a new action.
Note that you'll need to create one action per project as you'll need to setup each with their own Git URL (see next section).

You can follow this guide on [Setting up Pre-Scan Actions](https://checkmarx.atlassian.net/wiki/spaces/KC/pages/1170443044/Configuring+Pre+Post+Scan+Action).

## Running

To run this code, all you'll need is to is setup a Pre Scan Action with variable overrides and then setup the project you want to run the includes on using `Source Pulling`.

*Note: If no `.cxinclude` file exists, then nothing will be added.*

### Arguments

| Argument        | Description                                       |
| :-------------- | :------------------------------------------------ |
| -Help           | Help                                              |
| -Cx_Tmp         | Path to tmp dir which the cloned code gets placed |
| -Cx_Output      | Path to where the code output will stay           |
| -Cx_Logs        | Path to where the logs live                       |
| -Git_Url        | URL/URI to Git instance for cloning               |
| -Git_Branch     | The name of the branch for cloning                |
| -DisableCleanUp | Disables the clean up process leaving tmp files   |

### Examples

```powershell
# Get help information
.\scripts\includer.ps1 -Help

# Clone public repo
.\scripts\includer.ps1 -Git_Url https://github.com/gatsbyjs/gatsby.git
```

## Supported Features

- SSH Cloning

### Long Windows paths

Run the following command in Powershell (admin).

```powershell
Set-ItemProperty 'HKLM:\System\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -value 1
```
