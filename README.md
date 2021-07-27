# Collect-Benchmark-Data
A Powershell script that uses CPU_Z to generate a simple computer performance report. If CPU-Z is not already installed, it is installed automatically (https://silentinstallhq.com/cpu-z-install-and-uninstall-powershell/). CPU-Z is only used for it's benchmark data. All other data is collected manually.
This is where you will find the output data: C:\WC3Benchmark-main\data.json

Setup in one simple step using powershell:
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Cclayelijah/WC3Benchmark/main/Files/bench-setup.ps1" -UseBasicParsing | Invoke-Expression
