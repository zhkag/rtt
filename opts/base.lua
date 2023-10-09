Base = {name='base',prefix='',param=0,alias={},description='description'}

function Base:new (o,name)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.name = name
  return o
end

function Base:getName()
  return self.name
end

function Base:getAlias()
  return #(self.alias) , self.alias
end

function Base:getDescription()
  return self.description
end

function Base:setConfig(config)
end

function Base:run(...)
  return {...}, ''
end

return Base
