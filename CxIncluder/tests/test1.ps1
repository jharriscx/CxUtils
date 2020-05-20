
$OUTPUT = "$PSScriptRoot\output"
$OUTPUT_TMP = "$OUTPUT\_cxtmp"

##### Setup #####
New-Item -ItemType Directory -Force -Path "$OUTPUT" | Out-Null

# Clone test repo
if (-not (Test-Path $OUTPUT_TMP)) {
    git clone -b "master" --depth=1 https://github.com/gatsbyjs/gatsby.git "$OUTPUT_TMP"
}

Copy-Item -Path "$PSScriptRoot/../examples/.cxinclude" -Destination "$OUTPUT_TMP\.cxinclude" | Out-Null
Copy-Item -Path "$PSScriptRoot/../examples/.cxexclude" -Destination "$OUTPUT_TMP\.cxexclude" | Out-Null

Push-Location -Path "$OUTPUT"

Write-Host "Working Dir :: $($(Get-Location).Path)"
Write-Host " ========== Running Script =========="

../../scripts/includer.ps1 `
    -Git_URL https://github.com/gatsbyjs/gatsby.git `
    -Cx_Logs "../logs" `
    -DisableCleanUp


##### Tests #####

Write-Host " ========== Running Tests =========="

if (Test-Path "$OUTPUT\packages\gatsby-cli\src\__tests__") {
    Write-Error "[Failed] '__tests__' folder is present"
} else { Write-Host "[Passed] __tests__" }

# Remove dirs by full path
if (Test-Path "$OUTPUT\packages\gatsby\scripts") {
    Write-Error "[Failed] 'gatsby\scripts' folder is present"
} else { Write-Host "[Passed] gatsby\scripts" }

Write-Host $OUTPUT\packages\gatsby-cli\gatsby-cli\scripts
if (Test-Path "$OUTPUT\packages\gatsby-cli\gatsby-cli\scripts") {
    Write-Host "[Passed] gatsby-cli\scripts"
} else {
    Write-Error "[Failed] 'gatsby-cli\scripts' folder has been removed"
}



##### Clean up #####
Write-Host " ========== Cleaning Up =========="

Pop-Location

# Remove-Item -Path "$OUTPUT" -Recurse -Force
