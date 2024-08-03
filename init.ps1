# Define the source and target paths
$sourcePath = "C:\Users\isaac\dev\env\neovim\init.lua"
$targetDir = "$env:LOCALAPPDATA\nvim"
$targetPath = "$targetDir\init.lua"

# Create the target directory if it doesn't exist
if (-not (Test-Path -Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir | Out-Null
    Write-Host "Created directory: $targetDir"
}

# Remove existing file or symlink if it exists
if (Test-Path -Path $targetPath) {
    Remove-Item -Path $targetPath -Force
    Write-Host "Removed existing file or symlink: $targetPath"
}

# Create the symlink
New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath

# Verify the symlink was created successfully
if (Test-Path -Path $targetPath -PathType Leaf) {
    Write-Host "Symlink created successfully: $targetPath -> $sourcePath"
} else {
    Write-Host "Failed to create symlink" -ForegroundColor Red
}
