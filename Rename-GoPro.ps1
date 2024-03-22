<#
.SYNOPSIS
    Rename GoPro files after retrieving from folders, recursively.

.DESCRIPTION
    This script is used to rename GoPro files that have been retrieved from folders, recursively. It performs the following tasks:
    1. Retrieves GoPro files (videos and pictures) from the specified path.
    2. Moves LRV and THM files to a separate folder.
    3. Moves GoPro pictures to a separate folder.
    4. Renames GoPro videos according to a specific naming convention.
        - Videos are renamed to conform to Windows file sorting conventions. The new file name format is "GoPro-<video group>-<sequence>.MP4". 
        - If a video is GX010203.MP4, it will be renamed to GoPro-203-010.MP4. 203 is the group of the video, and 010 is the sequence of the video. 
        - 203-020 would be the next video. 203-030 would be the next video, and so on.
    5. Moves the renamed GoPro videos to the specified destination path.
        - The videos are moved to a folder named after the video group.

.PARAMETER DestinationPath
    Specifies the destination path where the renamed files will be moved. If not provided, the destination path will be the same as the source path.

.PARAMETER Path
    Specifies the path where the GoPro files are located.

.PARAMETER [switch]Copy
    Indicates whether to copy the renamed GoPro files to the destination path.

.PARAMETER [switch]Move
    Indicates whether to move the renamed GoPro files to the destination path.

.PARAMETER [switch]Recurse
    Indicates whether to search for GoPro files in subfolders.

.PARAMETER [switch]ShowMe
    Displays additional information during the execution of the script. If used, the script will not perform any file operations.

.EXAMPLE
    Rename-GoProFiles -Path "C:\GoProFiles" -Recurse -ShowMe
    Retrieves GoPro files from the "C:\GoProFiles" directory and its subfolders, displays file information, and does not perform any file operations.

.EXAMPLE
    Rename-GoProFiles -Path "C:\GoProFiles" -DestinationPath "D:\RenamedGoProFiles"
    Retrieves GoPro files from the "C:\GoProFiles" directory and renames them according to the specified naming convention. The renamed files are moved to the "D:\RenamedGoProFiles" directory.

.NOTES
    - This script supports GoPro video files with names starting with GX or GG, followed by 6 digits, and ending with .MP4.
    - This script supports GoPro picture files with names starting with GOPR followed by 4 digits, and ending with .JPG or .JPEG.
    - LRV and THM files are moved to a separate folder named "OtherGoProMedia".
    - GoPro pictures are moved to a separate folder named "GoPro Pictures".
    - GoPro videos are renamed according to the naming convention "GoPro-<sequence>-<extension>", where <sequence> is the last 6 digits of the original file name.
#>


param (
    [Parameter(Mandatory = $false)]
    [string]$DestinationPath,

    [Parameter(Mandatory = $true)]
    [string]$Path,
    
    [switch]$Copy,
    [switch]$Move,
    [switch]$Recurse,
    [switch]$ShowMe
)
function Get-GoProFiles {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [switch]$Recurse
    )

    # Get the GoPro file names
    $GoProFileNames = Get-ChildItem -Path $Path -Include *.MP4, *.JPG, *.JPEG -Recurse:$Recurse | Select-Object -Property Name, Directory, Extension

    $GoProVideos = @()
    $GoProPictures = @()

    # Get matching GoPro video file names with regex matching
    $GoProFileNames | ForEach-Object {
        if ($_.Name -match 'G[ghxGHX]\d{6}\.MP4') {
            $GoProVideos += [PSCustomObject]@{
                Name      = $_.Name
                Directory = $_.Directory
                Extension = $_.Extension
            }
        }
        if ($_.Name -match 'GOPR\d{4}\.JP.?G') {
            $GoProPictures += [PSCustomObject]@{
                Name      = $_.Name
                Directory = $_.Directory
                Extension = $_.Extension
            }
        }
    }

    if ($GoProVideos.Count -eq 0) {
        Write-Warning "No GoPro files found in the path: $Path`n"
        $GoProVideos = $false
    }
    if ($GoProPictures.Count -eq 0) {
        Write-Warning "No GoPro pictures found in the path: $Path`n"
        $GoProPictures = $false
    }

    return $GoProVideos, $GoProPictures
}

function Move-GoProLVMTHMFiles {
    param(
        [Parameter(Mandatory = $false)]
        [string]$DestinationPath,

        [Parameter(Mandatory = $true)]
        [string]$Path,

        [switch]$ShowMe
    )

    # Move LRV and THM files to separate folder from other GoPro media
    $OtherGoProFiles = Get-ChildItem -Path $Path -Include "*.lrv", "*.thm" -Recurse:$Recurse | Select-Object -Property Name, Directory

    if ($OtherGoProFiles.Count -eq 0) {
        Write-Warning "No LRV or THM files found in the path: $Path`n"
        return
    }

    if ($ShowMe) {
        Write-Host -ForegroundColor Yellow "`nLRV and THM files found in the path: $Path"
        $OtherGoProFiles | ForEach-Object {
            Write-Host $_.Name
        }
    }
    elseif (!$ShowMe) {
        Write-Host -ForegroundColor Yellow "Moving LRV and THM files to separate folder from other GoPro media..."

        $NewFileDirectory = $DestinationPath + "\" + "Other GoPro Media"
    
        $OtherGoProFiles | ForEach-Object {
            $File = $_
            $OldDirectory = $File.Directory
            $FileDirectory = $OldDirectory.ToString() + "\" + $File.Name.ToString()
            $NewFilePath = $NewFileDirectory + "\" + $File.ToString()
    
            if (-not (Test-Path -Path $NewFileDirectory)) {
                New-Item -Path $NewFileDirectory -ItemType Directory
            }
    
            Write-Verbose `n$FileDirectory
            Write-Verbose $NewFilePath`n
    
            Move-Item -Path $FileDirectory -Destination $NewFilePath
        }
    
        Write-Host -ForegroundColor Green "LRV and THM files moved to $NewFileDirectory"
    }
    else {
        Write-Host -ForegroundColor Red "Shit is broke!"
    }
}

function Move-GoProPictures {
    param (
        [Parameter(Mandatory = $false)]
        [string]$DestinationPath,

        [Parameter(Mandatory = $true)]
        [array]$GoProPictures,

        [Parameter(Mandatory = $true)]
        [string]$Path,

        [switch]$ShowMe
    )

    if ($ShowMe) {
        Write-Host -ForegroundColor Yellow "`nGoPro photos found in path: $Path"
        $GoProPictures | ForEach-Object {
            Write-Host $_.Name
        }
    }
    elseif (!$ShowMe) {
        $NewFileDirectory = $DestinationPath + "\" + "GoPro Pictures"
    
        $GoProPictures | ForEach-Object {
            $File = $_
            $OldDirectory = $File.Directory
            $FileDirectory = $OldDirectory.ToString() + "\" + $File.Name.ToString()
            $NewFilePath = $NewFileDirectory + "\" + $File.ToString()
    
            if (-not (Test-Path -Path $NewFileDirectory)) {
                New-Item -Path $NewFileDirectory -ItemType Directory
            }
    
            Write-Verbose `n$FileDirectory
            Write-Verbose $NewFilePath`n
    
            Move-Item -Path $FileDirectory -Destination $NewFilePath
        }
    
        Write-Host -ForegroundColor Green "GoPro pictures moved to $NewFileDirectory"
    }
    else {
        Write-Host -ForegroundColor DarkGray "Oops... Something went wrong!"
    }
}

function Rename-GoProFiles {
    param (
        [Parameter(Mandatory = $false)]
        [string]$DestinationPath,

        [Parameter(Mandatory = $true)]
        [array]$GoProVideos,

        [Parameter(Mandatory = $true)]
        [string]$Path,

        [switch]$Copy,
        [switch]$Move,
        [switch]$ShowMe
    )

    $NewFileDirectory = $DestinationPath + "\"
    $NewGoProVideoNames = @()

    $GoProVideos | ForEach-Object {
        
        $File = $_
        $FileName = $File.Name
        $FileExtension = $File.Extension
        $OldPrefix = $FileName -replace '\d.*$'
        $GoProSequence = $FileName -replace '.MP4' -replace '\D' 

        if ($OldPrefix -match 'GG|GH|GX') {
            $NewPrefix = "GoPro-"

            if ($GoProSequence.Length -eq 6) {
                # Splits sequence into 2 parts, 3 digits each
                $NewSequence = $GoProSequence -replace '(\d{3})(\d{3})', '$2-$1'
                
            }
            $NewFileName = $NewPrefix + $NewSequence + $FileExtension
        }
        $GoProFix = [pscustomobject]@{
            'Old File Name' = $File.Directory.ToString() + "\" + $FileName.ToString()
            'New Sequence'  = $NewSequence.Split('-')[0]
            'New Directory' = $NewFileDirectory.ToString() + $NewSequence.Split('-')[0]
            'New Filename'  = $NewFileName
        }

        $NewGoProVideoNames += $GoProFix
    }
    $NewGoProVideoNames = $NewGoProVideoNames | Sort-Object -Property 'New Sequence'
    $NewDirectories = $NewGoProVideoNames.'New Directory' | Select-Object -Unique

    if ($ShowMe) {
        Write-Host -ForegroundColor Yellow "`nOld GoPro video names:"
        $GoProVideos | ForEach-Object {
            Write-Host $_.Name
        }
        Write-Host -ForegroundColor Yellow "`nNew GoPro video names:"
        $NewGoProVideoNames
        return
    }
    elseif (!$ShowMe) {
        Write-Host -ForegroundColor Yellow "Renaming GoPro videos..."
        $NewDirectories | ForEach-Object {
            if (-not (Test-Path -Path $_)) {
                New-Item -Path $_ -ItemType Directory
            }
        }
        if ($Copy -and !$Move) {
            $NewGoProVideoNames | ForEach-Object {
                $OldFile = $_.'Old File Name'
                $NewFile = $_.'New Directory' + "\" + $_.'New Filename'
                Copy-Item -Path $OldFile -Destination $NewFile
            }
        }
        elseif ($Move -and !$Copy) {
            $NewGoProVideoNames | ForEach-Object {
                $OldFile = $_.'Old File Name'
                $NewFile = $_.'New Directory' + "\" + $_.'New Filename'
                Move-Item -Path $OldFile -Destination $NewFile
            }
        }       
    }
    else {
        Write-Host "The man is blue!"
    }
}

function Test-NewPath {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    # Checks system for the specified directory and creates it if it doesn't exist
    [System.IO.Directory]::CreateDirectory("$Path") | Out-Null

}

#################
### Main Code ###
#################

if ($Path -and !$DestinationPath) {
    $DestinationPath = $Path
}
else {
    Test-NewPath -Path $DestinationPath
}
if ($Copy -and $Move) {
    Write-Warning "You can't use both the -Copy and -Move switches at the same time. Please use only one switch."
    return
}

# First, get the GoPro files. If the -Recurse switch is used, get the GoPro files from all subfolders.
# This will match any GoPro file name that starts with GX or GG, followed by 6 digits, and ending with .MP4
# This will match any GoPro picture name that starts with GOPR followed by 4 digits, and ending with .JPG
$GoProVideos, $GoProPictures = Get-GoProFiles -Path $Path -Recurse:$Recurse

# Second, move the unneeded LRV and THM files to a separate folder
Move-GoProLVMTHMFiles -Path $Path -DestinationPath $DestinationPath -ShowMe:$ShowMe

# # Debugging
# $GoProVideos
# $GoProPictures

# Third, move the GoPro pictures to a separate folder
if ($GoProPictures -ne $false) {
    Move-GoProPictures -GoProPictures $GoProPictures -Path $Path -DestinationPath $DestinationPath -ShowMe:$ShowMe
}

# Fourth, rename the GoPro videos
if ($GoProVideos -ne $false) {
    Rename-GoProFiles -GoProVideos $GoProVideos -Path $Path -DestinationPath $DestinationPath -ShowMe:$ShowMe -Move:$Move -Copy:$Copy
}
