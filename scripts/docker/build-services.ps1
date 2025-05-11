# Build and package script for Trading System microservices
# This script builds all .NET microservices and creates Docker images

# Define services as array of arrays: [service_name, custom_image_name]
$services = @(
    @("TradingService", "trading"),
    @("IdentityService", "identity"),
    @("AccountService", "account"), 
    @("RiskService", "risk"),
    @("MarketDataService", "market-data"),
    @("NotificationService", "notification"),
    @("MatchMakingService", "match-making")
)

# Get root directory path (two levels up from script location)
$rootDir = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$builderDir = Join-Path $rootDir "builder"
$releaseDir = Join-Path $builderDir "release"

Write-Host "=== Starting build process for Trading System microservices ==="

foreach ($servicePair in $services) {
    $service = $servicePair[0]      # Original service name
    $imageName = $servicePair[1]    # Custom Docker image name
    
    Write-Host "Building $service (Image: $imageName)..."
    
    # Create or clean output directory
    $outputDir = Join-Path $releaseDir $service
    if (-not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir | Out-Null
    }
    else {
        Remove-Item -Path "$outputDir\*" -Recurse -Force
    }
    
    # Build .NET project with publish
    $projectPath = Join-Path $rootDir "backend\$service\$service.csproj"
    $buildCommand = "dotnet publish '$projectPath' -c Release -o '$outputDir'"
    Write-Host "Executing: $buildCommand"
    Invoke-Expression $buildCommand
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error building $service" -ForegroundColor Red
        exit 1
    }
    
    # Build Docker image with custom naming
    $dockerCommand = "docker build --build-arg SERVICE_NAME=$service -t registry.cn-shanghai.aliyuncs.com/eggybyte-trading-system/${imageName}:latest -f '$builderDir/Dockerfile' '$builderDir'"
    Write-Host "Executing: $dockerCommand"
    Invoke-Expression $dockerCommand
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error building Docker image for $service" -ForegroundColor Red
        exit 1
    }

    # Push Docker image to eggybyte repo
    $dockerPushCommand = "docker push registry.cn-shanghai.aliyuncs.com/eggybyte-trading-system/${imageName}:latest"
    Write-Host "Executing: $dockerPushCommand"
    Invoke-Expression $dockerPushCommand
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error pushing Docker image for $service" -ForegroundColor Red
        exit 1
    }

    Write-Host "$service built and pushed as 'eggybyte/${imageName}:latest'" -ForegroundColor Green
}

Write-Host "=== All services built and packaged successfully! ===" -ForegroundColor Green