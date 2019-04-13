-- *****************************************************************************
-- Fetch parts list and image in rebrickable.com to create new menu files
-- for LDCad.
-- Files must be copied/moved to $LDCADHOME/partBin/default/sets
-- and $LDCADHOME/partBin/default/sets.pbg must be updated too
--
-- $> lua5.3 req.lua
-- *****************************************************************************

require ("socket")
local https = require( "ssl.https" )
require( "os" )
local json = require( "myjson" )

-- TODO: need to use arguments
_numset = "75168-1"

-- my personnal key
_SNOWGOON88_APIKEY = "e70c7ac04d6e734aca8d3b60b10a16da"

-- known replacement parts
_replacement = {
   ["3010apr0004"] = "3010p04",
   ["3626apr0001"] = "3026ap01",
   ["3933a"] = "3933",
   ["3934a"] = "3934",
   ["3940a"] = "3940",
   ["4287a"] = "4287",
}


-- *****************************************************************************
-- ******************************************************************** base_url
-- *****************************************************************************
--[[ Builds request URL using
- numset : lego set number (ex: "6929-1")
- page : which page of the request [1]
- key : apikey for rebrickable [_SNOWGOON88_APIKEY]
--]]
local function base_url( numset, page, key )
   local numset = tostring( numset )
   local page = tostring(page or 1)
   local key = key or _SNOWGOON88_APIKEY

   local url = "https://rebrickable.com/api/v3/lego/sets/" .. numset
   local url = url .. "/parts/?key=" .. key
   local url = url .. "&page=" .. page

   return url
end
-- *****************************************************************************

-- *****************************************************************************
-- ****************************************************************** header_str
-- *****************************************************************************
--[[ Create header string to put at start of pbg file
- num_set (string) : Lego set id
- label (string) : as will appear in LDCad menu [num_set]
--]]
local function header_str( num_set, label )
   local label = label or num_set -- default value if not given
   header = [[
[options]
kind=basic
caption=Set ]]
   header = header .. tostring(label)
   header = header .. [[

description=Parts in the ]] .. tostring(label) .. " set"
   header = header .. [[

picture=]] .. tostring( num_set ) .. ".png"
   header = header .. [[

sortOn=description


<items>
]]
   return header
end
-- *****************************************************************************


-- *****************************************************************************
-- *****************************************************************************
-- *****************************************************************************
local function get_ldcad_part( part )
   local sp = tostring( part )
   if _replacement[sp] ~= nil then
      return _replacement[sp]
   end
   return sp
end
     
-- ******************************************************************* add_parts
-- *****************************************************************************
--[[ Get JSON file with parts from 'url' and write list of part to 'out'
     If needed (multi-part file as indicated by the 'next' field of json,
     call recursively with same 'out'
- url (string) url of the request 
      example: "https://rebrickable.com/api/v3/lego/sets/NUM/parts/?key=e70&page=1"
- out (io.stream) where to write [default io.stdout]
--]]
local function add_parts( url, out )
   local out = out or io.stdout
   local body, code, headers, status = https.request( url )

   -- OK
   if code == 200 then
      local parts = json.parse( body )

      for i,p in ipairs( parts.results ) do
         local msg = get_ldcad_part(p.part.part_num) .. ".dat"
         local msg = msg .. ":[color=" .. tostring(p.color.id) .. "]"
         local msg = msg .. " [count=" .. tostring(p.quantity) .. "]"
         local msg = msg .. " [desc=" .. tostring(p.part.name) .. "]"
         --print( i, " : ", msg )
         out:write( msg, "\n" )
      end

      -- check if recursive call
      if parts.next == json.null then
         return
      else
         add_parts( parts.next, out )
      end
   end
end
-- *****************************************************************************

-- *****************************************************************************
-- *********************************************************** write to file.pbg
-- *****************************************************************************
--[[ Open filename and write LDCad Menu info for givel set
- num_set (string) : Lego set id
- filename (string) : name of file ["num_set".pbg]
- label (string) : as will appear in LDCad menu [num_set]
--]]
write_pbg_file = function( num_set, filename, label )
   local filename = filename or num_set
   local label = label or num_set
   
   local fpbg = assert( io.open( tostring(num_set) .. ".pbg", "w" ))
   fpbg:write( header_str( num_set, label ))

   local baseurl = base_url( num_set )
   print( "__URL\n", baseurl )
   add_parts( baseurl, fpbg)

   fpbg:close()
end
--[[
write_pbg_file( "6929-1" )
--]]
-- *****************************************************************************

-- *****************************************************************************
-- ******************************************************** get image using wget
-- *****************************************************************************
--[[ Get image of set using Wget
-- TODO: need to check for conversion
- num_set (string) : Lego set id
--]]
local function get_image( num_set )
   cmd = "wget https://rebrickable.com/media/sets/" .. tostring(num_set) .. ".jpg"
   err = os.execute( cmd )
   return err
end
--[[
print( "__IMAGE" )
print( "  err=" .. tostring( get_image( "6929-1" )))
--]]
-- *****************************************************************************

local baseurl = base_url( _numset )
print( "__URL\n", baseurl )
get_image( _numset )
write_pbg_file( _numset )

