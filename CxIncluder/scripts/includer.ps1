param(
    # Cx Variables
    [Parameter(
        Mandatory = $false,
        HelpMessage = "Git Tmp Folder"
    )][string[]] $CX_TMP = $(Get-Location).Path + "/_cxtmp",
    [Parameter(
        Mandatory = $false,
        HelpMessage = "Where source code will live"
    )][string[]] $CX_OUTPUT = $(Get-Location).Path,
    [Parameter(
        Mandatory = $false,
        HelpMessage = "Where to store the logs/transcript"
    )][string[]] $CX_LOGS = "C:\Program Files\Checkmarx\Logs\CxIncluder",
    #

    # Git Variables
    [Parameter(
        Mandatory = $false,
        HelpMessage = "Git URL/URI"
    )][string[]] $GIT_URL,
    [Parameter(
        Mandatory = $false,
        HelpMessage = "Git Branch"
    )][string[]] $GIT_BRANCH = "master",

    # Others
    [Parameter(
        Mandatory = $false,
        HelpMessage = "Clean Up"
    )][switch] $DisableCleanUp,
    [Parameter(
        Mandatory = $false,
        HelpMessage = "Help"
    )][switch] $help
)


# Setup
# Add better debugging support
if (($DEBUG)) {
    $env:DEBUG = "1"
    $DebugPreference = "Continue"
}

# Logging
# Create the log dir if it doesn't exist
New-Item -ItemType Directory -Force -Path $CX_LOGS | Out-Null
# This is needed to debug the logs of the CxSAST Pre-Scan script
$CX_LOGS = Resolve-Path -Path $CX_LOGS
Start-Transcript -OutputDirectory "$CX_LOGS" -Append


Write-Host "  _________                  .___              .__            .___"
Write-Host "  \_   ___ \___  ___         |   | ____   ____ |  |  __ __  __| _/___________"
Write-Host "  /    \  \/\  \/  /  ______ |   |/    \_/ ___\|  | |  |  \/ __ |/ __ \_  __ \"
Write-Host "  \     \____>    <  /_____/ |   |   |  \  \___|  |_|  |  / /_/ \  ___/|  | \/"
Write-Host "   \______  /__/\_ \         |___|___|  /\___  >____/____/\____ |\___  >__|"
Write-Host "          \/      \/                  \/     \/                \/    \/"
Write-Host ""

if (($help)) {
    Write-Host " -Help              Help"
    Write-Host " -Cx_Tmp            Path to tmp dir which the cloned code gets placed"
    Write-Host " -Cx_Output         Path to where the code output will stay"
    Write-Host " -Cx_Logs           Path to where the logs live"
    Write-Host " -Git_Url           URL/URI to Git instance for cloning"
    Write-Host " -Git_Branch        The name of the branch for cloning"
    Write-Host " -DisableCleanUp    Disables the clean up process leaving tmp files"
    Write-Host ""

    Stop-Transcript
    exit
}

Write-Host " ========== Configurations =========="
Write-Host "Git URI             :: $GIT_URL"
Write-Host "Git Branch          :: $GIT_BRANCH"
Write-Host "Logs Folder         :: $CX_LOGS"
Write-Host "Tmp Directory       :: $CX_TMP"
Write-Host ""

# Check if the tmp folder exists and clone if it doesn't
if (-not (Test-Path $CX_TMP)) {
    Write-Debug "Running clone command :: git clone -b $GIT_BRANCH $GIT_URL $CX_TMP"
    git clone -b "$GIT_BRANCH" --depth=1 "$GIT_URL" $CX_TMP
}
else {
    Write-Warning "Tmp Directory is present..."
}

# Process Excludes folders
if ([System.IO.File]::Exists("$CX_TMP\.cxexclude")) {
    Write-Host "Processing Excludes File :: $file"
    [string[]]$ExcludesFromFile = @()
    foreach($line in Get-Content "$CX_TMP\.cxexclude") {
        # comments
        if ($line.StartsWith("#")) { Write-Debug "Comment :: $line"; continue }
        # Blank lines
        elseif ($line.Equals("")) { Write-Debug "Blank line"; continue; }
        # Exclude
        else {
            # convert `/` (unix) to `\` (windows)
            $ExcludesFromFile += $line.Replace("/", "\")
        }
    }
}
#TODO: Global excludes file?

# Process Include folders
if ([System.IO.File]::Exists("$CX_TMP\.cxinclude")) {
    # In the root of the source code
    Write-Host "Processing File :: $CX_TMP\.cxinclude"

    foreach($line in Get-Content "$CX_TMP\.cxinclude") {
        # comments
        if ($line.StartsWith("#")) { Write-Debug "Comment :: $line" }
        # Blank lines
        elseif ($line.Equals("")) { Write-Debug "Blank line" }
        # include
        else {
            $NewPath = Get-Item -Path "$CX_TMP\$line"
            Write-Debug "Include :: $NewPath"
            Write-Debug "Output  :: $CX_OUTPUT\$line"

            # Copy all files in the included/whitelisted directory minus
            # the items that were ignored
            Copy-Item -Path "$NewPath" -Destination "$CX_OUTPUT\$line" -Recurse -Exclude $ExcludesFromFile
        }
    }
}
else {
    Write-Host "No include found in the system..."
}

# Remove excludes
if ([System.IO.File]::Exists("$CX_TMP\.cxexclude")) {
    Write-Host "Excludes :: $ExcludesFromFile"

    # Excluding Dirs only if need be
    if ($ExcludesFromFile.Length -gt 0) {
        foreach($dir in Get-ChildItem "$CX_OUTPUT" -Directory -Recurse) {
            foreach($exclude in $ExcludesFromFile) {
                if ($dir.FullName.EndsWith($exclude)) {
                    Write-Host "Removing the following dir :: $dir"
                    Remove-Item -Path $dir -Recurse -Force
                }
            }
        }
    }
}


# Clean up
if (-not $DisableCleanUp) {
    Write-Host "Cleaning up temp folder..."
    Remove-Item -Path "$CX_TMP" -Recurse
}

Stop-Transcript
