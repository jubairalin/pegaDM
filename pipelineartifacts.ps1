- task: DownloadPipelineArtifact@2
  inputs:
    buildType: 'specific'
    project: '$(System.TeamProjectId)'
    definition: '<Your_Build_Pipeline_ID>'
    buildVersionToDownload: 'latest'
    artifactName: 'EDI_DEV'
    targetPath: '$(Pipeline.Workspace)/DownloadedArtifacts'

----------------------

param(
  [string]$AppName,
  [string]$PackageName,
  [string]$SourceRoot,
  [string]$DestinationDir
)

# Defaults if not provided
if (-not $AppName)        { $AppName = 'AirShipmt' }
if (-not $PackageName)    { $PackageName = 'AirShipmtBusiness' }
if (-not $SourceRoot)     { $SourceRoot = 'C:\azagent\a1\vsts-agent-win-x64-2.217.2\_work\2\a' }
if (-not $DestinationDir) { $DestinationDir = 'F:\edi\Project1\AirShipmt\classes\AirShipmtBusiness' }

$ErrorActionPreference = 'Stop'

# 1) Check for both possible paths
$path1 = Join-Path $SourceRoot 'EDI_TEST'
$path2 = Join-Path (Join-Path $SourceRoot '_EDI_DEV') 'EDI_TEST'

if (Test-Path $path1) {
    $artifactRoot = $path1
}
elseif (Test-Path $path2) {
    $artifactRoot = $path2
}
else {
    Write-Host "❌ Neither $path1 nor $path2 exists."
    exit 1
}

Write-Host "✅ Using artifact root: $artifactRoot"

# 2) Find the latest build folder: App_Package_*
$buildFolder = Get-ChildItem -Path $artifactRoot -Directory -Filter ("{0}_{1}_*" -f $AppName, $PackageName) |
               Sort-Object LastWriteTime -Descending |
               Select-Object -First 1

if (-not $buildFolder) {
    Write-Host "❌ No build folder found in $artifactRoot for $AppName/$PackageName"
    exit 1
}

# 3) Build SourceDir
$SourceDir = Join-Path $buildFolder.FullName $PackageName
if (-not (Test-Path $SourceDir)) {
    Write-Host "❌ Source package folder not found: $SourceDir"
    exit 1
}

# 4) Copy files
Write-Host "✅ Verified source package: $SourceDir"
Write-Host "📂 Copying *.class files to: $DestinationDir"
Copy-Item -Path (Join-Path $SourceDir '*.class') -Destination $DestinationDir -Force
Write-Host "✅ Done!"

