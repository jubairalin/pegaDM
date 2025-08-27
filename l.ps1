# ==============================
# Variables
# ==============================
$PackageName     = "AirShipmtBusiness"   # Package name to verify
$SourceDir       = "C:\vsts-agent-win-x64-2.217.2\_work\2\a\EDI_DEV\EDI_TEST\AirShipmtBusiness_20250826.142233_build152\AirShipmtBusiness"
$DestinationDir  = "F:\edi\Project1\AirShipmt\classes\AirShipmtBusiness"

# ==============================
# Validation
# ==============================
if ((Split-Path $SourceDir -Leaf) -eq $PackageName -and (Split-Path $DestinationDir -Leaf) -eq $PackageName) {
    Write-Host "Package names match. Copying files..."
    Copy-Item -Path "$SourceDir\*" -Destination $DestinationDir -Force
    Write-Host "Files copied successfully to $DestinationDir"
}
else {
    Write-Host "Package name mismatch. No files copied."
}
----------------
# ==============================
# Variables
# ==============================
$PackageName    = "AirShipmtBusiness"   # Package name to verify

# Example paths (update these as per runtime values)
$SourceDir      = "C:\vsts-agent-win-x64-2.217.2\_work\2\a\EDI_DEV\EDI_TEST\AirShipmtBusiness_20250826.142233_build152\AirShipmtBusiness"
$DestinationDir = "F:\edi\Project1\AirShipmt\classes\AirShipmtBusiness"

# ==============================
# Logic
# ==============================

# Get the last folder names from both paths
$SourceLastFolder      = Split-Path $SourceDir -Leaf
$DestinationLastFolder = Split-Path $DestinationDir -Leaf

if ($SourceLastFolder -eq $PackageName -and $DestinationLastFolder -eq $PackageName) {
    Write-Host "✅ Package names match. Copying files..."
    Copy-Item -Path (Join-Path $SourceDir '*') -Destination $DestinationDir -Force
    Write-Host "✅ Files copied successfully to $DestinationDir"
}
else {
    Write-Host "❌ Package name mismatch!"
    Write-Host "Source last folder: $SourceLastFolder"
    Write-Host "Destination last folder: $DestinationLastFolder"
    Write-Host "Expected package name: $PackageName"
}
----------------
# ==============================
# Variables
# ==============================
$PackageName    = "AirShipmtBusiness"   # Package name to verify

# Root paths (adjust as needed)
$SourceRoot      = "C:\vsts-agent-win-x64-2.217.2\_work\2\a\EDI_DEV\EDI_TEST"
$DestinationDir  = "F:\edi\Project1\AirShipmt\classes\AirShipmtBusiness"

# ==============================
# Find the latest build folder dynamically
# ==============================

# Get the newest folder that starts with "$PackageName_" and contains $PackageName subfolder
$LatestSourceDir = Get-ChildItem -Path $SourceRoot -Directory |
    Where-Object { $_.Name -like "$PackageName*" } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1 |
    ForEach-Object { Join-Path $_.FullName $PackageName }

# ==============================
# Validation and Copy
# ==============================

if (-not $LatestSourceDir) {
    Write-Host "❌ No source folder found for $PackageName under $SourceRoot"
    exit 1
}

$SourceLastFolder      = Split-Path $LatestSourceDir -Leaf
$DestinationLastFolder = Split-Path $DestinationDir -Leaf

if ($SourceLastFolder -eq $PackageName -and $DestinationLastFolder -eq $PackageName) {
    Write-Host "✅ Package names match. Copying *.class files..."
    Copy-Item -Path (Join-Path $LatestSourceDir '*.class') -Destination $DestinationDir -Force
    Write-Host "✅ Class files copied successfully from:`n$LatestSourceDir`n to:`n$DestinationDir"
}
else {
    Write-Host "❌ Package name mismatch!"
    Write-Host "Source last folder: $SourceLastFolder"
    Write-Host "Destination last folder: $DestinationLastFolder"
    Write-Host "Expected package name: $PackageName"
}
---------------

param(
  [string]$AppName        = 'AirShipmt',
  [string]$PackageName    = 'AirShipmtBusiness',
  [string]$SourceRoot     = 'C:\vsts-agent-win-x64-2.217.2\_work\2\a\EDI_DEV\EDI_TEST',
  [string]$DestinationDir = 'F:\edi\Project1\AirShipmt\classes\AirShipmtBusiness'
)

$ErrorActionPreference = 'Stop'

# 1) Find the latest build folder like "<AppName>_<PackageName>_*"
$buildFolder = Get-ChildItem -Path $SourceRoot -Directory -Filter ("{0}_{1}_*" -f $AppName, $PackageName) |
               Sort-Object LastWriteTime -Descending |
               Select-Object -First 1

if (-not $buildFolder) {
    Write-Host "❌ No build folder found in $SourceRoot for $AppName/$PackageName"
    exit 1
}

# 2) Build source path (it must contain the PackageName folder)
$SourceDir = Join-Path $buildFolder.FullName $PackageName
if (-not (Test-Path $SourceDir)) {
    Write-Host "❌ Source package folder not found: $SourceDir"
    exit 1
}

# 3) Verify Source & Destination names
$SourceAppName     = ($buildFolder.Name -split '_')[0]     # "AirShipmt"
$SourcePackageName = Split-Path $SourceDir -Leaf           # "AirShipmtBusiness"

$DestPackageName   = Split-Path $DestinationDir -Leaf      # "AirShipmtBusiness"
$DestAppName       = Split-Path (Split-Path (Split-Path $DestinationDir -Parent) -Parent) -Leaf  # "AirShipmt"

if ($SourceAppName -eq $AppName -and
    $SourcePackageName -eq $PackageName -and
    $DestAppName -eq $AppName -and
    $DestPackageName -eq $PackageName) {

    Write-Host "✅ Verified match for AppName='$AppName' and PackageName='$PackageName'"
    Write-Host "📂 Copying *.class files from:`n $SourceDir`n to:`n $DestinationDir"

    Copy-Item -Path (Join-Path $SourceDir '*.class') -Destination $DestinationDir -Force
    Write-Host "✅ Done!"
}
else {
    Write-Host "❌ AppName/PackageName mismatch! Copy aborted."
    Write-Host " Source AppName:     $SourceAppName"
    Write-Host " Source PackageName: $SourcePackageName"
    Write-Host " Dest AppName:       $DestAppName"
    Write-Host " Dest PackageName:   $DestPackageName"
}
----------------
# Backup DestinationDir to a timestamped folder

$DestinationDir = 'F:\edi\Project1'
$BackupRoot     = 'F:\edi\Backups'   # Change if you want backups somewhere else

# Ensure backup root exists
if (-not (Test-Path $BackupRoot)) {
    New-Item -ItemType Directory -Path $BackupRoot | Out-Null
}

# Generate folder name with current date/time
$timestamp   = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupDir   = Join-Path $BackupRoot ("Project1_Backup_" + $timestamp)

# Create backup folder
New-Item -ItemType Directory -Path $BackupDir | Out-Null

# Copy files
Write-Host "📂 Backing up '$DestinationDir' to '$BackupDir' ..."
Copy-Item -Path (Join-Path $DestinationDir '*') -Destination $BackupDir -Recurse -Force

Write-Host "✅ Backup completed: $BackupDir"
-----------------

param(
  [string]$AppName,
  [string]$PackageName,
  [string]$SourceRoot,
  [string]$DestinationDir
)

# Set defaults if not provided
if (-not $AppName)        { $AppName = 'AirShipmt' }
if (-not $PackageName)    { $PackageName = 'AirShipmtBusiness' }
if (-not $SourceRoot)     { $SourceRoot = 'C:\vsts-agent-win-x64-2.217.2\_work\2\a\EDI_TEST' }
if (-not $DestinationDir) { $DestinationDir = 'F:\edi\Project1\AirShipmt\classes\AirShipmtBusiness' }

$ErrorActionPreference = 'Stop'

# 1) Find the latest build folder
$buildFolder = Get-ChildItem -Path $SourceRoot -Directory -Filter ("{0}_{1}_*" -f $AppName, $PackageName) |
               Sort-Object LastWriteTime -Descending |
               Select-Object -First 1

if (-not $buildFolder) {
    Write-Host "❌ No build folder found in $SourceRoot for $AppName/$PackageName"
    exit 1
}

# 2) Build source path
$SourceDir = Join-Path $buildFolder.FullName $PackageName
if (-not (Test-Path $SourceDir)) {
    Write-Host "❌ Source package folder not found: $SourceDir"
    exit 1
}

# 3) Verify names
$SourceAppName     = ($buildFolder.Name -split '_')[0]
$SourcePackageName = Split-Path $SourceDir -Leaf

$DestPackageName   = Split-Path $DestinationDir -Leaf
$DestAppName       = Split-Path (Split-Path (Split-Path $DestinationDir -Parent) -Parent) -Leaf

if ($SourceAppName -eq $AppName -and
    $SourcePackageName -eq $PackageName -and
    $DestAppName -eq $AppName -and
    $DestPackageName -eq $PackageName) {

    Write-Host "✅ Verified match for AppName='$AppName' and PackageName='$PackageName'"
    Write-Host "📂 Copying *.class files from:`n $SourceDir`n to:`n $DestinationDir"

    Copy-Item -Path (Join-Path $SourceDir '*.class') -Destination $DestinationDir -Force
    Write-Host "✅ Done!"
}
else {
    Write-Host "❌ AppName/PackageName mismatch! Copy aborted."
    Write-Host " Source AppName:     $SourceAppName"
    Write-Host " Source PackageName: $SourcePackageName"
    Write-Host " Dest AppName:       $DestAppName"
    Write-Host " Dest PackageName:   $DestPackageName"
}
