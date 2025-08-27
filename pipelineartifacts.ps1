- task: DownloadPipelineArtifact@2
  inputs:
    buildType: 'specific'
    project: '$(System.TeamProjectId)'
    definition: '<Your_Build_Pipeline_ID>'
    buildVersionToDownload: 'latest'
    artifactName: 'EDI_DEV'
    targetPath: '$(Pipeline.Workspace)/DownloadedArtifacts'
