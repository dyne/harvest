# Harvest

[![software by Dyne.org](https://zenroom.dyne.org/img/software_by_dyne.png)](http://www.dyne.org)

Harvest is a compact, fast and portable software that can scan stored files and directory and, based on their extension and a simple fuzzy logic analysis of directory contents, recognise if they are related to video, audio or text materials.

Harvest makes it easy to list them by type or year, to move them or to categorize them for tagged filesystems. It can process approximately 1GB of stored files per second. Harvest is operated from the console terminal, it requires `zsh` to be installed and works on all desktop platforms supported by it (GNU/Linux, Apple/OSX and MS/Windows).

Harvest is designed to operate on folders containing files without exploding the files around: it assesses the typology of a folder from the files contained, but does not move the files outside of that folder. For instance it works very well to move around large collections of downloaded torrent folders.

## :floppy_disk: Installation

Just type 
```bash
git submodule update --init --recursive
sudo make install
``` 
to install into `/usr/local/share/harvest`.

The environmental variable `HARVEST_PREFIX` can be set when running harvest to indicate different installation directories. Using harvest on different operating systems than GNU/Linux/BSD may require tweaking of this variable.

## :video_game: Usage

To scan all files and directories found in a folder:
```
harvest /path/to/folder
```
To scan only the files (non recursive):
```
harvest /path/to/folder
```

After scanning, results are print to screen, but also saved in a local cache. Then it is possible to list all video hits in the most recent scan:
```
harvest ls video
```

To move harvested audio files to a "Sound" folder in home (beware, this command will actually move files across your filesystem):
```
harvest mv audio ~/Sound/
```

To move all harvested files to a new destination folder (destination must already exist and be a writable directory):
```
harvest mv all ~/destination
```

So for instance a simple script using harvest to move all downloaded audio and video files in different home folders would look like:
```sh
#!/bin/sh
harvest  ~/Downloads
harvest mv video ~/Video
harvest mv audio ~/Music
```

Or a short concatenation of commands that will delete all harvested code files and directories:
```sh
harvest ls code | cut -d, -f4 | xargs rm -rf
```


## :heart_eyes: Acknowledgements

Harvest is Copyright (C) 2014-2018 by the Dyne.org Foundation

Harvest is designed, written and maintained by Denis "Jaromil" Roio

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
