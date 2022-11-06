JSON = require'json'

local function stderr(_msg) io.stderr:write(_msg..'\n') end

-- see if the file exists
function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
function read_from(file)
  if not file_exists(file) then return {} end
  local buf = ""
  for line in io.lines(file) do 
    buf = buf .. line
  end
  return buf
end


function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = "' .. dump(v) .. '",'
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

local file = 'extensions.json'
local buf
if not file_exists(file) then
   stderr("file not found: ".. file)
   os.exit(1)
end
if file_exists(file) then
   buf = read_from(file)
end
-- print(buf)
local extensions = JSON.decode(buf)
-- remove nested array
local res = { }
for k,v in pairs(extensions) do
   res[k] = v[1]
end
print(dump(res))
