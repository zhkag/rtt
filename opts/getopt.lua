getopt = {}

local function convert_short2long(opts)
  local ret = {}
  for short_opt, accept_arg in opts:gmatch("(%w)(:?)") do
    ret[short_opt]=#accept_arg
  end
  return ret
end

local function exit_with_error(msg, exit_status)
  io.stderr:write(msg)
  os.exit(exit_status)
end

local function err_unknown_opt(opt)
  exit_with_error("Unknown option `-" ..
                  (#opt > 1 and "-" or "") .. opt .. "'\n", 1)
end

local function canonize(options, opt)
  if not options[opt] then
    err_unknown_opt(opt)
  end
  while type(options [opt]) == "string" do
    opt = options [opt]
    if not options [opt] then
      err_unknown_opt (opt)
    end
  end
  return opt
end

function getopt.get_ordered_opts(arg, sh_opts, long_opts)
  local i      = 1
  local count  = 1
  local opts   = {}
  local optarg = {}
  local options = convert_short2long (sh_opts)
  for k,v in pairs (long_opts) do
    options[k] = v
  end
  while i <= #arg do
    local a = arg [i]
    if a == "--" then
      i = i + 1
      break
    elseif a == "-" then
      break
    elseif a:sub (1, 2) == "--" then
      local pos = a:find ("=", 1, true)
      if pos then
        local opt = a:sub (3, pos-1)
        opt = canonize (options, opt)
        if options[opt] == 0 then
          exit_with_error ("Bad usage of option `" .. a .. "'\n", 1)
        end
        optarg [count] = a:sub (pos+1)
        opts [count] = opt
      else
        local opt = a:sub (3)
        opt = canonize (options, opt)
        if options [opt] == 0 then
          opts [count] = opt
        else
          if i == #arg then
            exit_with_error ("Missed value for option `" .. a .. "'\n", 1)
          end
          optarg [count] = arg [i+1]
          opts [count] = opt
          i = i + 1
        end
      end

      count = count + 1
    elseif a:sub (1, 1) == "-" then
      for j=2,a:len () do
        local opt = canonize (options, a:sub (j, j))
        if options [opt] == 0 then
          opts [count] = opt
          count = count + 1
        elseif a:len () == j then
          if i == #arg then
            exit_with_error ("Missed value for option `-" .. opt .. "'\n", 1)
          end
          optarg [count] = arg [i+1]
          opts [count] = opt
          i = i + 1
          count = count + 1
          break
        else
          optarg [count] = a:sub (j+1)
          opts [count] = opt
          count = count + 1
          break
        end
      end
    else
      break
    end
    i = i + 1
  end
  return opts,i,optarg
end

function getopt.get_opts (arg, sh_opts, long_opts)
  local ret = {}
  local opts,optind,optarg = getopt.get_ordered_opts (arg, sh_opts, long_opts)
  for i,v in ipairs (opts) do
    ret [v] = (optarg[i]) and optarg[i] or ''
  end
  return ret,optind
end

return getopt
