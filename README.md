## Remux and Delete

Automate the process of remuxing .mkv files to a .mp4 format and deleting .mkv file once finished. 

Requires [ffmpeg](https://ffmpeg.org/) and ffmpeg added to path

Add personal local video folders to the list of folders to search

The idea behind the project is to streamline the process of remuxing [OBS]() .mkv recordings after a recording/streaming session without having to do it manually. Doing it manually will easily involve a two step procedure of firstremuxing a clip, wait for it to complete, and then delete the original .mkv file to save storage. For now the program relies on ffmpeg, but ideally I would like it to invoke the OBS remuxer some way to avoid the additional dependency.
The program is designed to be able to be ran on demand, but can also easily be registered as a repeating script to launch how often as wanted. Future additions may include a script to register the program for you and alternatively add an interface to add/remove folders to search.
