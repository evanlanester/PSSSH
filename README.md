```
    ____  _______________ __  __
   / __ \/ ___/ ___/ ___// / / /
  / /_/ /\__ \\__ \\__ \/ /_/ / 
 / ____/___/ /__/ /__/ / __  /  
/_/    /____/____/____/_/ /_/   v2.0
```

# PowerShell Secure Shell

A native PowerShell alternative for remote session management.

Stores entries in `$ENV:USERPROFILE\.ssh\psssh_hosts.json` or C:\Users\username\\.ssh\psssh_hosts.json

Running `PSSSH.ps1` will display all entires in `psssh_hosts.json` and allow you add entries, it will then run ssh or psremote and connect to the seleted server.

More features to come.

## Arguments

-Log enables session outputs to be saved to a log file.

-Help shows this text.

## Roadmap:

Use my tool and want more support for your workflow?

Add a feature request in Issues!

### Support Remote Management tools:

1. SSH - ☑ - Added in V1.0

2. PSRemote - ☑ - Added in V2.0

3. RDP - ☐

### Quality of life:

- Different ways of running PowerShell in Win10/11.
- Logging sessions to a .log file

### Will not add:

- No support for storing passwords. Either use SSH Keys, or Single Sign On.