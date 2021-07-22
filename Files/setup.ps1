#Author: Elijah Cannon
#West Coast Code Consultants
#Sets up machine with file structures, cpuz helper files, and exported task

Set-ExecutionPolicy -ExecutionPolicy Bypass
Register-ScheduledTask -xml (Get-Content 'C:\WC3\BenchTest\WC3BenchmarkTask.xml' | Out-String) -TaskName "WC3 Benchmark" -TaskPath "\" -User SYSTEM –Force