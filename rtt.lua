require('opts')
require('config.toolchains')
local cmdTable, tool = opts.main(...)
if(tool ~= '') then
  tool = require("tools").getBuildTool()
end
local cmd = table.concat(cmdTable,' ')
if (tool ~= '' or cmd ~= '') then
  os.execute(setEnv()..tool..' '..cmd)
end

