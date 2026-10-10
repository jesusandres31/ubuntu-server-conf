# Syncthing on Windows

## Install

```powershell
winget install Syncthing.Syncthing
```

## Set up autostart

The winget package does not start with Windows.
[install-autostart.ps1](install-autostart.ps1) registers a `Syncthing` task
that starts it at logon. From the repo root, in a new shell:

```powershell
powershell -ExecutionPolicy Bypass -File docker\syncthing\win\install-autostart.ps1
```

It replaces any existing `Syncthing` task and starts Syncthing if it is not
already running.

## Check it is running

```powershell
Get-ScheduledTask -TaskName Syncthing | Select-Object State   # Ready or Running
Get-Process syncthing                                          # a process is listed
```

Then open <http://127.0.0.1:8384>. The `thinkcenter-syncthing` device and the
`Obsidian` folder should show **Up to Date**.

## Remove

```powershell
Unregister-ScheduledTask -TaskName Syncthing -Confirm:$false
```
