# Vars
$artifactDir  = "F:\Pipeline\EDI_DEV\EDIConfig"   # Path where artifacts are published
$ediDir       = "C:\edi"                          # Local EDI directory on agent
$backupDir    = "C:\edi\backups"                  # Backup folder

# Ensure backup directory exists
if (!(Test-Path -Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}

# Get all existing *.properties files in C:\edi
$localFiles = Get-ChildItem -Path $ediDir -Filter "*_EDIControl.properties" -File

foreach ($localFile in $localFiles) {
    $fileName = $localFile.Name
    $artifactFile = Join-Path $artifactDir $fileName

    if (Test-Path $artifactFile) {
        # Backup existing file with timestamp
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupFile = Join-Path $backupDir ("{0}.{1}.bak" -f $fileName, $timestamp)
        Copy-Item $localFile.FullName $backupFile -Force

        Write-Host "Backed up $fileName to $backupFile"

        # Replace file with artifact version
        Copy-Item $artifactFile $localFile.FullName -Force
        Write-Host "Replaced $fileName from artifact directory"
    }
    else {
        Write-Host "No matching artifact found for $fileName"
    }
}
-----
# Vars
$artifactDir  = "F:\Pipeline\EDI_DEV\EDIConfig"   # Path where artifacts are published
$ediDir       = "C:\edi"                          # Local EDI directory on agent
$backupDir    = "C:\edi\backups"                  # Backup folder

# Ensure backup directory exists
if (!(Test-Path -Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}

# Get all existing *.properties files in C:\edi
$localFiles = Get-ChildItem -Path $ediDir -Filter "*_EDIControl.properties" -File

foreach ($localFile in $localFiles) {
    $fileName   = $localFile.Name
    $artifactFile = Join-Path $artifactDir $fileName

    if (Test-Path $artifactFile) {
        # Build backup file name with timestamp, keeping .properties extension
        $timestamp   = Get-Date -Format "yyyyMMdd_HHmmss"
        $baseName    = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
        $extension   = $localFile.Extension
        $backupFile  = Join-Path $backupDir ("{0}_{1}{2}" -f $baseName, $timestamp, $extension)

        # Backup existing file
        Copy-Item $localFile.FullName $backupFile -Force
        Write-Host "Backed up $fileName to $backupFile"

        # Replace file with artifact version
        Copy-Item $artifactFile $localFile.FullName -Force
        Write-Host "Replaced $fileName from artifact directory"
    }
--------------------
# 6) Copy EDIConfig to Artifacts
- task: PowerShell@2
  displayName: 'Copy EDIConfig to Artifacts'
  inputs:
    targetType: 'inline'
    script: |
      # Define source and destination
      $sourceDir = "$(Build.SourcesDirectory)/EDIConfig"
      $stagingDir = "$(Build.ArtifactStagingDirectory)/EDIConfig"

      Write-Host "Source Directory: $sourceDir"
      Write-Host "Staging Directory: $stagingDir"

      # Create staging folder if not exists
      New-Item -ItemType Directory -Force -Path $stagingDir | Out-Null

      # Copy complete EDIConfig folder structure
      Copy-Item -Path $sourceDir\* -Destination $stagingDir -Recurse -Force

  failOnStderr: true

# 7) Publish Artifact
- task: PublishBuildArtifacts@1
  displayName: 'Publish EDIConfig Artifact'
  inputs:
    PathtoPublish: '$(Build.ArtifactStagingDirectory)/EDIConfig'
    ArtifactName: 'EDI_DEV'
    publishLocation: 'Container'
------------------

# ==========================================
# Script: Deploy EDIControl Properties
# ==========================================

# 1. Get Hostname of the running agent
$hostname = $env:COMPUTERNAME
Write-Host "Detected Hostname: $hostname"

# 2. Define base directories
$ediDir     = "C:\edi"
$backupDir  = "C:\edi\backups"
$artifactRoot = "$(Pipeline.Workspace)\drop\EDIConfig"   # base path where artifact is downloaded

# Ensure backup directory exists
if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
}

# 3. Find all ControlProperties folders for the hostname across ALL environments
$controlDirs = Get-ChildItem -Path $artifactRoot -Directory -Recurse |
    Where-Object { $_.FullName -like "*\$hostname\ControlProperties" }

if (-not $controlDirs) {
    Write-Host "No matching ControlProperties folder found for hostname: $hostname"
    exit 1
}

foreach ($controlDir in $controlDirs) {
    Write-Host "Processing directory: $($controlDir.FullName)"

    # Get all *_EDIControl.properties files from artifact
    $artifactFiles = Get-ChildItem -Path $controlDir.FullName -Filter "*_EDIControl.properties" -File

    foreach ($artifactFile in $artifactFiles) {
        $targetFile = Join-Path $ediDir $artifactFile.Name

        if (Test-Path $targetFile) {
            # 4. Backup existing file
            $timestamp = Get-Date -Format "yyyyMMddHHmmss"
            $backupFile = Join-Path $backupDir ("{0}_{1}.bak" -f $artifactFile.BaseName, $timestamp)
            Copy-Item -Path $targetFile -Destination $backupFile -Force
            Write-Host "Backed up: $targetFile -> $backupFile"
        }

        # 5. Copy artifact file to edi directory (replace existing)
        Copy-Item -Path $artifactFile.FullName -Destination $targetFile -Force
        Write-Host "Deployed new file: $artifactFile.Name to $ediDir"
    }
}

Write-Host "Deployment completed successfully."
