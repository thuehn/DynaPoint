local uci = require "luci.model.uci".cursor()

local wlcursor = luci.model.uci.cursor_state()
local wireless = wlcursor:get_all("wireless")
local ifaces = {}

for k, v in pairs(wireless) do
  if v[".type"] == "wifi-iface" then
    table.insert(ifaces, v)
  end
end

m = Map("dynapoint", "DynaPoint", "Dynamic Access Point Validator and Creator")
m:chain("wireless")


m1 = Map("wireless") 


aps = m1:section(TypedSection, "wifi-iface", "Access Points")
aps.addremove = false
aps.anonymous = true
aps.template  = "cbi/tblsection"

ssid = aps:option(DummyValue, "ssid", "SSID")


action = aps:option(ListValue, "dynapoint", "action")
action.widget="select"
action:value("1","use if online")
action:value("0","use if offline")
action:value("2","don't use by dynapoint")

s = m:section(NamedSection, "internet", "rule", "Internet", "Internet connectivity")

pinghost = s:option(Value, "host", "Host address", "address to check the availability")
pinghost.datatype = "string"
pinghost.default = "http://www.example.com"

interval = s:option(Value, "interval", "Interval", "How often to check Internet connection in seconds")
interval.datatype = "uinteger"
interval.default = "30"

timeout = s:option(Value, "timeout", "Timeout", "Timeout when trying to check Internet availability of host")
timeout.datatype = "uinteger"
timeout.default = "5"

add_hostname_to_ssid = s:option(Flag, "add_hostname_to_ssid", "Append hostname to ssid", "Append the router's hostname to the SSID when connectivity check fails")
--add_hostname_to_ssid.enabled = "1"
--add_hostname_to_ssid.disabled = "0"
add_hostname_to_ssid.rmempty = false

offline_treshold = s:option(Value, "offline_treshold", "Offline treshold", "After how many times of checking, the connection is considered offline")
offline_treshold.datatype = "uinteger"
offline_treshold.default = "1"


return m,m1