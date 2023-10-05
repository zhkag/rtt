local Base = {name='base',prefix='',param=0,alias={},description='description'}

function Base:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
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
  for k,v in pairs({...}) do
    print(k,v)
  end
end

return Base
