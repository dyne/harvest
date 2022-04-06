# hvst

A wrapper around [dyne/harvest](https://github.com/dyne/harvest) that fills in [missing functionality](https://github.com/dyne/harvest/issues/5)

At its heart [dyne/harvest](https://github.com/dyne/harvest) is a file categorization tool.
`hvst` takes these categorized files and lets you copy them or move them in bulk.

## Installation

```sh
cp hvst ~/.local/bin
```

Dependencies:  harvest, perl, sed, mkdir, cp, mv

Optional Dependency:  tmsu-fs-mv

## Usage

```
  hvst
  hvst help
  hvst ls [TYPE] [OPTION]
  hvst types
  hvst cp <TYPE> <DEST> [OPTION]...
  hvst mv <TYPE> <DEST> [OPTION]...
  hvst tmv <TYPE> <DEST> [OPTION]...
```

## Examples

```sh
  # Display help message.
  hvst help

  # List files+metadata in current directory.
  hvst

  # Also list files+metadata in current directory.
  hvst ls

  # List only audio files+metadata.
  hvst ls audio

  # List only book files WITHOUT metadata.  (filename only)
  hvst ls book -1

  # List types of files that exist in this directory and their counts.
  hvst types

  # Copy all images to ~/Pictures.
  hvst cp image ~/Pictures

  # Copy all images to ~/Pictures and be verbose.
  hvst cp image ~/Pictures --verbose

  # Show what would happen if we tried to move all images to ~/Pictures/YYYY/MM.
  hvst mv image @'"~/Pictures/$year/$month"' --recon

  # Move all videos to ~/Videos/YYYY/MM.
  hvst mv video @'"~/Videos/$year/$month"'

  # Move all books to ~/Dropbox/books using tmsu-fs-mv.
  hvst tmv book ~/Dropbox/books

  # The cp, mv, and tmv commands take --verbose and --recon
  # (or -v and -r for short).
  # --verbose means print the shell command.
  # --recon   means print the shell command but don't execute it.
```

### Destination Expressions

The `<DEST>` for for `cp`, `mv`, and `tmv` can be a Perl expression.
A Leading "@" tells `hvst` to evaluate the string as Perl code.
The following variables will be available.

* $i     - numeric index
* $nt    - node type (file or dir)
* $t     - file type
* $d     - date in YYYY-MM-DD format
* $mt    - modified time in seconds
* $year  - year
* $month - month (zero padded)
* $day   - day (zero padded)
* $s     - size in bytes
* $n     - name

The `$_` variable is also available and is a hashref containing all of the above values.

## My System

To keep my `~/Downloads` tidy, I use these aliases and run them periodically.
I don't run this automatically, because I often delete files I don't want before
running `hvst`.

```bash
  alias hmvi="hvst mv image @'\"~/Pictures/\$year/\$month\"'"
  alias hmvv="hvst mv video @'\"~/Videos/\$year/\$month\"'"
```

To help me find them later, I tag them with [tmsu](https://github.com/oniony/TMSU).
