--  Adapted from https://github.com/torch/sdl2-ffi/blob/master/dev/create-init.lua
print[[
-- Do not change this file manually
-- Generated with dev/create-ffi.lua

local ffi = require 'ffi'
local C = ffi.load('matio')
local mat = {C=C}

require 'matio.cdefs'

local defines = require 'matio.defines'
defines.register_hashdefs(mat, C)

local function register(luafuncname, funcname)
   local symexists, msg = pcall(function()
                              local sym = C[funcname]
                           end)
   if symexists then
      mat[luafuncname] = C[funcname]
   end
end
]]

local defined = {}

local txt = io.open('cdefs.lua'):read('*all')
for funcname in txt:gmatch('Mat_([^%=,%.%;<%s%(%)]+)%s*%(') do
   if funcname and not defined[funcname] then
      local luafuncname = funcname:gsub('^..', 
					function(str)                            
					   return string.lower(str:sub(1,1)) .. str:sub(2,2)					       
					end
      )
      print(string.format("register('%s', 'Mat_%s')", luafuncname, funcname))
      defined[funcname] = true
   end
end

print()

for defname in txt:gmatch('Mat_([^%=,%.%;<%s%(%)|%[%]]+)') do
   if not defined[defname] then
      print(string.format("register('%s', 'Mat_%s')", defname, defname))
   end
end

print[[

return mat
]]
