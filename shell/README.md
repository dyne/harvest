# Shell version of harvest

This is an older version of harvest, it is made in Zsh and needs the Zuper
plugin for Zsh installed (make install -C zuper).

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
