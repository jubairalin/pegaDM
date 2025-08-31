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
