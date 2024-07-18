#######################################################
# 
# Filename: remux-delete.ps1
# Author: Vegard Totland
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
#######################################################

# Folders to search
[System.String[]] $folders = (
  "E:\4k Recordings",
  "E:\VODs"
  # Add folders in fullpath
)

[System.Collections.ArrayList] $files = [System.Collections.ArrayList]::new()

foreach ($folder in $folders)
{
  $files += [System.IO.Directory]::GetFiles($folder, "*.mkv")
  $files += [System.IO.Directory]::GetFiles($folder, "*.mp4")
}

for ($i = 0; $i -lt $files.Count; $i++)
{
  $files[$i] = [System.IO.FileInfo]::new($files[$i])
}

foreach ($file in $files)
{
  if ($file.extension -ne ".mkv") {continue}

  $remuxedFile = [System.String]::Concat($file.FullName.Substring(0, $file.FullName.LastIndexOf(".")), ".mp4")
  $index = $files.ToArray().FullName.IndexOf($remuxedFile)

  # If remux file found -> check file size
  if ( $index -ne -1)
  {
    
    $fileSizeDelta = [System.Math]::Abs($file.Length - $files[$index].Length)
    if ($fileSizeDelta / $file.Length -gt 0.01)
    {
      Write-Host "Remux too small" $file.FullName $files[$index].FullName
      [System.IO.File]::Delete($files[$index].FullName)
    }
    else
    {
      # Found corresponding .mp4 file of similar size
      # Delete original and jump to next loop iteration
      [System.IO.File]::Delete($file)
      Continue
    }
  }

  # If remuxed file is not found start remux
  try
  {
    Write-Host "Starting Remux: " $file.FullName " ==> " $remuxedFile
    ffmpeg.exe -hide_banner -loglevel warning -stats -i $file.FullName -c copy -map 0 $remuxedFile | Out-Null
    Write-Host "Remux complete"
  }
  catch
  {
    Continue
  }
  finally
  {
    # Formatting
    Write-Host ""
  }

}
