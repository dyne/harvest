#!/usr/bin/env zsh

# Copyright (C) 2014-2018 Dyne.org Foundation

# Harvest is designed, written and maintained by Denis "Jaromil" Roio

# This source code is free software; you can redistribute it and/or
# modify it under the terms of the GNU Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This source code is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  Please refer
# to the GNU Public License for more details.
#
# You should have received a copy of the GNU Public License along with
# this source code; if not, write to: Free Software Foundation, Inc.,
# 675 Mass Ave, Cambridge, MA 02139, USA.

harvest_version=0.5
harvest_release_date="July/2018"

# export HARVEST_PREFIX=$HOME/devel/harvest
R=${HARVEST_PREFIX:-/usr/local/share/harvest}

DEBUG=${DEBUG:-0}

source $R/zuper/zuper

vars+=(files numfiles dirs)
vars+=(ext video_factor image_factor audio_factor code_factor text_factor other_factor web_factor slide_factor sheet_factor archiv_factor)

arrs+=(alldirs)

maps+=(video audio code text image other web slide sheet archiv)
maps+=(totals)

case `uname` in
  Darwin)
    STAT_OPTS="-f %Sm -t %F"
    ;;
  Linux)
    STAT_OPTS='-c %y'
    ;;
  FreeBSD)
    STAT_OPTS="-f %Sm -t %F"
    ;;
esac

source $R/zuper/zuper.init

# source the generated code parser from file-extension-list
source $R/file-extension-list/render/file-extension-parser.zsh

# fuzzy thresholds
#
# this is the most important section to tune the selection: the higher
# the values the more file of that type need to be present in a
# directory to classify it with their own type. In other words a lower
# number makes the type "dominant".
video_factor=1  #  minimum video files to increase the video factor
audio_factor=3  #  minimum audio files to increase the audio factor
text_factor=8   #  minimum text  files to increase the text factor
image_factor=10 #  minimum image files to increase the image factor
other_factor=20 #  minimum other files to increase the other factor
code_factor=5   #  minimum code  files to increase the code factor
web_factor=10
slide_factor=2
sheet_factor=3
archiv_factor=10

notice "Harvest $harvest_version - a tool to classify large collections of files and directories"

# counts all totals using a basic fuzzy logic algo and prints results
fuzzycount() {
    fn fuzzycount $*
    arg=$1
    req=(arg)
    ckreq || return 1

    # this redefines the priority order
    choice=(video audio image text web slide sheet archiv code other)

    # succesful match means an entry is greater than all others
    match=$(( ${#choice} - 1 ))

    # reset totals
    totals[video]=0
    totals[audio]=0
    totals[other]=0
    totals[image]=0
    totals[code]=0
    totals[text]=0
	totals[web]=0
	totals[slide]=0
	totals[sheet]=0
	totals[archiv]=0

    [[ "$video[$arg]" = "" ]] && video[$arg]=0
    [[ "$audio[$arg]" = "" ]] && audio[$arg]=0
    [[ "$other[$arg]" = "" ]] && other[$arg]=0
    [[ "$image[$arg]" = "" ]] && image[$arg]=0
    [[ "$code[$arg]"  = "" ]] &&  code[$arg]=0
    [[ "$text[$arg]"  = "" ]] &&  text[$arg]=0
    [[ "$web[$arg]"  = "" ]] &&    web[$arg]=0
    [[ "$slide[$arg]"  = "" ]] && slide[$arg]=0
    [[ "$sheet[$arg]"  = "" ]] && sheet[$arg]=0
    [[ "$archiv[$arg]"  = "" ]] && archiv[$arg]=0

    # compute a very, very simple linear fuzzy logic for each
    (( ${#video} )) && totals[video]=$(( $video[$arg] / $video_factor ))
    (( ${#audio} )) && totals[audio]=$(( $audio[$arg] / $audio_factor ))
    (( ${#other} )) && totals[other]=$(( $other[$arg] / $other_factor ))
    (( ${#image} )) && totals[image]=$(( $image[$arg] / $image_factor ))
    (( ${#code}  )) &&  totals[code]=$((  $code[$arg] / $code_factor  ))
    (( ${#text}  )) &&  totals[text]=$((  $text[$arg] / $text_factor  ))
    (( ${#web}  )) &&  totals[web]=$((  $web[$arg] / $web_factor  ))
    (( ${#slide}  )) &&  totals[slide]=$((  $slide[$arg] / $slide_factor  ))
    (( ${#sheet}  )) &&  totals[sheet]=$((  $sheet[$arg] / $sheet_factor  ))
    (( ${#archiv}  )) &&  totals[archiv]=$((  $archiv[$arg] / $archiv_factor  ))

    for t in $choice; do
        count=0
        for o in ${(k)totals}; do
            # don't compare with self
            [[ "$t" = "$o" ]] && continue

            (( ${totals[$t]} > ${totals[$o]} )) && (( count++ ))
        done
        (( $count == $match )) && {
			# get the year and print out directories here 
			year=`stat ${=STAT_OPTS} $arg | cut -d'-' -f1`
			print "dir,$t,$year,$arg"
			return 0 }
    done
	year=`stat ${=STAT_OPTS} $arg | cut -d'-' -f1`
	print "dir,other,$year,$arg"
    return 0
}

analyse_files() {
	act "analysing files "
	prev=""
	numfiles=0
	for i in ${(f)1}; do
		[[ -r "$i" ]] || continue
		mime=`file-extension-parser $i`
		year=`stat ${=STAT_OPTS} $i | cut -d'-' -f1`
		files+="file,$mime,$year,$i\n"
		(print -n "." 1>&2)
		numfiles=$(( $numfiles + 1 ))
	done
}
analyse_dirs() {
	prev=""
	for i in ${(f)1}; do

		mime=`file-extension-parser $i`
		base=$2
		func "$mime \t $base"

		[[ "$base" = "" ]] && continue;

		case "$mime" in

			video) (( ++video[$base] )) ;;

			audio) (( ++audio[$base] )) ;;

			image) (( ++image[$base] )) ;;

			code)  (( ++code[$base] ))  ;;

			text)  (( ++text[$base] ))  ;;

			slide)  (( ++slide[$base] ))  ;;

			web)  (( ++web[$base] ))  ;;

			sheet)  (( ++sheet[$base] ))  ;;

			archiv)  (( ++archiv[$base] ))  ;;

			*)     (( ++other[$base] ))
				   # func "${(r:5:)other[$base]} other :: $base"
				   ;;

		esac

		[[ "$prev" = "$base" ]] || {
			(print -n "." 1>&2)
			prev="$base" }
		alldirs+=($base)
	done
}

cache_check() {
	[[ -r $cache ]] || {
		error "cache is empty: $cache"
		return 1 }
	return 0
}

root_check() {
    root=`grep -m 1 '^#+root:' $cache | cut -d: -f2 | trim`
	[[ -d $root ]] || {
		error "no root found in cache"
		return 1 }
	return 0
}

## lists only cached items that actually exist
cache_list() {
	needle="$1"
	for i in ${(f)"$(cat $cache)"}; do
		[[ "${i[1]}" = "#" ]] && continue
		fname=${i[(ws:,:)4]}
		[[ -r "$fname" ]] || continue
		[[ "$needle" == "" ]] && { print $i; continue }
		fstype=${i[(ws:,:)1]}
		genre=${i[(ws:,:)2]}
		year=${i[(ws:,:)3]}
		[[ "$fstype" = "$needle" ]] && print "$i"
		[[ "$genre" = "$needle" ]] && print "$i"
		[[ "$year" = "$needle" ]] && print "$i"
	done
}

getattr() {
    a=$1; v=$2
    shift 3
    getfattr -n $a $* |
		awk "BEGIN  {
      RS=\"# file: \"
      FS=\"\n\"
    }/=\"$v\"/ { print \$1 }"
}

# return here if sourcing as lib
[[ "$1" == "source" ]] && {
	zuper.exit
	return 0
}

# main argument: harvest will parse all filenames found in incoming
incoming="${1:-`pwd`}"
cache=$HOME/.cache/harvest
bmarks=$HOME/.config/gtk-3.0/bookmarks

# TODO: build proper argument parsing and useful options
#       -e to exclude path string patterns from analysis

if   [[ "$incoming" = "source" ]]; then
    act "internal functions loaded"
    zuper.exit; return 0

elif [[ -d "$incoming" ]]; then
	# [[ ${incoming[0]} == "/" ]] || {
	# 	pushd "$incoming"; incoming=`pwd`; popd }
    incoming=${incoming}/
	depth=${2:-2}
    act   "scanning directory: $incoming (depth $depth)"
	analyse_files "`find $incoming -maxdepth 1 -type f | tail -n +2`"
	print
	[[ "files" == "$2" ]] || {
		act "analysing directories "
		for d in ${(f)"$(find $incoming -maxdepth 1 -type d | tail -n +2)"}; do
			# TODO: make depth configurable
			analyse_dirs "`find $d -maxdepth $depth`" $d
		done
		print
	}
	mkdir -p $HOME/.cache
	rm -f $cache
	print "#+root: $incoming" > $cache
	print "#+depth: $depth"  >> $cache
	print "${files}" | /usr/bin/tee -a $cache
	[[ "files" == "$2" ]] || {
		for o in $alldirs; do
			fuzzycount "$o"  | /usr/bin/tee -a $cache
		done
	}
	notice "${numfiles} files and ${#alldirs} directories analysed in total"
	act   "results saved, use 'harvest ls' to replay on stdout"


elif [[ "$incoming" == "mv" ]]; then
	needle="$2"
	dest="$3"
	moved=0
	[[ "$dest" = "" ]] && {
		error "missing argument: destination folder"
		act "usage: $0 mv type destination/"
		zuper.exit; return 1 }
	[[ -d "$dest" ]] || {
		error "destination is not a folder: $dest"
		act "usage: $0 mv type destination/"
		zuper.exit; return 1 }
	cache_check || { zuper.exit; return 1 }
	act "Moving harvested files to folder: $dest"
	[[ "$needle" = "all" ]] && needle=""
	for i in ${(f)"$(cache_list $needle)"}; do
		fname=${i[(ws:,:)4]}
		func "mv $fname $dest/"
		# this is the only place where harvest modifies the filesystem
		mv $fname $dest/
		moved=$(( $moved + 1 ))
	done
	act "Done moving $moved items."
	zuper.exit; return 0

elif [[ "$incoming" == "ls" ]]; then
	cache_check || { zuper.exit; return 1 }
	act "Listing harvested files $2"
	cache_list $2
	zuper.exit; return 0

# using attr (getfattr / setfattr)
elif [[ "$incoming" == "attr" ]]; then
	if command -v setfattr; then
        cache_check || { zuper.exit; return 1 }
        act "Set tags as filesystem extended attributes"
        act "using harvest.type key/value store"
        root=`grep -m 1 '^#+root:' $cache | cut -d: -f2 | trim`
        pushd $root
        for i in ${(f)"$(cache_list $2)"}; do
            fname=${i[(ws:,:)4]}
            ftype=${i[(ws:,:)2]}
            fyear=${i[(ws:,:)3]}
            setfattr -n "harvest.type" -v "$ftype" "$fname"
            setfattr -n "harvest.year" -v "$fyear" "$fname"
        done
        popd; zuper.exit; return 0
    else
		error "attr commands not found (setfattr)"
	fi

# using tmsu
elif [[ "$incoming" == "tmsu" ]]; then
	command -v tmsu >/dev/null || {
		error "tmsu command not found"
		zuper.exit; return 1 }
    cache_check || { zuper.exit; return 1 }
    act "Tagging harvested files with tmsu"
    root=`grep -m 1 '^#+root:' $cache | cut -d: -f2 | trim`
    pushd $root
    func "tmsu init -v -D $root"
    tmsu init -v -D $root
    tmsu config \
         autoCreateTags=yes \
         autoCreateValues=no \
         directoryFingerprintAlgorithm=none \
         fileFingerprintAlgorithm=none \
         reportDuplicates=yes

    for i in ${(f)"$(cache_list $2)"}; do
        fname=${i[(ws:,:)4]}
        [[ -r "$fname" ]] || continue
        ftype=${i[(ws:,:)2]}
        fyear=${i[(ws:,:)3]}
        # act "tmsu tag $fname $ftype"
        tmsu tag "$fname" "$ftype"
        numfiles=$(( $numfiles + 1 ))
    done
    popd
    zuper.exit; return 0

elif [[ "$incoming" == "mount" ]]; then
	command -v tmsu >/dev/null || {
		error "tmsu command not found"
		zuper.exit; return 1 }
	cache_check || { zuper.exit; return 1 }
	root_check  || { zuper.exit; return 1 }
	[[ -r $root/.tmsu/db ]] || {
		error "tmsu tags not initialised, use 'harvest tmsu'"
		zuper.exit; return 1 }
	[[ -d $root/.mnt/tags ]] || {
		act "Mounting tagged filesystem in $root/.mnt"
		mkdir -p $root/.mnt
		tmsu mount -D $root/.tmsu/db $root/.mnt || {
			error "Error mounting tagged filesystem using tmsu"
			zuper.exit; return 1 }
	}
	# setup gtk bookmarks too (for sidebar in pcmanfm, thunar etc.)
	[[ -r $bmarks~harvest ]] || {
		mv $bmarks $bmarks~harvest
		for i in ${(f)"$(ls $root/.mnt/tags)"}; do
			print "file://$root/.mnt/tags/$i" >> $bmarks
		done
	}
	act "$root tagged filesytem ready (path in clipboard and \$harvest)"
	print $root/.mnt | xclip
	export harvest=$root/.mnt

elif [[ "$incoming" == "umount" ]]; then
	command -v tmsu >/dev/null || {
		error "tmsu command not found"
		zuper.exit; return 1 }
	for i in ${(f)"$(mount | awk '
/fuse.pathfs.pathInode/ { print $3 }')"}; do
		act "umount $i"
		tmsu umount $i
		if [[ $? = 0 ]]; then
			act "$i tagged filesystem unmounted"
		else
			error "$i error unmounting tagged filesystem"
			break
		fi
	done
	[[ -r $bmarks~harvest ]] &&
		mv $bmarks~harvest $bmarks
	unset harvest
fi

zuper.exit; return 0
