#Author: Elijah Cannon
#West Coast Code Consultants
#Runs the most up-to-date version from server

Set-ExecutionPolicy -ExecutionPolicy Bypass
$script = Invoke-WebRequest -Uri "https://plans.wc-3.com/path/to/script.ps1" -UseBasicParsing
$script | Invoke-Expression