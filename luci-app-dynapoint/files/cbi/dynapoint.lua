m = Map("dynapoint", "DynaPoint", "Dynamic Access Point Validator and Creator")

s = m:section(NamedSection, "internet", "rule", "Internet", "Internet connectivity")

pinghost = s:option(Value, "host", "host address", "address to check the availability")
pinghost.datatype = "host(1)"
pinghost.default = "http://www.example.com"

interval = s:option(Value, "interval", "Interval", "How often to check Internet connection in seconds")
interval.datatype = "uinteger"
interval.default = "30"

timeout = s:option(Value, "timeout", "Timeout", "Timeout when trying to check internet availability of host")
timeout.datatype = "uinteger"
timeout.default = "5"

return m