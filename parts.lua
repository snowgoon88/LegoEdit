-- *****************************************************************************
-- parts.lua
-- store parts, a unique key is num x color
-- *****************************************************************************

Parts = {}

function Parts.new()
   local parts = {}
   return parts
end

-- *****************************************************************************
-- ******************************************************************** part_str
function Parts.part_str( part )
   local msg = "Part: " .. part.num .. " : " .. part.desc
   for col,nb in pairs( part.colors ) do
      msg = msg .. "\n    C " .. tostring(col) .. " -> " .. tostring(nb)
   end
   return msg 
end

function Parts.to_pbg_str( part )
   local msg = ""
   for col,nb in pairs( part.colors ) do
      msg = msg .. tostring( part.num ) .. ".dat"
      msg = msg .. ":[color=" .. tostring(col) .. "]"
      msg = msg .. " [count=" .. tostring(nb) .. "]"
      msg = msg .. " [desc=" .. tostring(part.desc) .. "]\n"
   end
   return msg
end

-- *****************************************************************************
-- ***************************************************************** store_parts
function Parts.store_parts( _parts, num, color, desc, nb )
   -- look for num in parts
   part = _parts[ tostring( num ) ]
   if part == nil then
      print( " must add new part" )
      _parts[tostring(num)] = {num = num, desc=desc, colors={[color]=nb} }
   else
      print( " found " .. Parts.part_str( part ))
      -- must add nb
      col = part.colors[color]
      if col == nil then
         print( " must add new color" )
         part.colors[color] = nb
      else
         print( " found color, adding... " )
         part.colors[color] = part.colors[color] + nb
      end
   end
end


-- *****************************************************************************
-- *********************************************************************** debug
function Parts.dump_parts( _parts)
   print( "__DUMP _all_parts" )
   for k,v in pairs( _parts ) do
      print( k, Parts.part_str(v) )
   end
end

-- *****************************************************************************
-- ************************************************************************ test
--[[
print( "__START" )
local _all_parts = Parts.new()
Parts.dump_parts( _all_parts )

Parts.store_parts( _all_parts, 23, 16, "Une brique 2x2", 3 )
Parts.dump_parts( _all_parts )

Parts.store_parts( _all_parts, 25, 8, "Une plaque 1x8", 1 )
Parts.dump_parts( _all_parts )

Parts.store_parts( _all_parts, 25, 8, "Une plaque 1x8", 1 )
Parts.dump_parts( _all_parts )

Parts.store_parts( _all_parts, 25, 8, "Une plaque 1x8", 1 )
Parts.dump_parts( _all_parts )

Parts.store_parts( _all_parts, 25, 27, "Une plaque 1x8", 7 )
Parts.dump_parts( _all_parts )
--]]


