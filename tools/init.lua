tools = {}

function tools.getBuildTool(...)
  for k,v in pairs (require("config.tools")) do
    for i,v in pairs(v) do
      if os.execute("test -e " .. v) then
        return k
      end
    end
  end
  return ''
end

function tools.exectest(file)
  if os.execute("test -e " .. file) then
    return true
  end
  return false
end

return tools
