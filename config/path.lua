path = {}
path.rtt = os.getenv('RTT_PATH')
path.opts = path.rtt..'/config/opts.json'
return path
