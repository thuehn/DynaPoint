m = Map("dynapoint", "DynaPoint", "Dynamic Access Point Validator and Creator")

s = m:section(NamedSection, "internet", "rule", "Internet", "Internet connectivity")

pinghost = s:option(Value, "host", "Host address", "address to check the availability")
pinghost.datatype = "host(1)"
pinghost.default = "http://www.example.com"

interval = s:option(Value, "interval", "Interval", "How often to check Internet connection in seconds")
interval.datatype = "uinteger"
interval.default = "30"

timeout = s:option(Value, "timeout", "Timeout", "Timeout when trying to check Internet availability of host")
timeout.datatype = "uinteger"
timeout.default = "5"

offline_treshold = s:option(Value, "offline_treshold", "Offline treshold", "After how many times of checking, the connection is considered offline")
offline_treshold.datatype = "uinteger"
offline_treshold.default = "1"

add_hostname_to_ssid = s:option(Flag, "add_hostname_to_ssid", "Append hostname to ssid", "Append the router's hostname to the SSID when connectivity check fails")
add_hostname_to_ssid.datatype = "bool"
add_hostname_to_ssid.default = "0"

return m