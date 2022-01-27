#!/usr/bin/env luajit

-- Copyright (C) 2014-2022 Dyne.org Foundation

-- Harvest is designed, written and maintained by Denis "Jaromil" Roio

-- This source code is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Public License as published by
-- the Free Software Foundation; either version 3 of the License, or
-- (at your option) any later version.
--
-- This source code is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  Please refer
-- to the GNU Public License for more details.
--
-- You should have received a copy of the GNU Public License along with
-- this source code; if not, write to: Free Software Foundation, Inc.,
-- 675 Mass Ave, Cambridge, MA 02139, USA.

local lfs = require'lfs'

-- require local lua libs from src
package.path = package.path ..";"..lfs.currentdir().."/src/?.lua"

local cli = require'cliargs'

local align = require'align'

local function stderr(_msg) io.stderr:write(_msg..'\n') end
local function stdout(_msg) io.stdout:write(_msg..'\n') end

-- # fuzzy thresholds
-- #
-- # this is the most important section to tune the selection: the higher
-- # the values the more file of that type need to be present in a
-- # directory to classify it with their own type. In other words a lower
-- # number makes the type "dominant".
local fuzzy = {
   video=1,  --  minimum video files to increase the video factor
   audio=3,  --  minimum audio files to increase the audio factor
   text=10,   --  minimum text  files to increase the text factor
   image=10, --  minimum image files to increase the image factor
   other=25, --  minimum other files to increase the other factor
   code=5,   --  minimum code  files to increase the code factor
   web=10,
   slide=2,
   sheet=3,
   archiv=10
}

-- https://github.com/dyne/file-extension-list
local file_extension_list = { ["ogm"] = "video",["doc"] = "text",["hs"] = "code",["scala"] = "code",["js"] = "code",["swift"] = "code",["cc"] = "code",["jsp"] = "code",["tga"] = "image",["ape"] = "audio",["woff2"] = "font",["cab"] = "archive",["whl"] = "archive",["mpe"] = "video",["rmvb"] = "video",["srt"] = "video",["csh"] = "code",["tex"] = "text",["cs"] = "code",["exe"] = "exec",["m4a"] = "audio",["zsh"] = "code",["crx"] = "exec",["vob"] = "video",["xm"] = "audio",["gz"] = "archive",["org"] = "text",["ada"] = "code",["lhs"] = "code",["azw"] = "book",["for"] = "code",["gif"] = "image",["rb"] = "code",["3g2"] = "video",["cob"] = "code",["ar"] = "archive",["vb"] = "code",["sid"] = "audio",["ai"] = "image",["wma"] = "audio",["pea"] = "archive",["lisp"] = "code",["bmp"] = "image",["py"] = "code",["2.ada"] = "code",["mp4"] = "video",["m4p"] = "video",["aaf"] = "video",["jpeg"] = "image",["3dm"] = "image",["command"] = "exec",["go"] = "code",["azw4"] = "book",["otf"] = "font",["ebook"] = "text",["eps"] = "image",["rtf"] = "text",["cbz"] = "book",["ttf"] = "font",["1.ada"] = "code",["bat"] = "code",["mobi"] = "book",["diff"] = "code",["ra"] = "audio",["cpio"] = "archive",["xz"] = "archive",["php"] = "code",["s"] = "code",["dmg"] = "archive",["flv"] = "video",["asf"] = "video",["css"] = "web",["zipx"] = "archive",["mpg"] = "video",["xls"] = "sheet",["cpp"] = "code",["jpg"] = "image",["mkv"] = "video",["nsv"] = "video",["jsx"] = "code",["mp3"] = "audio",["adb"] = "code",["h"] = "code",["m4"] = "code",["java"] = "code",["cbl"] = "code",["hpp"] = "code",["class"] = "code",["lua"] = "code",["m2v"] = "video",["fth"] = "code",["deb"] = "archive",["rst"] = "text",["csv"] = "sheet",["hh"] = "code",["hxx"] = "code",["c"] = "code",["m4v"] = "video",["pls"] = "audio",["pak"] = "archive",["tbz2"] = "archive",["aiff"] = "audio",["egg"] = "archive",["log"] = "text",["swg"] = "code",["gpx"] = "image",["e"] = "code",["d"] = "code",["bz2"] = "archive",["f"] = "code",["fish"] = "code",["iso"] = "archive",["apk"] = "archive",["it"] = "audio",["webm"] = "video",["3ds"] = "image",["au"] = "audio",["patch"] = "code",["rs"] = "code",["kml"] = "image",["woff"] = "font",["r"] = "code",["max"] = "image",["3gp"] = "video",["po"] = "code",["v"] = "code",["mng"] = "video",["rpm"] = "archive",["a"] = "archive",["htm"] = "code",["s7z"] = "archive",["ics"] = "sheet",["bash"] = "code",["f90"] = "code",["flac"] = "audio",["azw3"] = "book",["mp2"] = "video",["asm"] = "code",["xml"] = "code",["ksh"] = "code",["epub"] = "book",["bas"] = "code",["svg"] = "image",["tgz"] = "archive",["mpa"] = "audio",["wmv"] = "video",["vcxproj"] = "code",["mpeg"] = "video",["mpv"] = "video",["less"] = "web",["f77"] = "code",["c++"] = "code",["m3u"] = "audio",["dwg"] = "image",["odt"] = "text",["msg"] = "text",["ads"] = "code",["msi"] = "exec",["png"] = "image",["gsm"] = "audio",["ogg"] = "video",["cbr"] = "book",["azw1"] = "book",["pages"] = "text",["dds"] = "image",["docx"] = "text",["azw6"] = "book",["mid"] = "audio",["ftn"] = "code",["odp"] = "slide",["aac"] = "audio",["s3m"] = "audio",["avi"] = "video",["ogv"] = "video",["ods"] = "sheet",["groovy"] = "code",["eot"] = "font",["dxf"] = "image",["nim"] = "code",["html"] = "code",["wpd"] = "text",["bin"] = "exec",["txt"] = "text",["pp"] = "code",["rm"] = "video",["m"] = "code",["ps"] = "image",["psd"] = "image",["ppt"] = "slide",["clj"] = "code",["roq"] = "video",["mod"] = "audio",["tiff"] = "image",["lha"] = "archive",["mxf"] = "video",["7z"] = "archive",["drc"] = "video",["yuv"] = "image",["wps"] = "text",["sh"] = "code",["mar"] = "archive",["vcf"] = "sheet",["shar"] = "archive",["xcf"] = "image",["tlz"] = "archive",["jar"] = "archive",["qt"] = "video",["tar"] = "archive",["xpi"] = "archive",["zip"] = "archive",["xcodeproj"] = "code",["cxx"] = "code",["kt"] = "code",["rar"] = "archive",["md"] = "text",["scss"] = "web",["pdf"] = "text",["webp"] = "image",["war"] = "archive",["pl"] = "code",["xlsx"] = "sheet",["svi"] = "video",["thm"] = "image",["avchd"] = "video",["tif"] = "image",["mov"] = "video",["kmz"] = "image",["wasm"] = "web",["el"] = "code",["wav"] = "audio",}

local function extparser(arg)
   local curr = 0
   repeat
	  local n = arg:find('.',curr+1, true)
	  if n then curr = n end
   until (not n)
   if (curr == 0) then return nil end
   return(arg:sub( curr + 1 ))
end

-- recurse into directories
local function analyse_path(basedir, pathname, level)
   local target = pathname or basedir
   local curlev = level or 1
   local scores = { other = { } }
   local path
   for path in lfs.dir(target) do
	  if not (path == '.' or path == '..') then
		 local tarpath = target..'/'..path
		 if lfs.attributes(tarpath,"mode") == "directory" then
			analyse_path(basedir, tarpath, curlev+1)

	 else -- file in subdir
			local ftype = file_extension_list[ extparser(tarpath) ]
			if ftype then
			   if not scores[ftype] then scores[ftype] = { } end
			   table.insert(scores[ftype], tarpath)
			else
			   table.insert(scores['other'], tarpath)
			end
		 end
	  end
   end
   return scores
end

local function fuzzyguess(scores)
   -- compute a very, very simple linear fuzzy logic for each
   local res = { guess = 'other',
				 totals = { } }
   for k,v in pairs(scores) do
	  res.totals[k] = #v / (fuzzy[k] or fuzzy['other'])
   end
   local max = 0
   for k,v in pairs(res.totals) do
	  if v > max then
		 max = v
		 res.guess = k
	  end
   end
   return res
end

-- checks that the file attributes match the selection arguments
local function filter_selection(args, attr)
   if args.type and (args.type ~= attr.guess) then return false end
   if args.file and attr.mode == 'directory' then return false end
   if args.dir and attr.mode ~= 'directory' then return false end
   return true
end

local function show_selection(args, selection)
   if args.output == 'human' then
      stderr(align('LINE,MODE,TYPE,YYYY-MM-DD,SIZE,NAME'))
      stderr(align('----,----,----,----------,----,----'))
   end
   -- for k,v in pairs(selection) do
   for k=1, #selection do
      local v = selection[k]
      if args.output == 'csv' then
         stdout(v.type..","..v.guess..","..v.modification..","
		..v.size..","..v.name)
         -- human friendly formatting
      else
	 local size = v.size
	 local guess = v.guess
	 if v.type == 'dir' then size = '/' end
	 if v.guess == 'other' then guess = '? ? ?' end
	 if v.guess == 'archiv' then guess = 'archv' end
         stdout(align(k..","..v.type..","..guess..","
		      ..os.date('%Y-%m-%d',v.modification)..","
		      ..size..","..v.name))
      end
   end
end

-- CLI: command line argument parsing

cli:set_name("harvest")
cli:set_description('manage large collections of files and directories')

cli:option("-p, --path=PATH", "", lfs.currentdir())
cli:option("-t, --type=TYPE", "text, audio, video, etc. (-t list)")
cli:option("-o, --output=FORMAT", "csv", 'human')
cli:flag("--dir", "select only directories")
cli:flag("--file", "select only files")
cli:flag("-d", "run in DEBUG mode", function() DEBUG=1 end)
cli:flag("-v, --version", "print the version and exit", function()
			print("Harvest version 0.8") os.exit(0) end)

local args, err = cli:parse(arg)
local selection = { }

-- MAIN()
if not args and err then
   -- print(cli.name .. ': command not recognized')
   stderr(err)
   os.exit(1)
elseif args then -- default command is scan
   stderr("Harvest "..args.path)
   if args.type == 'list' then
      local list = { }
      for k,v in pairs(file_extension_list) do
	 table.insert(list, v)
      end
      print'Supported types:'
      local hash = { }
      for _,v in ipairs(list) do
	 if not hash[v] then
	    io.stdout:write(' '..v)
	    hash[v] = true
	 end
      end
      io.stdout:write('\n')
      os.exit(0)
   end
   if args.type then stderr("type: "..args.type) end

   -- recursive
   local fattr = lfs.attributes
   for file in lfs.dir(args.path) do
      local filepath = args.path.."/"..file
      if not (file == '.' or file == '..') then
         local attr = fattr(filepath)
         attr.name = file
         -- I(attr)
         if type(attr) == 'table' then -- safety to os stat
            if attr.mode == "directory" then
               attr.type = 'dir'
               attr.guess = fuzzyguess(
                  analyse_path(args.path, filepath, 3) ).guess
               collectgarbage'collect' -- recursion costs memory
	       if filter_selection(args,attr) then
		  table.insert(selection, attr)
	       end
            else
               attr.type = 'file'
               attr.guess =
                  file_extension_list[ extparser(filepath) ]
                  or 'other'
	       if filter_selection(args,attr) then
		  table.insert(selection, attr)
	       end
            end
         end
      end
   end
end

-- print to screen
stderr(os.date())
show_selection(args,selection)
