# Harvest - a tool to classify large collections of files and directories

![Kant handle my swag](https://repository-images.githubusercontent.com/77449851/9d50d480-9766-11ea-98a2-c5aa84501c6e)

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

```
Usage: harvest [OPTIONS]

OPTIONS: 
  -p, --path=PATH     (default is current position)
  -t, --type=TYPE     text, audio, video, code, etc.
  -o, --output=FORMAT csv, json (default: human)
  --dir               select only directories
  --file              select only files
  -d                  run in DEBUG mode
  -v, --version       print the version and exits
```


To list all image files found in Downloads:
```
harvest -p ~/Downloads -t image --file
```

To list all video directories at current filesystem position:
```
harvest -t video --dir
```

To list all files and dirs containing reading materials:
```
harvest -t text
```

To have a list of supported types use `harvest -t list` at any moment
```
Supported types:
 code image video book text font web archiv sheet exec slide audio
```
For more information about types recognized see the catalogue of file
types we maintain in the [file-extension-list
project](https://github.com/dyne/file-extension-list).

### Copy or move

So far we have seen how to run non-destructive operations, now we come
to **apply actual changes to the filesystem**.

#### Using shell scripts

Another simplier solution to move or copy files around is to use shell scripting on the command-line or inside your own scripts.

For example, here is a short concatenation of commands that will copy all harvested image files and directories to /tmp/images/
```bash
harvest -t image -o csv | cut -d, -f5 | xargs -I{} cp -v {} /tmp/images
```

The comma separated list (CSV) output of harvest is organized like this:
```
FILE | DIR, TYPE, TIMESTAMP, SIZE, FILENAME
```

#### Using hvst

One solution is to use a practical wrapper called
[hvst](https://git.coom.tech/gg1234/hvst) which supports distributing
files to destination folders named after Perl expressions based on
file attributes, for instance date.

For more info about this solution see the [hvst readme documentation](https://git.coom.tech/gg1234/hvst).

#### Using TMSU

Support of tagged filesystems is an old feature, easy to bring back.

if anyone wants it back just say, for more information see the [TMSU project](https://github.com/oniony/TMSU).

## :heart_eyes: Acknowledgements

[![software by Dyne.org](https://files.dyne.org/software_by_dyne.png)](http://www.dyne.org)

Harvest is Copyright (C) 2014-2022 by the Dyne.org Foundation

Harvest is designed, written and maintained by Denis "Jaromil" Roio
with contributions by Puria Nafisi Azizi and G Gundam.

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
