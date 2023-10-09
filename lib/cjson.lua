require("tools")
require("config.path")
if(not tools.exectest(path.rtt..'/lib/cjson.so')) then
    os.execute('cd lib && git clone https://github.com/mpx/lua-cjson.git && cd lua-cjson && make')
    os.execute('cp lib/lua-cjson/cjson.so lib/cjson.so')
end

return require('cjson')
