Param (
    [switch]$Log,
    [switch]$Help
)

$Version = "2.0"

If ($true -eq $Help) {
Write-Host @"
    ____  _______________ __  __
   / __ \/ ___/ ___/ ___// / / /
  / /_/ /\__ \\__ \\__ \/ /_/ / 
 / ____/___/ /__/ /__/ / __  /  
/_/    /____/____/____/_/ /_/   $Version

PowerShell Secure Shell
Author: Evan Lane
Website: https://github.com/evanlanester/PSSSH

A native PowerShell alternative to SSH and PSRemote management.
Stores entries in $ENV:USERPROFILE\.ssh\psssh_hosts.json

-Log enables session outputs to be saved to a log file.
-Help shows this text.

For any feature requests or issues, please report them to:
https://github.com/evanlanester/PSSSH/issues
"@
    return
}

$JsonPath = "$ENV:USERPROFILE\.ssh\psssh_hosts.json"

# Load existing entries
if (Test-Path $JsonPath) {
    $entries = Get-Content $JsonPath | ConvertFrom-Json
} else {
    $entries = @()
}

function Get-Timestamp {
   Get-Date -Format "ddd MMM d HH:mm:ss yyyy"
}

function Get-HostEnvironment {
    switch ($true) {
        { $env:WT_SESSION } { return "WindowsTerminal" }
        { $env:TERM_PROGRAM -eq "vscode" } { return "VSCode" }
        { $host.Name -eq "Windows PowerShell ISE Host" } { return "ISE" }
        { $host.Name -eq "ConsoleHost" } { return "Console" }
        default { return "Unknown" }
    }
}

# Add "Add New Entry" as a menu option
$menuItems = $entries | ForEach-Object { "$($_.Name) ($($_.User)@$($_.Host))" }
$menuItems += "Add New Entry"
$menuItems += "Exit"
$selectedIndex = 0
$selectionMade = $false

function Draw-Menu {
    Clear-Host
    Write-Host @"
    ____  _______________ __  __
   / __ \/ ___/ ___/ ___// / / /
  / /_/ /\__ \\__ \\__ \/ /_/ / 
 / ____/___/ /__/ /__/ / __  /  
/_/    /____/____/____/_/ /_/   $Version
                                
"@
    Write-Host "Select an remote target or add a new one:`n"
    for ($i = 0; $i -lt $menuItems.Count; $i++) {
        if ($i -eq $selectedIndex) {
            Write-Host "> $($menuItems[$i])" -ForegroundColor Cyan
        } else {
            Write-Host "  $($menuItems[$i])"
        }
    }
}

do {
    Draw-Menu
    $key = [System.Console]::ReadKey($true).Key

    switch ($key) {
        'UpArrow' {
            $selectedIndex = ($selectedIndex - 1 + $menuItems.Count) % $menuItems.Count
        }
        'DownArrow' {
            $selectedIndex = ($selectedIndex + 1) % $menuItems.Count
        }
        'Enter' {
            $selectionMade = $true
        }
    }
} until ($selectionMade)

Clear-Host

if ($selectedIndex -eq $menuItems.Count - 2) {
    # Add new entry  
    $validTypes = @("ssh", "psremote")
    do {
        $type = Read-Host "Enter a type of connection (ssh/psremote)"
    } while ($validTypes -notcontains $type.ToLower())

    $name = Read-Host "Enter a name for the server"
    $user = Read-Host "Enter the Remote username"
    $server = Read-Host "Enter the Remote host"

    $newEntry = [PSCustomObject]@{
        Type = $type
        Name = $name
        User = $user
        Host = $server
    }

    $entries += $newEntry
    $entries | ConvertTo-Json -Depth 3 | Set-Content $JsonPath

    Write-Host "`nNew entry added successfully!" -ForegroundColor Green

} elseif ($selectedIndex -eq $menuItems.Count - 1) {
     Write-Host "`nExiting..." -ForegroundColor Red
    return
} else {
    # Connect via SSH
    $entry = $entries[$selectedIndex]
    switch ($entry.Type) {
        "ssh" {
            $remoteCommand = "ssh $($entry.User)@$($entry.Host)"
        }
        "psremote" {
            $remoteCommand = "Enter-PSSession -ComputerName $($entry.Host) -Credential $($Entry.User)"
        }
    }

    $hostEnv = Get-HostEnvironment

    If ($true -eq $Log) {
        $logFile = ".\$($entry.Name).log"
        Write-Host "Executing: $remoteCommand" -ForegroundColor Yellow
        Write-Host "### $(Get-TimeStamp) Connecting to $($entry.Host) as  $($entry.User) [ $remoteCommand ] ###" | Tee-Object -FilePath $logFile
    } Else {
        Write-Host "Executing: $remoteCommand" -ForegroundColor Yellow
    }
   
    switch ($hostEnv) {
        # Open SSH Session in either, the existing session, a new PowerShell Window or wt.exe new-tab
        <#"WindowsTerminal" { # This functionality is broken - exploring `wt -w 0 nt`
            # Open in a new tab
            $tabTitle = $entry.Name
            if ($log) {
                wt.exe -w 0 new-tab --title "$tabTitle" powershell -NoProfile -NoExit -Command  "$remoteCommand | Tee-Object -FilePath '$logFile' -Append" 
            } else {
                wt.exe -w 0 new-tab --title "$tabTitle" powershell -NoProfile -NoExit -Command "$remoteCommand"
            }
        } #>
        "Console" {
            # Run in same window
            if ($log) {
                Invoke-Expression $remoteCommand | Tee-Object -FilePath $logFile -Append
            } else {
                Invoke-Expression $remoteCommand
            }
        }
        "VSCode" {
            Write-Host "Remote Sessions in VSCode terminal may not behave as expected. Running in current window..." -ForegroundColor Yellow
            if ($log) {
                Invoke-Expression $remoteCommand | Tee-Object -FilePath $logFile -Append
            } else {
                Invoke-Expression $remoteCommand
            }
        }
        "ISE" {
            Write-Host "PowerShell ISE does not support interactive remote sessions." -ForegroundColor Red
        }
        default {
            Write-Host "Unknown host environment. Running a Remote Session in current window..." -ForegroundColor Yellow
            if ($log) {
                Invoke-Expression $remoteCommand | Tee-Object -FilePath $logFile -Append
            } else {
                Invoke-Expression $remoteCommand  
            }
        }
    }

}