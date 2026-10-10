# Registers a scheduled task that starts Syncthing at logon, then starts it.
# Safe to run again: it replaces the existing task.

$ErrorActionPreference = 'Stop'
$taskName = 'Syncthing'

$syncthing = (Get-Command syncthing -ErrorAction SilentlyContinue).Source
if (-not $syncthing) {
    throw 'syncthing not found. Install it with "winget install Syncthing.Syncthing" and open a new shell.'
}

$action = New-ScheduledTaskAction -Execute $syncthing -Argument '--no-console --no-browser'
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit 0

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
    -Settings $settings -Force | Out-Null

if (-not (Get-Process syncthing -ErrorAction SilentlyContinue)) {
    Start-ScheduledTask -TaskName $taskName
}

Write-Host "Task '$taskName' registered for $syncthing"
