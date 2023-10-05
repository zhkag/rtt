local cjson = require('cjson')
local Config = {name='file'}

function Config:new (o,name)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.name = name
  return o
end

local function file_load(filename)
  local file
  if filename == nil then
    file = io.stdin
  else
    local err
    file, err = io.open(filename, "rb")
    if file == nil then
      error(("Unable to read '%s': %s"):format(filename, err))
    end
  end
  local data = file:read("*a")

  if filename ~= nil then
    file:close()
  end

  if data == nil then
    error("Failed to read " .. filename)
  end

  return data
end

local function file_save(filename, data)
  local file
  if filename == nil then
    file = io.stdout
  else
    local err
    file, err = io.open(filename, "wb")
    if file == nil then
      error(("Unable to write '%s': %s"):format(filename, err))
    end
  end
  file:write(data)
  if filename ~= nil then
    file:close()
  end
end

function Config:load()
  local json_text = file_load(self.name)
  local data = cjson.decode(json_text)
  return data
end

function Config:write(data)
  local json_str = cjson.encode(data)
  file_save(self.name,json_str)
end

return Config
