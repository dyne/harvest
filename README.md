# Harvest - a tool to classify large collections of files and directories

[![software by Dyne.org](https://files.dyne.org/software_by_dyne.png)](http://www.dyne.org)

Harvest is a compact, fast and portable software that can scan files and folders to recognise their typology. Scanning is based on file extensions and a simple fuzzy logic analysis of folder contents to recognise if they are related to video, audio or text materials.

Harvest makes it easy to list folders by type or year, to move them or to categorize them for tagged filesystems. It can process approximately 1GB of stored files per second and is operated from the console terminal.

Harvest is designed to operate on folders containing files without exploding the files around: it assesses the typology of a folder from the files contained, but does not move the files outside of that folder. For instance it works very well to move around large collections of downloaded torrent folders.

## :floppy_disk: Installation

Harvest works on all desktop platforms supported by it (GNU/Linux, Apple/OSX and MS/Windows).

To be built from source, Harvest requires the following packages to be installed in your system:
- pkg-config
- luarocks
- libluajit-5.1-dev

Then inside the luarocks package manager it should be installed luastatic and inspect:
```
sudo luarocks install luastatic
sudo luarocks install inspect
```

From inside the source, just type:

Just type 
```bash
git submodule update --init --recursive
make
sudo make install
``` 
to install into `/usr/local/share/harvest`.

The environmental variable `HARVEST_PREFIX` can be set when running harvest to indicate different installation directories. Using harvest on different operating systems than GNU/Linux/BSD may require tweaking of this variable.

Extended functionalities can be attained by installing [TMSU](https://tmsu.org/) (see below "Advanced Usage").

## :video_game: Usage

To scan all files and directories found in a folder:
```
harvest /path/to/folder
```
To scan only the files (non recursive):
```
harvest /path/to/folder files
```

After scanning, results are print to screen, but also saved in a local cache. Then it is possible to list all video hits in the most recent scan:
```
harvest ls video
```

The `harvest ls` command will list all hits comma separated per line so that it can be piped and parsed into other programs to take further actions; the CSV format is:
```
[dir|file],TYPE,year,path_to_file
```
The `TYPE` field is one of the strings returned by `ls file-extension-list/data` which is the catalogue of file types maintained in the [file-extension-list project](https://github.com/dyne/file-extension-list).

To proceed moving harvested audio files to another "Sound" folder in home:
```
harvest mv audio ~/Sound/
```

To move all harvested files to a new destination folder (destination must already exist and be a writable directory):
```
harvest mv all ~/destination
```

So for instance a simple script using harvest to move all downloaded audio and video files in different home folders would look like:
```bash
#!/bin/sh
harvest  ~/Downloads
harvest mv video ~/Video
harvest mv audio ~/Music
```

Or a short concatenation of commands that will delete all harvested code files and directories:
```bash
harvest ls code | cut -d, -f4 | xargs rm -rf
```

Or a Zsh script to move all files into "Archive/YEAR" to distribute files according to the year in which they were created:
```bash
#!/usr/bin/env zsh
for i in ${(f)"$(harvest ls)"}; do
	year=${i[(ws:,:)3]}
	file=${i[(ws:,:)4]}
	mkdir -p ~/Archive/$year
	mv $file ~/Archive/$year/
done
```
In the previous script one can use the file type instead of the year by changing `year=${i[(ws:,:)3]}` into `type=${i[(ws:,:)2]}`. To navigate tags however is not necessary to modify the filesystem contents: in order to accomplish that, the next section will illustrate the use of a virtual tagged filesystem.

## :telescope: Advanced usage

To allow the navigation of files in the style of a [Semantic Filesystem](https://en.wikipedia.org/wiki/Semantic_file_system), Harvest supports [TMSU](https://tmsu.org/), an small utility to maintain a database of tags inside an hidden directory `.tmsu` in each harvested folder.

To initialise a `tmsu` database bootstrapped with harvest's tags in the currently harvested folder, do:
```
harvest tmsu
```
Directories indexed this way can then be "mounted" (using fuse) and navigated:
```
harvest mount
```
Inside the `$harvest` hidden subfolder (pointing to `.mnt` inside the folder) tags will become folders containing symbolic links to the actual tagged files. Any filemananger following symbolic links can be used to navigate tags, also tags will be set as bookmarks in graphical filemanagers (GTK3 supported).

In addition to the tags view, there is also a queries folder in which you can run view queries by listing or creating new folders:
```
ls -l "$harvest/queries/text and 2018"
```
 This automatic creation of the query folders makes it possible to use new file queries within the file chooser of a graphical program simply by typing the query in. Unwanted query folders can be safely removed.

Limited tag management is also possible via the virtual filesystem. For example one can remove specific tags from a file by deleting the symbolic link in the tag folder, or delete a tag by performing a recursive delete.

To unmount all TMSU semantic filesystems currently mounted, just do:
```
harvest umount
```
Further TMSU operations are possible operating directly from inside the directories that have been indexed using `harvest tmsu`, for more information see `tmsu help`. For instance, TMSU also detects duplicate files using `tmsu dupes`.


## :heart_eyes: Acknowledgements

Harvest is Copyright (C) 2014-2020 by the Dyne.org Foundation

Harvest is designed, written and maintained by Denis "Jaromil" Roio
with contributions by Puria Nafisi Azizi.

This source code is free software; you can redistribute it and/or
modify it under the terms of the GNU Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This source code is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  Please refer
to the GNU Public License for more details.

You should have received a copy of the GNU Public License along with
this source code; if not, write to: Free Software Foundation, Inc.,
675 Mass Ave, Cambridge, MA 02139, USA.
