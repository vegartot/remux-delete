#######################################################
# 
# Filename: remux-delete.ps1
#
# This script will check the specified folders for
# mkv files. If there exists a duplicate file with
# an .mp4 extension it deletes the .mkv file.
# Else it will try to remux the .mkv file 
# and delete it once remuxed. 
#
# Use Task Scheduler to schedule this task to
# make this process automatic. Or run the script
# manually when needed. 
#
# After adding desired folders, save this file and
# simply run the .bat file to execute this script
# and bypass powershell's default execution
# policy.
#
#######################################################



# Folders to search
[System.String[]] $folders = (
  
  "C:\Users\"

  # Add folders in fullpath and quotation separated by comma
  # For example:
  # 
  # "$HOME\Videos\",
  # "D:\Recordings"
)

#Array to contain all files
[System.Collections.ArrayList] $files = [System.Collections.ArrayList]::new()

# Add all files with .mkv and .mp4 extensions
foreach ($folder in $folders)
{
  if ([System.IO.Directory]::Exists($folder))
  {
    $files += [System.IO.Directory]::GetFiles($folder, "*.mkv")
    $files += [System.IO.Directory]::GetFiles($folder, "*.mp4")
  }
  else
  {
    # If a certain folder specified cannot be found
    Write-Host "WARNING: failed to locate provided folder: '$folder' `n"
  }
}

# Initalize indices as FileInfo objects
for ($i = 0; $i -lt $files.Count; $i++)
{
  $files[$i] = [System.IO.FileInfo]::new($files[$i])
}

# Keep looping file buffer untill all .mkv files have been remuxed and deleted
while ($files.Where({$_.extension -eq ".mkv"}))
{

  foreach ($file in $files.Where({$_.extension -eq ".mkv"}))
  {
    # Check if matching filename is in file buffer and query it's index
    # Returns -1 if not found, otherwise an index >= 0
    $remuxedFile = [System.String]::Concat($file.FullName.Substring(0, $file.FullName.LastIndexOf(".")), ".mp4")
    $index = $files.FullName.IndexOf($remuxedFile)

    # If remux file found -> check if file size is similar
    if ($index -ne -1)
    {

      # NOTE: Defined bias .. filesize is within 1% of original file.
      #       If not, assume remux got stopped prematurely or corrupted.
      #       Might need to be tweaked if a previously remuxed clip
      #       has a deviation greater than 1%. Although a 1:1 copied
      #       remux should fall within this margin.

      $fileSizeDelta = [System.Math]::Abs($file.Length - $files[$index].Length)
      if ($fileSizeDelta / $file.Length -gt 0.01)
      {
        Write-Host "Remux too small:" $files[$index].FullName
        [System.IO.File]::Delete($files[$index].FullName)
      }
      else
      {
        # Found corresponding .mp4 file of similar size
        # Delete original and break out of for-each loop
        Write-Host "Deleting original:" $file.FullName "`n"
        [System.IO.File]::Delete($file)
        $files[$files.IndexOf($file)] = $null
        $files[$files.FullName.IndexOf($remuxedFile)] | Out-Null
        break
      }
    }
    # If remuxed file is not found start remux
    Write-Host "Starting remux: " $file.FullName "===>" $files[$index].FullName
    & ffmpeg.exe -hide_banner -loglevel error -xerror -stats -i $file.FullName -c copy -map 0 $remuxedFile
      
    if ($LASTEXITCODE -eq 0)
    {
      # Exit 0 on success
      # Add remux file to buffer and start all over
      Write-Host "Remux complete."
      $files.Add([System.IO.FileInfo]::new($remuxedFile)) | Out-Null
      break
    }
      
    else 
    {
      # FFMPEG exited with non-zero
      Write-Host "FFMPEG error - return code:" $LASTEXITCODE
      exit
    }
  }
}

Write-Host "No more work to do."
