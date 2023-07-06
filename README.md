# SharePointPSFileWatcher
Powershell Script that watches for creation, change or renaming of files and uploads to a SharePoint library

#How to use
- Change the script to use yoru own SharePoint tenant and library
- Execute the script, passing it the 'Path' argument like so:
  `.\FileWatcher.ps1 -Path "C:\Users\Vincent\dev\"`
- Do your programming as you normally do
- Everytime you create a file, change it (and save) or rename it, it will trigger an upload of this file to SharePoint
