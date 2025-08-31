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
