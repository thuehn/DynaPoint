m = Map("dynapoint", "DynaPoint", "Dynamic Access Point Validator and Creator")

s = m:section(NamedSection, "internet", "rule", "Internet", "Internet connectivity")

pinghost = s:option(Value, "icmp_host", "Ping address", "Host address to ping")
pinghost.datatype = "host(1)"
pinghost.default = "8.8.8.8"

interval = s:option(Value, "interval", "Interval", "How often to check Internet connection in seconds.")
interval.datatype = "uinteger"
interval.default = "30"

timeout = s:option(Value, "timeout", "Timeout", "After how may seconds the interface is consideres offline (should be a bigger value than interval).")
timeout.datatype = "uinteger"
timeout.default = "40"

return m