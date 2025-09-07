```
    ____  _______________ __  __
   / __ \/ ___/ ___/ ___// / / /
  / /_/ /\__ \\__ \\__ \/ /_/ / 
 / ____/___/ /__/ /__/ / __  /  
/_/    /____/____/____/_/ /_/   v1.1
```

# PowerShell Secure Shell

A native PowerShell alternative for SSH management.

Stores entries in `$ENV:USERPROFILE\.ssh\ssh_hosts.json` or C:\Users\username\\.ssh\ssh_hosts.json

Running `PSSSH.ps1` will display all entires in `ssh_hosts.json` and allow you add entries, it will then run ssh and connect to the seleted server.

More features to come.

## Arguments

-Log enables session outputs to be saved to a log file.

-Help shows this text.