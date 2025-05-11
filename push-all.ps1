# Define submodule paths
$frontendSubmodulePath = "frontend"
$backendSubmodulePath = "backend"

# Set the author name for all commits
$authorName = "John Feng"

# Function to get current timestamp in specified format
function Get-Timestamp {
    return (Get-Date -Format 'yyyyMMdd-HHmmss')
}

# Function to commit changes with timestamped message
function Commit-Changes {
    param (
        [string]$path,
        [string]$messagePrefix = ""
    )
    
    Set-Location -Path $path
    
    # Add all changes
    git add .
    
    # Create timestamped commit message
    $timestamp = Get-Timestamp
    if ($messagePrefix) {
        $commitMessage = "$messagePrefix - $authorName $timestamp"
    }
    else {
        $commitMessage = "$authorName $timestamp"
    }
    
    # Commit changes
    git commit -m $commitMessage
    
    # Push changes to main branch
    git push origin HEAD:main
    
    # Return to parent directory
    Set-Location -Path ..
}

# Commit and push frontend submodule changes
Commit-Changes -path $frontendSubmodulePath

# Commit and push backend submodule changes
Commit-Changes -path $backendSubmodulePath

# Return to main repository directory
Set-Location -Path .

# Update main repository references to submodules
git add .

# Create timestamped commit message for main repository
$timestamp = Get-Timestamp
$mainCommitMessage = "$authorName $timestamp"

# Commit changes in main repository
git commit -m $mainCommitMessage

# Push changes to main branch of main repository
git push origin HEAD:main

Write-Host "All changes have been pushed successfully."