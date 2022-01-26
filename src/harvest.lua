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

-- debug
DEBUG=0
local inspect = require'inspect'
local function I(o) 
   if DEBUG > 0 then stderr( inspect.inspect(o) ) end end
local function D(s)
   if DEBUG > 0 then stderr(s) end
end

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
local file_extension_list = { ["3dm"] = "image", ["3ds"] = "image", ["3g2"] = "video", ["3gp"] = "video", ["7z"] = "archiv", a = "archiv", aac = "audio", aaf = "video", ai = "image", aiff = "audio", ape = "audio", apk = "archiv", ar = "archiv", asf = "video", au = "audio", avchd = "video", avi = "video", azw = "book", azw1 = "book", azw3 = "book", azw4 = "book", azw6 = "book", bat = "exec", bin = "exec", bmp = "image", bz2 = "archiv", c = "code", cab = "archiv", cbr = "book", cbz = "book", cc = "code", class = "code", clj = "code", command = "exec", cpio = "archiv", cpp = "code", crx = "exec", cs = "code", css = "web", csv = "sheet", cxx = "code", dds = "image", deb = "archiv", diff = "code", dmg = "archiv", doc = "text", docx = "text", drc = "video", dwg = "image", dxf = "image", ebook = "text", egg = "archiv", el = "code", eot = "font", eps = "image", epub = "book", exe = "exec", flac = "audio", flv = "video", gif = "image", go = "code", gpx = "image", gsm = "audio", gz = "archiv", h = "code", html = "code", ics = "sheet", iso = "archiv", it = "audio", jar = "archiv", java = "code", jpeg = "image", jpg = "image", js = "code", kml = "image", kmz = "image", less = "web", lha = "archiv", log = "text", lua = "code", m = "code", m2v = "video", m3u = "audio", m4 = "code", m4a = "audio", m4p = "video", m4v = "video", mar = "archiv", max = "image", md = "text", mid = "audio", mkv = "video", mng = "video", mobi = "book", mod = "audio", mov = "video", mp2 = "video", mp3 = "audio", mp4 = "video", mpa = "audio", mpe = "video", mpeg = "video", mpg = "video", mpv = "video", msg = "text", msi = "exec", mxf = "video", nsv = "video", odp = "slide", ods = "sheet", odt = "text", ogg = "video", ogm = "video", ogv = "video", org = "text", otf = "font", pages = "text", pak = "archiv", patch = "code", pdf = "text", pea = "archiv", php = "code", pl = "code", pls = "audio", png = "image", po = "code", ppt = "slide", ps = "image", psd = "image", py = "code", qt = "video", ra = "audio", rar = "archiv", rb = "code", rm = "video", rmvb = "video", roq = "video", rpm = "archiv", rs = "code", rst = "text", rtf = "text", s3m = "audio", s7z = "archiv", scss = "web", sh = "exec", shar = "archiv", sid = "audio", srt = "video", svg = "image", svi = "video", swift = "code", tar = "archiv", tbz2 = "archiv", tex = "text", tga = "image", tgz = "archiv", thm = "image", tif = "image", tiff = "image", tlz = "archiv", ttf = "font", txt = "text", vb = "code", vcf = "sheet", vcxproj = "code", vob = "video", war = "archiv", wasm = "web", wav = "audio", webm = "video", webp = "image", whl = "archiv", wma = "audio", wmv = "video", woff = "font", woff2 = "font", wpd = "text", wps = "text", xcf = "image", xcodeproj = "code", xls = "sheet", xlsx = "sheet", xm = "audio", xml = "code", xpi = "archiv", xz = "archiv", yuv = "video", zip = "archiv", zipx = "archiv" }

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
   -- D("analyse: "..target)
   local path
   for path in lfs.dir(target) do
	  if not (path == '.' or path == '..') then
		 local tarpath = target..'/'..path
		 if lfs.attributes(tarpath,"mode") == "directory" then
			D("found dir:\t"..tarpath.." ("..curlev..")")
			analyse_path(basedir, tarpath, curlev+1)

	 else -- file in subdir
			local ftype = file_extension_list[ extparser(tarpath) ]
			if ftype then
			   if not scores[ftype] then scores[ftype] = { } end
			   table.insert(scores[ftype], tarpath)
			   -- D("found "..ftype..":\t"..tarpath)
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
cli:flag("-v, --version", "print the version and exits", function()
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
      D("analyze "..filepath)
      if not (file == '.' or file == '..') then
         local attr = fattr(filepath)
         attr.name = file
         I(attr)
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
