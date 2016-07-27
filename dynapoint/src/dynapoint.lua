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

local uci_cursor = uci.cursor()
local host = uci_cursor:get("dynapoint", "internet", "host")
local test = uci_cursor:get("dynapoint", "internet", "test")
print("test?")
print(test)
local localhostname = uci_cursor:get("system", "system", "hostname")
local host2 = "http://www.google.com"
local interval = uci_cursor:get("dynapoint", "internet", "interval")
local timeout = uci_cursor:get("dynapoint", "internet", "timeout")
local offline_delay = tonumber(uci_cursor:get("dynapoint", "internet", "offline_delay"))

function get_dynapoint(t)
  for pos,val in pairs(t) do
    if (type(val)=="table") then
      get_dynapoint(val);
    elseif (type(val)=="string") then
      if (pos == "dynapoint") then
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

local online = true
local timer
local offline_counter = 0

function do_internet_check(host)
  local result = os.execute("wget -q --timeout="..timeout.." --spider "..host)
  if (result == 0) then
    return true
  else
    return false
  end
end

function check_internet_connection()
  print("checking connection")
  if (do_internet_check(host) == true) then
    -- online
    offline_counter = 0
    if (online == false) then
      print("changed to online")
      online = true
      uci_cursor = uci.cursor()
      uci_cursor:set("wireless", table_name_0 , "disabled", "1")
      uci_cursor:set("wireless", table_name_1 , "disabled", "0")
      uci_cursor:commit("wireless")
      conn:call("network", "reload", {})
    end
  else
    --offline
    if (do_internet_check(host2) == false) then
      offline_counter = offline_counter + 1
      if (offline_counter == offline_delay) then
        print("changed to offline")
        online = false
        uci_cursor = uci.cursor()
        uci_cursor:set("wireless", table_name_0, "disabled", "0")
        uci_cursor:set("wireless", table_name_1, "disabled", "1")
        uci_cursor:commit("wireless")
        conn:call("network", "reload", {})
      end
    end
  end
  timer:set(interval * 1000)
end

timer = uloop.timer(check_internet_connection)
timer:set(interval * 1000)


--local my_method = {
--  dynapoint = {
--    online = {
--      function(req, msg)
--        conn:reply(req, {status="online",interface=msg.interface});
--        print("Call to function 'online'")
--        print("Interface=" .. msg.interface)
--
--        uci_cursor = uci.cursor()
--        uci_cursor:set("wireless", table_name_0 , "disabled", "1")
--        uci_cursor:set("wireless", table_name_1 , "disabled", "0")
--        conn:call("network", "reload", {})
--
--      end, {interface = ubus.STRING }
--    },
--    offline = {
--      function(req, msg)
--        conn:reply(req, {status="offline",interface=msg.interface});
--        print("Call to function 'offline'")
--        print("Interface=" .. msg.interface)
--        uci_cursor = uci.cursor()
--        uci_cursor:set("wireless", table_name_0, "disabled", "0")
--        uci_cursor:set("wireless", table_name_1, "disabled", "1")
--        conn:call("network", "reload", {})
--      end, {interface = ubus.STRING }
--    }
--  }
--}

--conn:add(my_method)

uloop.run()
