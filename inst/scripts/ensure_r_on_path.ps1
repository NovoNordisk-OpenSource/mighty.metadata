# Setup script to add R to path before running R commands
# This file is called before executing any R commands to ensure R is properly on the PATH

function Add-R-To-Path {
    # Check if R is already on the path
    $rOnPath = $false
    try {
        $rCmd = Get-Command Rscript -ErrorAction Stop
        $rOnPath = $true
        Write-Host "R is already on path: $($rCmd.Source)"
    } catch {
        $rOnPath = $false
    }

    # If R is not on the path, add it
    if (-not $rOnPath) {
        Write-Host "Adding R to PATH"
        $env:PATH += ";C:/R/R-4.3.1/bin"
        # Also set it for the current user to persist across sessions
        [System.Environment]::SetEnvironmentVariable('PATH', $env:PATH, [System.EnvironmentVariableTarget]::User)
    }
    
    # Verify R is now on the path
    try {
        $rCmd = Get-Command Rscript -ErrorAction Stop
        Write-Host "R is now available at: $($rCmd.Source)"
        return $true
    } catch {
        Write-Host "Failed to add R to PATH"
        return $false
    }
}

# Run the function
Add-R-To-Path
