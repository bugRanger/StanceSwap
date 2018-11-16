print('version: ' .. _VERSION)

local function Trace(text)
 print(text)
end

local function IsCombat()
 return 'is not combat';
end
local function IsHarm()
 return 'is harm';
end
local function IsRange()
 return 'is not range';
end

local table = {
	[1] = function()return IsCombat()end,
	[2] = function()return IsHarm()end,
	[4] = function()return IsRange()end
}

local value = 11;

for bit, func in pairs(table) do
 if bit32.band(value, bit) == bit then
  local sucess, result = pcall(func);
  Trace('check: '..result);
 end
end