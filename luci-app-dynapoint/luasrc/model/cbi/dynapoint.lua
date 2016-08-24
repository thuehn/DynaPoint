local uci = require "luci.model.uci".cursor()
local a = require "luci.model.ipkg"
local DISP = require "luci.dispatcher"

local wlcursor = luci.model.uci.cursor_state()
local wireless = wlcursor:get_all("wireless")
local ifaces = {}

for k, v in pairs(wireless) do
  if v[".type"] == "wifi-iface" then
    table.insert(ifaces, v)
  end
end

m = Map("dynapoint")
m:chain("wireless")

s = m:section(NamedSection, "internet", "rule", translate("Configuration"), translate("Check for Internet connectivity via HTTP download"))

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
add_hostname_to_ssid.rmempty = false


if (a.installed("curl") == true) then
  use_curl = s:option(Flag, "use_curl", translate("Use curl"), translate("Use curl instead of wget for testing the connectivity."))
  use_curl.rmempty = false

  curl_interface = s:option(Value, "curl_interface", translate("Used interface"), translate("Which interface should curl use. (Use ifconfig to find out)"))
  curl_interface.datatype = "string"
  curl_interface:depends("use_curl","1")
  curl_interface.placeholder = "eth0"
else
  use_curl = s:option(Flag, "use_curl", translate("Use curl instead of wget"), translate("Curl is currently not installed.")
  .." Please install the package in the "
  ..[[<a href="]] .. DISP.build_url("admin", "system", "packages")
  .. "?display=available&query=curl"..[[">]]
  .. "Software Section" .. [[</a>]]
  .. "."
  )
  use_curl.rmempty = false
  use_curl.template = "dynapoint/cbi_checkbox"
end

m1 = Map("wireless", "DynaPoint", translate("Dynamic Access Point Validator and Creator"))

aps = m1:section(TypedSection, "wifi-iface", translate("Access Points"))
aps.addremove = false
aps.anonymous = true
aps.template  = "cbi/tblsection"

status = aps:option(DummyValue, "disabled", translate("Status"))
status.template = "dynapoint/cbi_color"

function status.cfgvalue(self,section)
  local val = m1:get(section, "disabled")
  if val == "1" then return translate("Disabled") end
  if (val == nil or val == "0") then return translate("Enabled") end
  return val
end

ssid = aps:option(DummyValue, "ssid", translate("SSID"))

action = aps:option(ListValue, "dynapoint_rule", translate("Activate if"))
action.widget="select"
action:value("internet",translate("Online"))
action:value("!internet",translate("Offline"))
action:value("",translate("Not used by DynaPoint"))
action.default = ""

return m1,m
