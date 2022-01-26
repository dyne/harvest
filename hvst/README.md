# hvst

A wrapper around **[dyne/harvest](https://github.com/dyne/harvest)** that fills in [missing functionality](https://github.com/dyne/harvest/issues/5)

## Installation

```sh
cp hvst ~/.local/bin
```

Dependencies:  harvest, perl, mkdir, cp, mv

## Usage

```
  hvst
  hvst help
  hvst ls [TYPE]
  hvst types
  hvst cp <TYPE> <DEST> [OPTION]...
  hvst mv <TYPE> <DEST> [OPTION]...
```

## Examples

```sh
  # Display help message.
  hvst help

  # List files in current directory.
  hvst

  # Also list files in current directory.
  hvst ls

  # List only audio files.
  hvst ls audio

  # List types of files that exist in this directory and their counts.
  hvst types

  # Copy all images to ~/Pictures.
  hvst cp image ~/Pictures

  # Copy all images to ~/Pictures and be verbose.
  hvst cp image ~/Pictures --verbose

  # Show what would happen if we tried to move all images to ~/Pictures/YYYY/MM.
  hvst mv image @'"~/Pictures/$_->{year}/$_->{month}"' --recon

  # Move all videos to ~/Videos/YYYY/MM.
  hvst mv video @'"~/Videos/$_->{year}/$_->{month}"'

  # Both cp and mv commands take --verbose and --recon (or -v and -r for short).
  # --verbose means print the shell command.
  # --recon   means print the shell command but don't execute it.
```

### Destination Expressions

The `<DEST>` for for both `cp` and `mv` can be a Perl expression.
A Leading "@" tells `hvst` to evaluate the string as Perl code.
The `$_` variable will be a hashref with the following keys.

* i     - numeric index
* nt    - node type
* t     - file type
* d     - date
* year  - year
* month - month (zero padded)
* day   - day (zero padded)
* s     - size
* n     - name

## Known Issues

* Filenames with literal tab characters break `hvst`.  The upstream `harvest` seems to expands tabs to spaces when printing them out.
