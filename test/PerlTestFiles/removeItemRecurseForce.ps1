# Get the target to be deleted
Param(
  [string]$targetDir
  )
 
write-host "Deleting (from shell): $targetDir"

# recursively remove the directory named 
# Remove-Item -Recurse -Force $targetDir

write-host "done"
exit