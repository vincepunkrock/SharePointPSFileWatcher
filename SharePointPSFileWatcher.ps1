### 
# listens for Create, Change, Rename events in the specified folder
# the events are catched and trigger an upload of the file to the specifid SharePoint library

### REQUIREMENTS
# Install-Module 'Pnp.PowerShell'
# Register-PnpManagementShellAccess

param(
    [string]$Path
)

# What is the target SharePoint site URL for the upload? 
$spoSite = 'https://[tenant].sharepoint.com/sites/[MySite]' 

# What is the target document library relative to the site URL? 
$spoDocLibrary = 'Style Library/scripts/DEV' 

# This command authenticates to the SPO site you specified in the $spoSite variable. Enter your username and password when prompted.
Connect-PnPOnline -Url $spoSite -Interactive
# Next, confirm that the target folder you specified in the $spoDocLibrary variable exists in the SPO site.
Resolve-PnPFolder -SiteRelativePath $spoDocLibrary

function global:UploadToSP {

    param(
        [string]$filePath
    )

    Write-Host "Uploading $filePath"

    Add-PnPFile `
        -Path $filePath `
        -Folder $spoDocLibrary `

    Write-Host "Done"
}

### SET FOLDER TO WATCH + FILES TO WATCH + SUBFOLDERS YES/NO
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $Path
$watcher.Filter = "*.*"
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true  

### DEFINE ACTIONS AFTER AN EVENT IS DETECTED
$action = {
    $path = $Event.SourceEventArgs.FullPath
    $changeType = $Event.SourceEventArgs.ChangeType
    $logline = "$(Get-Date), $changeType, $path"
    Write-Host $logline
    UploadToSP -filePath $Path
}

# Unsubscribe all previously registered watchers
Get-EventSubscriber -Force | Unregister-Event -Force

### DECIDE WHICH EVENTS SHOULD BE WATCHED 
Register-ObjectEvent $watcher "Created" -Action $action
Register-ObjectEvent $watcher "Changed" -Action $action
Register-ObjectEvent $watcher "Renamed" -Action $action

try
{
    while($true)
    {
        Start-Sleep 5
    }
}
finally
{
    # Unsubscribe all previously registered watchers
    Get-EventSubscriber -Force | Unregister-Event -Force
    Write-Host "Ended work."
}
