local uci = require "luci.model.uci".cursor()

local wlcursor = luci.model.uci.cursor_state()
local wireless = wlcursor:get_all("wireless")
local ifaces = {}

for k, v in pairs(wireless) do
  if v[".type"] == "wifi-iface" then
    table.insert(ifaces, v)
  end
end

m = Map("dynapoint", "DynaPoint", translate("Dynamic Access Point Validator and Creator"))
m:chain("wireless")

m1 = Map("wireless") 

aps = m1:section(TypedSection, "wifi-iface", translate("Access Points"))
aps.addremove = false
aps.anonymous = true
aps.template  = "cbi/tblsection"

ssid = aps:option(DummyValue, "ssid", translate("SSID"))

action = aps:option(ListValue, "dynapoint_rule", translate("action"))
action.widget="select"
action:value("internet",translate("online"))
action:value("!internet",translate("offline"))
action:value("",translate("not used by dynapoint"))
action.default = ""

s = m:section(NamedSection, "internet", "rule", translate("Internet"), translate("Internet connectivity"))

hosts = s:option(DynamicList, "hosts", translate("Target host addresses"), translate("Addresses for checking the availability"))
hosts.datatype = "string"

interval = s:option(Value, "interval", translate("Interval"), translate("How often to check Internet connection in seconds"))
interval.datatype = "uinteger"
interval.default = "30"

timeout = s:option(Value, "timeout", translate("Timeout"), translate("Timeout in seconds when trying to check Internet availability of host"))
timeout.datatype = "uinteger"
timeout.default = "5"

offline_treshold = s:option(Value, "offline_threshold", translate("Offline threshold"), translate("After how many times of checking, the connection is considered offline"))
offline_treshold.datatype = "uinteger"
offline_treshold.default = "1"

add_hostname_to_ssid = s:option(Flag, "add_hostname_to_ssid", translate("Append hostname to ssid"), translate("Append the router's hostname to the SSID when connectivity check fails"))
--add_hostname_to_ssid.enabled = "1"
--add_hostname_to_ssid.disabled = "0"
add_hostname_to_ssid.rmempty = false

use_curl = s:option(Flag, "use_curl", translate("Use curl"), translate("Use curl instead of wget for testing the connectivity. ATTENTION: You need to have curl installed before using this."))
use_curl.rmempty = false

curl_interface = s:option(Value, "curl_interface", translate("Used interface"), translate("Which interface should curl use. (Use ifconfig to find out)"))
curl_interface.datatype = "string"
curl_interface:depends("use_curl","1")
curl_interface.placeholder = "eth0"

return m,m1