require 'torch'
local ffi = require 'ffi'
local mat = require 'matio.ffi'

local matio = {}
matio.ffi = mat

--[[
   Load a given variable from a given .mat file as a torch tensor of the appropriate type
   matio.load(filename, variableName)

   Example:
   local img1 = matio.load('data.mat', 'img1')
--]]
function matio.load(filename, name)
   local file = mat.open(filename, mat.ACC_RDONLY);
   if not file then
      error('File could not be opened: ' .. filename)      
      return
   end
   local var = mat.varRead(file, name);
   if not var then
      error('Could not find var in fil: ' .. name)
      mat.close(file);
      return
   end
   local out
   -- type check
   if var.class_type == mat.C_CHAR or var.class_type == mat.C_INT8 then
      out = torch.CharTensor()
   elseif var.class_type == mat.C_UINT8 then
      out = torch.ByteTensor()
   elseif var.class_type == mat.C_INT16 or var.class_type == mat.C_UINT16 then
	 out = torch.ShortTensor()
   elseif var.class_type == mat.C_INT32 or var.class_type == mat.C_UINT32 then
	 out = torch.IntTensor()
   elseif var.class_type == mat.C_INT64 or var.class_type == mat.C_UINT64 then
	 out = torch.LongTensor()
   elseif var.class_type == mat.C_SINGLE then
	 out = torch.FloatTensor()
   elseif var.class_type == mat.C_DOUBLE then
	 out = torch.DoubleTensor()
   else
      error('Unsupported type of variable, only matrices are supported, cells, structs, objects and functions are not supported for loading')
      mat.close(file);
      return
   end

   -- rank check
   if var.rank > 8 or var.rank < 1 then
      error('Rank of input matrix is invalid: ' .. var.rank)
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
   ffi.copy(out:data(), var.data, out:nElement() * ffi.sizeof(out:data()));
   
   mat.close(file);
   -- -- transpose, because matlab is column-major
   if out:dim() > 1 then
      for i=1,out:dim() do	 
   	 out=out:transpose(1, out:dim()-i+1)
      end
   end
   return out
end


return matio
