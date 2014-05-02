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

register('getLibraryVersion', 'Mat_GetLibraryVersion')
register('setVerbose', 'Mat_SetVerbose')
register('setDebug', 'Mat_SetDebug')
register('critical', 'Mat_Critical')
register('error', 'Mat_Error')
register('help', 'Mat_Help')
register('logInit', 'Mat_LogInit')
register('logClose', 'Mat_LogClose')
register('logInitFunc', 'Mat_LogInitFunc')
register('message', 'Mat_Message')
register('debugMessage', 'Mat_DebugMessage')
register('verbMessage', 'Mat_VerbMessage')
register('warning', 'Mat_Warning')
register('sizeOf', 'Mat_SizeOf')
register('sizeOfClass', 'Mat_SizeOfClass')
register('createVer', 'Mat_CreateVer')
register('close', 'Mat_Close')
register('open', 'Mat_Open')
register('getFilename', 'Mat_GetFilename')
register('getVersion', 'Mat_GetVersion')
register('rewind', 'Mat_Rewind')
register('varCalloc', 'Mat_VarCalloc')
register('varCreate', 'Mat_VarCreate')
register('varCreateStruct', 'Mat_VarCreateStruct')
register('varDelete', 'Mat_VarDelete')
register('varDuplicate', 'Mat_VarDuplicate')
register('varFree', 'Mat_VarFree')
register('varGetCell', 'Mat_VarGetCell')
register('varGetCells', 'Mat_VarGetCells')
register('varGetCellsLinear', 'Mat_VarGetCellsLinear')
register('varGetSize', 'Mat_VarGetSize')
register('varGetNumberOfFields', 'Mat_VarGetNumberOfFields')
register('varAddStructField', 'Mat_VarAddStructField')
register('varGetStructFieldnames', 'Mat_VarGetStructFieldnames')
register('varGetStructFieldByIndex', 'Mat_VarGetStructFieldByIndex')
register('varGetStructFieldByName', 'Mat_VarGetStructFieldByName')
register('varGetStructField', 'Mat_VarGetStructField')
register('varGetStructs', 'Mat_VarGetStructs')
register('varGetStructsLinear', 'Mat_VarGetStructsLinear')
register('varPrint', 'Mat_VarPrint')
register('varRead', 'Mat_VarRead')
register('varReadData', 'Mat_VarReadData')
register('varReadDataAll', 'Mat_VarReadDataAll')
register('varReadDataLinear', 'Mat_VarReadDataLinear')
register('varReadInfo', 'Mat_VarReadInfo')
register('varReadNext', 'Mat_VarReadNext')
register('varReadNextInfo', 'Mat_VarReadNextInfo')
register('varSetCell', 'Mat_VarSetCell')
register('varSetStructFieldByIndex', 'Mat_VarSetStructFieldByIndex')
register('varSetStructFieldByName', 'Mat_VarSetStructFieldByName')
register('varWrite', 'Mat_VarWrite')
register('varWriteInfo', 'Mat_VarWriteInfo')
register('varWriteData', 'Mat_VarWriteData')
register('calcSingleSubscript', 'Mat_CalcSingleSubscript')
register('calcSubscripts', 'Mat_CalcSubscripts')


return mat

