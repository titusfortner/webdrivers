$downloadDevLink = "https://go.microsoft.com/fwlink/?linkid=2069324&Channel=Dev&language=en-us&Consent=0&IID=85213fc4-6a13-57ae-9082-72910982ede8"
$downloadCanaryLink = "https://go.microsoft.com/fwlink/?linkid=2084706&Channel=Canary&language=en-us&Consent=0&IID=85213fc4-6a13-57ae-9082-72910982ede8"
$devSetup = "C:\MicrosoftEdgeSetupDev.exe"
$canarySetup = "C:\MicrosoftEdgeSetupCanary.exe"

#  Note: We're purposely skipping the -Wait flag in Start-Process.
#  This is because Edge auto-launches after the setup is done and
#  Start-Process continues to indefinitely wait on that process.
Write-Host "Installing Microsoft Edge (Dev)..." -ForegroundColor cyan
Invoke-WebRequest $downloadDevLink -OutFile $devSetup # Download Dev
Start-Process $devSetup # Run installer
Write-Host "Microsoft Edge (Dev) installed.`n" -ForegroundColor green

Write-Host "Installing Microsoft Edge (Canary)..." -ForegroundColor cyan
Invoke-WebRequest $downloadCanaryLink -OutFile $canarySetup # Download Canary
Start-Process $canarySetup # Run installer
Write-Host "Microsoft Edge (Canary) installed.`n" -ForegroundColor green