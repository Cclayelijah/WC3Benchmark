Set-ExecutionPolicy -ExecutionPolicy Bypass
$date = Get-Date -Format "MM/dd/yyyy HH:mm K"

#Install CPU-Z
$software = "CPUID CPU-Z 1.96";
$installed = (Get-ItemProperty HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\* | Where { $_.DisplayName -eq $software }) -ne $null
If (-Not $installed) {
    Write-Host "Now installing '$software'.";
    Powershell.exe -ExecutionPolicy Bypass .\CPU-Z\Deploy-CPU-Z.ps1 -DeploymentType "Install" -DeployMode "Silent"
} else {
    Write-Host "'$software' is installed.";
}

Write-Host "Generating Reports..."

# Run CPU-Z Processor Benchmark
Set-Location -Path "C:\\Program Files\\CPUID\\CPU-Z"
./cpuz.exe -bench

# Run CPU-Z Report
./cpuz.exe -txt=C:\\Users\\%USERNAME%\\Favorites\\WC3\\BenchTest\\cpuz;
$path = 'C:\Users\' +$env:USERNAME+ '\Favorites\WC3\BenchTest'
Set-Location -Path $path -PassThru

#Generate Disk Report
Invoke-Expression -Command:"wmic bios get SerialNumber > diskinfo.txt"
Invoke-Expression -Command:"echo Disk Speeds >> diskinfo.txt"
Invoke-Expression -Command:"winsat disk -drive c -seq -read > temp.txt"
Select-String -Path .\temp.txt -Pattern 'MB/s' -SimpleMatch >> diskinfo.txt
Invoke-Expression -Command:"winsat disk -drive c -seq -write > temp.txt"
Select-String -Path .\temp.txt -Pattern 'MB/s' -SimpleMatch >> diskinfo.txt
Invoke-Expression -Command:"findStr 'MB/s' temp.txt >> diskinfo.txt"

$cpu_name = ""
$cpu_coreSpeed = 0
$cpu_numCores = 0
$cpu_benchmark = 0

$ram_size = 0
$ram_frequency = 0

[System.Collections.ArrayList]$gpu_name = @() #stored in array to handle multiple GPUs
[System.Collections.ArrayList]$gpu_coreClock = @()
[System.Collections.ArrayList]$gpu_memClock = @()
$gpu_count = 0

$dsk_capacity = 0
$dsk_read = 0
$dsk_write = 0


Write-Host "Reading Reports..."

#Get CPU Benchmark
$filepath = "C:\Program Files\CPUID\CPU-Z\" + $env:COMPUTERNAME + ".txt"
[string]$line = (Select-String -Path $filepath -Pattern "," -SimpleMatch)
$cpu_benchmark = [double]::Parse($line.substring($line.IndexOf(",")+1).replace('"',' ').trim());

#Read Disk Report
[string]$line = (Select-String -Path diskinfo.txt -Pattern "Read" -SimpleMatch)
$line = $line.substring($line.IndexOf("Read")+4).Trim();
$line = $line.Substring(0, $line.IndexOf("MB/s")).Trim();
$dsk_read = [double]::Parse($line)
[string]$line = (Select-String -Path diskinfo.txt -Pattern "Write" -SimpleMatch)
$line = $line.substring($line.IndexOf("Write")+5).Trim();
$line = $line.Substring(0, $line.IndexOf("MB/s")).Trim();
$dsk_write = [double]::Parse($line)

#Read CPU-Z Report
[string]$line = Select-String -Path "cpuz.txt" -Pattern "Specification" -SimpleMatch | select-object -First 1
$cpu_name = $line.Substring($line.IndexOf("Specification") + "Specification".Length).Trim()
[string]$line = Select-String -Path "cpuz.txt" -Pattern "Number of adapters" -SimpleMatch
$gpu_count = [int]$line.Substring($line.IndexOf("Number")).replace("Number of adapters", "").Trim()
$matches = Select-String -Path "cpuz.txt" -Pattern "Number of sockets" -CaseSensitive
[int]$cpuCount = $matches.count
$nameCounter = 0;
$gpu_coreToggle = $true
$gpu_memToggle = $true

[System.IO.File]::ReadLines("cpuz.txt") | ForEach-Object { 
    if ($_ -clike '*Core Speed*'){
        $cpu_coreSpeed = [double]$_.replace('Core Speed',' ').replace('MHz',' ').Trim()
    }
    if ($_ -clike '*Number of cores*'){
        $cpu_numCores = [int]$_.Substring(0,$_.IndexOf("(")).replace('Number of cores',' ').Trim()
    }
    if ($_ -clike '*Memory Size*'){
        $ram_size = [int]$_.substring(0,$_.IndexOf("GBytes", "")).replace("Memory Size", " ").Trim()
    }
    if ($_ -clike '*Memory Frequency*'){
        $ram_frequency = [double]$_.Substring(0,$_.IndexOf("MHz")).replace("Memory Frequency", " ").Trim()
    }
    if ($_ -clike '*Name*'){ 
        $nameCounter += 1; 
        if ($nameCounter -gt $gpu_count + $cpuCount){ 
            [void]$gpu_name.Add($_.replace("Name", "").Trim())
        }
    }
    if ($_ -clike '*Core clock*'){
        $gpu_coreToggle = ! $gpu_coreToggle
        if ($gpu_coreToggle){
            [void]$gpu_coreClock.Add([double]$_.substring(0,$_.IndexOf("MHz")).Replace("Core clock", "").Trim())
        }
    }
    if ($_ -clike '*Memory clock*'){
        $gpu_memToggle = ! $gpu_memToggle
        if ($gpu_memToggle){
            [void]$gpu_memClock.Add([double]$_.substring(0,$_.IndexOf("MHz")).Replace("Memory clock", "").Trim())
        }
    }
}

# Transmit Data
Write-Host "Posting Data..."
Write-Host ""
Write-Host "$env:COMPUTERNAME"
Write-Host "$date"
Write-Host ""
Write-Host "CPU Info-"
Write-Host "$cpu_name"
Write-Host "Core Speed: $cpu_coreSpeed"
Write-Host "Cores: $cpu_numCores"
Write-Host "CPU-Z Benchmark: $cpu_benchmark"
Write-Host ""
Write-Host "RAM Info-"
Write-Host "Memory Size: $ram_size"
Write-Host "Memory Frequency: $ram_frequency"
Write-Host ""
Write-Host "GPU Info-"
Write-Host "gpu_count: $gpu_count"
Write-Host "gpu_name: $gpu_name"
Write-Host "gpu_coreClock: $gpu_coreClock"
Write-Host "gpu_memClock: $gpu_memClock"
Write-Host ""
Write-Host "Disk Info-"
Write-Host "Read Speed (MB/s): $dsk_read"
Write-Host "Write Speed (MB/s): $dsk_write"
Write-Host ""

$gpu = @{}
for ($i=0; $i -lt $gpu_count; $i++){
    $list = @{"Core Clock"=$gpu_coreClock[$i];"Memory Clock"=$gpu_memClock[$i]}
    $gpu.Add($gpu_name[$i], $list)
}

$data = @{
    "Computer Name" = $env:COMPUTERNAME;
    "Timestamp" = $date;
    "CPU" = $cpu_name;
    "Core Speed" = $cpu_coreSpeed;
    "Cores" = $cpu_numCores;
    "CPU-Z Benchmark" = $cpu_benchmark;
    "RAM Size" = $ram_size;
    "RAM Frequency" = $ram_frequency;
    "Disk Read Speed" = $dsk_read;
    "Disk Write Speed" = $dsk_write;
    "Graphics Cards" = $gpu;
}

$data | ConvertTo-Json -Depth 10 | Out-File ".\data.json"

#Remove files we are done using
Invoke-Expression -Command:"del temp.txt"
Invoke-Expression -Command:"del cpuz.txt"
Invoke-Expression -Command:"del diskinfo.txt"
Invoke-Expression -Command:"del 'C:\\Program Files\\CPUID\\$env:COMPUTERNAME.txt'"