# Collect-Benchmark-Data
A Powershell script that uses CPU_Z to generate a simple computer performance report. If CPU-Z is not already installed, it is installed automatically (https://silentinstallhq.com/cpu-z-install-and-uninstall-powershell/). It only uses it for the cpu benchmark data. All other data is collected manually.
This is where you will find the output data: C:\Users\$env:USERNAME\Favorites\WC3\BenchTest\data.json

SETUP:
1. Extract the WC3 Folder into the User's Favorites folder.
2. Open powershell as administrator and run "C:\\Users\\$env:USERNAME\\Favorites\\WC3\\BenchTest\\wc3-benchmark.ps1"
3. CPU-Z Installation error logs can be viewed here: “C:\Windows\Logs\Software”.
