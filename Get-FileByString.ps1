<#
Author: CPT Lu, TREAD
Input: FILE NAME and STRING to search for
Output: Location and SHA256 hash of FILE containing the STRING
Description: Recursively search the mounted drives for a file named <FILE>, if the file is found, output the file name, location, and SHA256 hash. Search the file for the <STRING>, if the string is found, output a message saying the string was found within the file.

Recursively search all directories in all drives for the FILE
For every file found, search the file for STRING
If the string is found within the file, output FILE location, SHA256 hash, STRING found
If the string is not found within the file, output FILE location, SHA256 hash, And STRING not found

Test conditions:
File to search for: SolarWinds.Orion.Core.BusinessLayer.dll
String: OrionImprovementBusinessLayer
#>


function Get-FileByString {

<#
    .SYNOPSIS
        Creates an in-memory assembly and module
        Author: CPT Lu, TREAD)
        Required Dependencies: None
        Optional Dependencies: None
    .DESCRIPTION
        Input: FILE NAME and STRING to search for.
        Output: Location and SHA256 hash of FILE containing the STRING
        Description: Recursively search the mounted drives for a file named <FILE>, if the file is found, output the file name, location, and SHA256 hash. Search the file for the <STRING>, if the string is found, output a message saying the string was found within the file.

        Recursively search all directories in all drives for the FILE
        For every file found, search the file for STRING
        If the string is found within the file, output FILE location, SHA256 hash, STRING found
         the string is not found within the file, output FILE location, SHA256 hash, And STRING not found

        Test conditions:
        File to search for: SolarWinds.Orion.Core.BusinessLayer.dll
        String: OrionImprovementBusinessLayer
    .PARAMETER ModuleName
        Input: FILE NAME and STRING to search for.
    .EXAMPLE
        Get-FileByString -filename "SolarWinds.Orion.Core.BusinessLayer.dll" -string "OrionImprovementBusinessLayer"
#>

    Param(
        [Parameter(mandatory=$true)]
        [string]$filename,
        [Parameter(mandatory=$true)]
        [string]$string
    )

    #$filename = "SolarWinds.Orion.Core.BusinessLayer.dll"
    #$string = "OrionImprovementBusinessLayer"
    $drives = (Get-PSDrive -PSProvider 'FileSystem').Root

    $found_hashes = @()
    $notfound_hashes = @()
    foreach ($drive in $drives){
        $files = Get-ChildItem -path $drive -Recurse -Filter $filename -ErrorAction SilentlyContinue

        foreach ($file in $files){
            $found_string = $false
            $content = Get-Content -Path $file.FullName

            foreach ($line in $content) {
                if ($line -match $string) {
                    $found_string = $true
                }
            }

            if ($found_string -eq $true) {
                $found_hashes += Get-FileHash -Algorithm SHA256 -Path $file.FullName
            }
            else {
                $notfound_hashes += Get-FileHash -Algorithm SHA256 -Path $file.FullName
            }
        }
    }
    Write-Output "$string is found in the following files:"
    Write-Output $found_hashes
    Write-Output "`n`n----------------------------BREAK-----------------------------------`n`n"
    Write-Output "$string is NOT found in the following files:`n"
    Write-Output $notfound_hashes
}