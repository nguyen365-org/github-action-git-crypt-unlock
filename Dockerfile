# Use the latest Long-Term Servicing Channel for Windows Server Core
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set the default shell to PowerShell
SHELL ["powershell", "-Command"]

# Bypass execution policy to install Scoop and packages
RUN Set-ExecutionPolicy Bypass -Scope Process -Force;

# Install Scoop package manager
RUN Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh'); `
    # Add Scoop to the PATH for the current session and future sessions
    $env:PATH = [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Machine) + ';' + [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::User); `
    [System.Environment]::SetEnvironmentVariable('PATH', $env:PATH, [System.EnvironmentVariableTarget]::Machine);

# Install Git using Scoop
RUN scoop install git --global; `
    # Refresh environment variables to include Git path
    $env:PATH = [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Machine); `
    Write-Host "Updated PATH: $env:PATH"

# Install git-crypt using Scoop
# Need to add the 'extras' bucket first as git-crypt is located there
RUN scoop bucket add extras; `
    scoop install git-crypt --global; `
    # Refresh environment variables again if necessary (though scoop install --global should handle it)
    $env:PATH = [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Machine); `
    Write-Host "Updated PATH after git-crypt: $env:PATH"

# Copy the entrypoint script into the container
ADD entrypoint.ps1 /entrypoint.ps1

# Set the entrypoint script to run when the container starts
ENTRYPOINT ["powershell", "-File", "/entrypoint.ps1"]

# Optional: Verify installations (useful for debugging)
# RUN git --version
# RUN git-crypt --version
