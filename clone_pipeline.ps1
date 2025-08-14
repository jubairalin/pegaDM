# ============================
# CONFIGURATION - UPDATE THESE
# ============================
$PegaBaseUrl       = "https://pega.example.com/prweb"   # Base URL to your Pega DM
$ClientId          = "dm-client"
$ClientSecret      = "dm-secret"
$Username          = "admin@dm"
$Password          = "rules"
$SourcePipelineId  = "1234"                             # ID of existing pipeline to copy
$NewPipelineName   = "Cloned Pipeline $(Get-Date -Format 'yyyyMMddHHmmss')"

# ============================
# STEP 1 - GET OAUTH TOKEN
# ============================
Write-Host "[INFO] Requesting OAuth token..."
$TokenResponse = Invoke-RestMethod -Method Post -Uri "$PegaBaseUrl/PRRestService/oauth2/v1/token" `
    -Headers @{ "Content-Type" = "application/x-www-form-urlencoded" } `
    -Body @{
        grant_type    = "password"
        client_id     = $ClientId
        client_secret = $ClientSecret
        username      = $Username
        password      = $Password
    }

if (-not $TokenResponse.access_token) {
    Write-Host "[ERROR] Failed to get access token" -ForegroundColor Red
    exit 1
}

$AccessToken = $TokenResponse.access_token
Write-Host "[INFO] Got OAuth token"

# ============================
# STEP 2 - FETCH EXISTING PIPELINE
# ============================
Write-Host "[INFO] Fetching pipeline with ID: $SourcePipelineId"
$OriginalPipeline = Invoke-RestMethod -Method Get -Uri "$PegaBaseUrl/api/v1/pipelines/$SourcePipelineId" `
    -Headers @{
        "Accept"        = "application/json"
        "Authorization" = "Bearer $AccessToken"
    }

# ============================
# STEP 3 - MODIFY PIPELINE JSON
# ============================
Write-Host "[INFO] Modifying pipeline name to: $NewPipelineName"
$OriginalPipeline.name = $NewPipelineName
$NewPipelineJson = $OriginalPipeline | ConvertTo-Json -Depth 10

# ============================
# STEP 4 - CREATE NEW PIPELINE
# ============================
Write-Host "[INFO] Creating new pipeline..."
$CreateResponse = Invoke-RestMethod -Method Post -Uri "$PegaBaseUrl/api/v1/pipelines" `
    -Headers @{
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
        "Authorization" = "Bearer $AccessToken"
    } `
    -Body $NewPipelineJson

Write-Host "[INFO] Create Pipeline Response:" -ForegroundColor Cyan
$CreateResponse | ConvertTo-Json -Depth 10

Write-Host "[SUCCESS] Pipeline creation complete!" -ForegroundColor Green
