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
