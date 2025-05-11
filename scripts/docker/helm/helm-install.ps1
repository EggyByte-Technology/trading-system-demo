#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Simplified Helm chart deployment script with automatic namespace creation.

.DESCRIPTION
    Streamlined deployment using Helm with minimal pre-checks and automatic namespace handling.
    Simply verifies chart directories exist and runs helm upgrade --install with --create-namespace.

.PARAMETER Charts
    Charts to deploy. Default: "prometheus", "trading-system"

.PARAMETER NamespaceMap
    Namespace mapping. Default: @{prometheus="monitoring"; "trading-system"="trading-system"}

.PARAMETER Values
    Custom values files (hashtable)

.PARAMETER HelmArgs
    Additional Helm arguments

.EXAMPLE
    ./helm-install.ps1 -Values @{"trading-system"="prod-values.yaml"}
#>

param(
    [string[]] $Charts = @("mongodb-sharded", "trading-system"),
    [hashtable] $NamespaceMap = @{
        "mongodb-sharded" = "database";
        "trading-system"  = "trading-system";
    },
    [hashtable] $Values = @{},
    [string] $HelmArgs = ""
)

$Colors = @{
    Success = "Green"
    Error   = "Red"
    Info    = "Cyan"
}

$ScriptDir = $PSScriptRoot

function Test-Prerequisites {
    Write-Host "`n[Precheck] Verifying system requirements..." -ForegroundColor $Colors.Info
    
    # Verify Helm exists
    if (-not (Get-Command helm -ErrorAction SilentlyContinue)) {
        Write-Host "[Error] Helm not found in PATH" -ForegroundColor $Colors.Error
        exit 1
    }
    
    # Validate chart directories
    foreach ($chart in $Charts) {
        $chartPath = Join-Path $ScriptDir $chart
        if (-not (Test-Path $chartPath)) {
            Write-Host "[Error] Missing chart: $chartPath" -ForegroundColor $Colors.Error
            exit 1
        }
    }
    
    Write-Host "[Precheck] All requirements satisfied`n" -ForegroundColor $Colors.Success
}

function Install-Chart {
    param (
        [string]$ChartName,
        [string]$Namespace,
        [string]$ValuesFile
    )

    try {
        Write-Host "`n[Deploy] Starting deployment: $ChartName" -ForegroundColor $Colors.Info
        
        $chartPath = Join-Path $ScriptDir $ChartName
        $baseCmd = "helm upgrade --install $ChartName '$chartPath' --namespace $Namespace --create-namespace"
        
        # Add values file if specified
        if ($ValuesFile -and (Test-Path $ValuesFile)) {
            $baseCmd += " -f `"$ValuesFile`""
        }

        # Append additional arguments
        if ($HelmArgs) {
            $baseCmd += " $HelmArgs"
        }

        Write-Host "Executing: $baseCmd" -ForegroundColor $Colors.Info
        Invoke-Expression $baseCmd
        
        if ($LASTEXITCODE -ne 0) {
            throw "Helm deployment failed with exit code $LASTEXITCODE"
        }

        Write-Host "[Success] $ChartName deployed to $Namespace`n" -ForegroundColor $Colors.Success
    }
    catch {
        Write-Host "[Error] Failed to deploy $ChartName : $_" -ForegroundColor $Colors.Error
        exit 1
    }
}

# Main execution flow
try {
    Test-Prerequisites

    foreach ($chart in $Charts) {
        $namespace = $NamespaceMap[$chart]
        $valuesFile = $Values[$chart]
        
        Install-Chart -ChartName $chart -Namespace $namespace -ValuesFile $valuesFile
    }

    Write-Host "`n[Summary] All charts deployed successfully!" -ForegroundColor $Colors.Success
}
catch {
    Write-Host "`n[Fatal] Deployment aborted: $_" -ForegroundColor $Colors.Error
    exit 1
}