require 'torch'
local ffi = require 'ffi'
local mat = require 'matio.ffi'

local matio = {}
matio.ffi = mat

local function mat_read_variable(file, name)
   local var = mat.varRead(file, name);
   if var == nil then
      print('Could not find variable with name: ' .. name .. ' in file: ' .. ffi.string(mat.getFilename(file)))
      mat.close(file);
      return
   end
   local out
   local sizeof
   -- type check
   if var.class_type == mat.C_CHAR or var.class_type == mat.C_INT8 then
      out = torch.CharTensor()
      sizeof = 1
   elseif var.class_type == mat.C_UINT8 then
      out = torch.ByteTensor()
      sizeof = 1
   elseif var.class_type == mat.C_INT16 or var.class_type == mat.C_UINT16 then
      out = torch.ShortTensor()
      sizeof = 2
   elseif var.class_type == mat.C_INT32 or var.class_type == mat.C_UINT32 then
      out = torch.IntTensor()
      sizeof = 4
   elseif var.class_type == mat.C_INT64 or var.class_type == mat.C_UINT64 then
      out = torch.LongTensor()
      sizeof = 8
   elseif var.class_type == mat.C_SINGLE then
      out = torch.FloatTensor()
      sizeof = 4
   elseif var.class_type == mat.C_DOUBLE then
      out = torch.DoubleTensor()
      sizeof = 8
   else
      print('Unsupported type of variable, only matrices are supported, cells, structs, objects and functions are not supported for loading')
      mat.close(file);
      return
   end

   -- rank check
   if var.rank > 8 or var.rank < 1 then
      print('Rank of input matrix is invalid: ' .. var.rank)
      mat.close(file);
      return
   end
   
   local sizes = {}
   for i=0,var.rank-1 do
      table.insert(sizes, tonumber(var.dims[i]))
   end
   -- reverse initialize because of column-major order of matlab
   local revsizes = {}
   for i=1, var.rank do
      revsizes[i] = sizes[var.rank-i+1]
   end

   -- resize tensor
   out:resize(torch.LongStorage(revsizes))

   -- memcpy
   ffi.copy(out:data(), var.data, out:nElement() * sizeof);
   mat.varFree(var);
   mat.close(file);
   -- -- transpose, because matlab is column-major
   if out:dim() > 1 then
      for i=1,math.floor(out:dim()/2) do
         out=out:transpose(i, out:dim()-i+1)
      end
   end
   return out
end

--[[
   Load a given variable from a given .mat file as a torch tensor of the appropriate type
   matio.load(filename, variableName)

   Example:
   local img1 = matio.load('data.mat', 'img1')
--]]
function matio.load(filename, name)
   local file = mat.open(filename, mat.ACC_RDONLY);
   if file == nil then
      print('File could not be opened: ' .. filename)
      return
   end

   local names
   local string_name
   -- if name is not given then load everything
   if not name then
      names = {}
   elseif type(name) == 'string' then
      names = {name}
      string_name = true
   elseif type(name) == 'table' then
      names = name
   end

   if #names == 0 then
      -- go over the file and get the names
      local var = mat.varReadNextInfo(file)
      while var ~= nil do
         table.insert(names, ffi.string(var.name))
         var = mat.varReadNextInfo(file)
      end
   end

   if #names == 0 then
      print('No variables in this file')
      return
   end

   local out = {}
   for i, varname in ipairs(names) do
      local x = mat_read_variable(file, varname)
      if not x then
         return
      end
      out[varname] = x
   end

   -- conserve backward compatibility
   if #names == 1 and string_name then
      return out[names[1]]
   else
      return out
   end
end

return matio
