#Author: Elijah Cannon
#West Coast Code Consultants
#Runs the most up-to-date version from server

Set-ExecutionPolicy -ExecutionPolicy Bypass
try {
    $script = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Cclayelijah/WC3Benchmark/main/Files/wc3-benchmark.ps1" -UseBasicParsing
    $script | Invoke-Expression
}
catch {
  Write-Host "An error occurred:"
  Write-Host $_
}