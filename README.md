# Harvest - manage large collections of files and dirs

Harvest makes it easy to list files and folders by type and copy or
move them around.

![Kant handle my swag](docs/kant_handle_my_swag.jpeg)

Harvest is a compact and portable script to scan files and folders and
recognise their typology. Scanning is based on [file
extensions](https://github.com/dyne/file-extension-list) and a simple
fuzzy logic analysis of **folder contents** (not just files) to
recognise if they are related to video, audio or text materials, etc.

Harvest is **fast**: it can read approximately 1GB of stored filenames
per second and is operated from the console terminal. It never
modifies the filesystem: that is done explicitly by the user piping
shell commands.

[![Software by Dyne.org ](https://files.dyne.org/software_by_dyne.png)](https://dyne.org)

Harvest operates on folders containing files without exploding the
files around: it assesses the typology of a folder from the files
contained, but does not promote move the files outside of that folder. For
instance it works very well to move around large collections of
downloaded torrent folders.

## :floppy_disk: Installation

Harvest is a Zsh script and works on any POSIX platform where it can be installed including GNU/Linux, Apple/OSX and MS/Windows.

Install the latest harvest with:
```
curl https://raw.githubusercontent.com/dyne/harvest/main/harvest | sudo tee /usr/local/bin/harvest
```

Dependencies: `zsh`

Optional:
- `fuse tmsu` for tagged filesystem
- `setfattr` for setting file attributes

## :video_game: Usage

Scan a folder /PATH/ to show and save results
```
 harvest scan [PATH]
```

List of supported category types:
```
 code image video book text font web archiv sheet exec slide audio
```

Move all scanned text files in /PATH/ to /DEST/
```
 harvest scan [PATH] | grep ';text;' | xargs -rn1 -I% mv % [DEST]
```

Tag all file attributes in /PATH/ with `harvest.type` categories
```
 harvest attr [PATH]
```

Tag all files for use with TMSU (See section below about TMSU)
```
 harvest tmsu [PATH]
```


## TMSU

This implementation supports tagged filesystems using [TMSU](https://github.com/oniony/TMSU).

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
