# Define the mandatory parameter for the Base64 encoded private key
param (
    [Parameter(Mandatory = $true)]
    [string]$GIT_CRYPT_PRIVATE_KEY_BASE64
)

# Define the path for the temporary private key file
$privateKeyPath = "./private-key.key"

Write-Host "Decoding Base64 private key..."
try {
    # Decode the Base64 string into bytes
    $privateKeyBytes = [System.Convert]::FromBase64String($GIT_CRYPT_PRIVATE_KEY_BASE64)

    # Write the raw bytes directly to the key file
    # This is crucial as private keys are binary data, not necessarily valid UTF-8 strings
    [System.IO.File]::WriteAllBytes($privateKeyPath, $privateKeyBytes)

    Write-Host "Private key decoded and saved to $privateKeyPath"

    # Run git-crypt unlock using the decoded private key file
    Write-Host "Running git-crypt unlock..."
    # Ensure git-crypt is in the PATH or provide the full path if needed
    # Scoop usually adds it to the path during installation.
    & git-crypt unlock $privateKeyPath
    if ($LASTEXITCODE -ne 0) {
        Write-Error "git-crypt unlock failed with exit code $LASTEXITCODE"
        exit $LASTEXITCODE
    }
    Write-Host "git-crypt unlock successful."

} catch {
    Write-Error "An error occurred during key decoding or git-crypt unlock: $_"
    # Ensure the key file is removed even if an error occurs before unlock
    if (Test-Path $privateKeyPath) {
        Write-Host "Removing temporary private key file due to error..."
        Remove-Item $privateKeyPath -Force
    }
    exit 1 # Exit with a non-zero code to indicate failure
} finally {
    # Securely remove the temporary private key file after use (or if an error occurred)
    if (Test-Path $privateKeyPath) {
        Write-Host "Removing temporary private key file..."
        Remove-Item $privateKeyPath -Force
    }
}

Write-Host "Action completed successfully."
exit 0 # Explicitly exit with 0 for success
