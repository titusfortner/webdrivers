$downloadLink = "https://go.microsoft.com/fwlink/?linkid=2108834&Channel=Stable&language=en"
$installerFile = "C:\MicrosoftEdgeSetup.exe"

#  Note: We're purposely skipping the -Wait flag in Start-Process.
#  This is because Edge auto-launches after the setup is done and
#  Start-Process continues to indefinitely wait on that process.
Write-Host "Downloading Microsoft Edge (Stable)..." -ForegroundColor cyan
Invoke-WebRequest $downloadLink -OutFile $installerFile
Write-Host "Installing..." -ForegroundColor cyan
Start-Process $installerFile
Write-Host "Microsoft Edge (Stable) installed.`n" -ForegroundColor green