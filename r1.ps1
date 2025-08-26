Write-Host "Environment variables: $(AGENT.RELEASEDIRECTORY)"

# Define paths
$releasePath = "_NEBRAS-EDI/edi-maven-artifact/config/application_tstedicoreneb01.properties"
$sourceFile = Join-Path "$(AGENT.RELEASEDIRECTORY)" $releasePath
$destinationFile = "F:\certscan\application.properties"
$backupPath = "F:\certscan\backup\"

Write-Host "Source: $sourceFile"
Write-Host "Destination: $destinationFile"

# Debug: Show properties files
Get-ChildItem "$(AGENT.RELEASEDIRECTORY)" -Recurse -File -Filter "*.properties" | 
    ForEach-Object { Write-Host "FOUND: $($_.FullName)" }

# Find source file
if (-not (Test-Path $sourceFile)) {
    Write-Host "Source not found, searching alternatives..."
    $altFile = Get-ChildItem "$(AGENT.RELEASEDIRECTORY)" -Recurse -File -Filter "*.properties" | Select-Object -First 1
    if ($altFile) {
        $sourceFile = $altFile.FullName
        Write-Host "Using alternative: $sourceFile"
    } else {
        throw "No properties files found in artifact"
    }
}

# Create backup directory
if (-not (Test-Path $backupPath)) {
    New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
}

# Backup existing file
if (Test-Path $destinationFile) {
    $backupFile = Join-Path $backupPath "application.properties.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item $destinationFile $backupFile -Force
    Write-Host "Backup created: $backupFile"
}

# Copy file and verify
Copy-Item -Path $sourceFile -Destination $destinationFile -Force
if (Test-Path $destinationFile) {
    $fileSize = (Get-Item $destinationFile).Length
    Write-Host "Deployed successfully! Size: $fileSize bytes"
    Write-Host "Preview (first 3 lines):"
    Get-Content $destinationFile -Head 3 | ForEach-Object { Write-Host "  $_" }
} else {
    throw "Deployment failed - file not found at destination"
}

Write-Host "Deployment completed!"
