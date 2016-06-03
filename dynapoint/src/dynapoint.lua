#!/usr/bin/lua

require "uci"
require "ubus"
require "uloop"


function getConfType(conf,type)
  local curs=uci.cursor()
  local ifce={}
  curs:foreach(conf,type,function(s) ifce[s[".index"]]=s end)
  return ifce
end

local pingcheck_default = getConfType("pingcheck","default")[0][".name"]


local uci_cursor = uci.cursor()

local icmp_host = uci_cursor:get("dynapoint", "internet", "icmp_host")
uci_cursor:set("pingcheck", pingcheck_default , "host", icmp_host)

local interval = uci_cursor:get("dynapoint", "internet", "interval")
uci_cursor:set("pingcheck", pingcheck_default , "interval", interval)

local timeout = uci_cursor:get("dynapoint", "internet", "timeout")
uci_cursor:set("pingcheck", pingcheck_default , "timeout", timeout)

uci_cursor:commit("pingcheck")
os.execute("sh /etc/init.d/pingcheck restart")


function get_dynapoint(t)
  for pos,val in pairs(t) do
    if (type(val)=="table") then
      get_dynapoint(val);
    elseif (type(val)=="string") then
      if (pos == "dynapoint_internet") then
        if (val == "1") then
          table_name_1=t[".name"]
          print(table_name_1)
        elseif (val == "0") then
          table_name_0=t[".name"]
          print(table_name_0)
        end
      end
    end
  end
end


get_dynapoint(getConfType("wireless","wifi-iface"))

uloop.init()

conn = ubus.connect()
if not conn then
  error("Failed to connect to ubusd")
end

local my_method = {
  dynapoint = {
    online = {
      function(req, msg)
        conn:reply(req, {status="online",interface=msg.interface});
        print("Call to function 'online'")
        print("Interface=" .. msg.interface)

        uci_cursor = uci.cursor()
        uci_cursor:delete("wireless", table_name_1 , "disabled")
        uci_cursor:set("wireless", table_name_0 , "disabled", "1")
        uci_cursor:commit("wireless")
        conn:call("network", "reload", {})

      end, {interface = ubus.STRING }
    },
    offline = {
      function(req, msg)
        conn:reply(req, {status="offline",interface=msg.interface});
        print("Call to function 'offline'")
        print("Interface=" .. msg.interface)
        uci_cursor = uci.cursor()
        uci_cursor:delete("wireless", table_name_0, "disabled")
        uci_cursor:set("wireless", table_name_1, "disabled", "1")
        uci_cursor:commit("wireless")
        conn:call("network", "reload", {})
      end, {interface = ubus.STRING }
    }
  }
}

conn:add(my_method)

uloop.run()
