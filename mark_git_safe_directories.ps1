# Define the root directory of the drives
$C_DRIVE_ROOT = "C:\"
$D_DRIVE_ROOT = "D:\"

$INCLUDED_PATHS = @(
    "C:\stable-diffusion",
    "D:\Portfolio",
    "D:\PortfolioWebGL",
    "D:\Project",
    "D:\Project Assistant",
    "D:\Project Sheening Ash",
    "D:\Random Unity"
    
    # Add more paths as needed
)

$IGNORE_PATTERNS = @(
    "\\node_modules$" ,
    "\\Library$",
    "\\Temp$",
    "\\Builds$",
    "\\Build$",
    "\\Program Files$",
    "\\Program Files (x86)$"

    # Add more patterns as needed
)

# Check if the .git folder exists in the directory
function Check-GitFolder {
    param (
        [string]$Path
    )
 
    $GitFolderPath = Join-Path -Path $Path -ChildPath ".git"

    if (Test-Path -Path $GitFolderPath -PathType Container) {
        return $true
    } else {
        return $false
    }
}

# Function to recursively set safe directory for Git
function Set-SafeDirectory {
    param(
        [string]$DrivePath
    )

    # Set the Drive Path directory as safe
    git config --global --add safe.directory $DrivePath
    Write-Host "Marked directory as safe: $DrivePath"

    # Iterate over each directory in the specified drive path
    Get-ChildItem -Directory $DrivePath | ForEach-Object {
        [string]$Path = $_.FullName 
        # Check if the current directory matches any of the included paths
        if ($INCLUDED_PATHS -contains $Path) {
            # Set current directory as safe
            git config --global --add safe.directory $Path
            Write-Host "Marked directory as safe: $Path"

            # Recursively set safe directory for all subdirectories
            Get-ChildItem -Directory $Path | ForEach-Object {
                Set-SafeSubDirectory $_.FullName
            }
        }
    }
}

# Function to recursively set safe directory for Git
function Set-SafeSubDirectory {
    param(
        [string]$Path
    )

    foreach ($pattern in $IGNORE_PATTERNS) {
        if ($Path -match $pattern) {
            # Write-Host "Skipping directory: $Path ($pattern)"
            return
        }
    }

    if(Check-GitFolder -Path $Path){    
        # Set current directory as safe
        git config --global --add safe.directory $Path
        Write-Host "Marked directory as safe: $Path"
    } 
    # else{
    #     Write-Host "Skipping $Path : Not a Git Directory"
    # }
    
    # Recursively set safe directory for all subdirectories
    Get-ChildItem -Directory $Path | ForEach-Object {
        Set-SafeSubDirectory $_.FullName
    }
}

# Call the function to mark all directories in C drive as safe
Set-SafeDirectory $C_DRIVE_ROOT

# Output message when finished
Write-Host "All directories in C drive marked as safe."

# Call the function to mark all directories in D drive as safe
Set-SafeDirectory $D_DRIVE_ROOT

# Output message when finished
Write-Host "All directories in D drive marked as safe."