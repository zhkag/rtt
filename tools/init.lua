tools = {}

function tools.main(...)
  for k,v in pairs (require("config.tools")) do
    for i,v in pairs(v) do
      if os.execute("test -e " .. v) then
        return k
      end
    end
  end
end

return tools
