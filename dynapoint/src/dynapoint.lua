#!/usr/bin/lua

require "uci"
require "ubus"
require "uloop"
log = require "nixio"

log.openlog("DynaPoint" , "ndelay", "cons", "nowait");

function getConfType(conf,type)
  local curs=uci.cursor()
  local ifce={}
  curs:foreach(conf,type,function(s) ifce[s[".index"]]=s end)
  return ifce
end

local uci_cursor = uci.cursor()
uci_cursor:revert("wireless")

conn = ubus.connect()
if not conn then
  error("Failed to connect to ubusd")
end
conn:call("network", "reload", {})


local interval = uci_cursor:get("dynapoint", "internet", "interval")
local timeout = uci_cursor:get("dynapoint", "internet", "timeout")
local offline_threshold = tonumber(uci_cursor:get("dynapoint", "internet", "offline_threshold"))
local hosts = uci_cursor:get("dynapoint", "internet", "hosts")
local curl = tonumber(uci_cursor:get("dynapoint", "internet", "use_curl"))
if (curl == 1) then
  curl_interface = uci_cursor:get("dynapoint", "internet", "curl_interface")
end


local numhosts = #hosts
--print(numhosts)

function get_dynapoint(t)
  for pos,val in pairs(t) do
    if (type(val)=="table") then
      get_dynapoint(val);
    elseif (type(val)=="string") then
      if (pos == "dynapoint_rule") then
        if (val == "internet") then
          table_name_1=t[".name"]
          --print(table_name_1)
        elseif (val == "!internet") then
          table_name_0=t[".name"]
          --print(table_name_0)
        end
      end
    end
  end
end

function print_r ( t )
  local print_r_cache={}
  local function sub_print_r(t,indent)
    if (print_r_cache[tostring(t)]) then
      print(indent.."*"..tostring(t))
    else
      print_r_cache[tostring(t)]=true
      if (type(t)=="table") then
        for pos,val in pairs(t) do
          if (type(val)=="table") then
            print(indent.."["..pos.."] => "..tostring(t).." {")
            sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
            print(indent..string.rep(" ",string.len(pos)+6).."}")
          elseif (type(val)=="string") then
            print(indent.."["..pos..'] => "'..val..'"')
          else
            print(indent.."["..pos.."] => "..tostring(val))
          end
        end
      else
        print(indent..tostring(t))
      end
    end
  end
  if (type(t)=="table") then
    print(tostring(t).." {")
    sub_print_r(t,"  ")
    print("}")
  else
    sub_print_r(t,"  ")
  end
  print()
end

--print_r(getConfType("wireless", "wifi-iface"))

--print(table.getn(hosts))
--print(#hosts)

get_dynapoint(getConfType("wireless","wifi-iface"))

if (tonumber(uci_cursor:get("dynapoint", "internet", "add_hostname_to_ssid")) == 1 ) then
  localhostname = uci_cursor:get("system", "system", "hostname")
  ssid = uci_cursor:get("wireless", table_name_0, "ssid")
  ssid2 = ssid.."_"..localhostname
end



local online = true
if (tonumber(uci_cursor:get("wireless", table_name_1, "disabled")) == 1) then
  online = false
end

local timer
local offline_counter = 0
uloop.init()

function do_internet_check(host)
  if (curl == 1 ) then
    if (curl_interface) then
      result = os.execute("curl -s -m "..timeout.." --max-redirs 0 --interface "..curl_interface.." --head "..host.." > /dev/null")
    else
      result = os.execute("curl -s -m "..timeout.." --max-redirs 0 --head "..host.." > /dev/null")
    end
  else
    result = os.execute("wget -q --timeout="..timeout.." --spider "..host)
  end
  if (result == 0) then
    return true
  else
    return false
  end
end

function change_wireless_config(switch_to_offline)
  if (switch_to_offline == 1) then
    log.syslog("info","Switched to OFFLINE")
    if (localhostname) then
      uci_cursor:set("wireless", table_name_0, "ssid", ssid2)
      log.syslog("info","Bring up new AP "..ssid2)
    else
      log.syslog("info","Bring up new AP "..ssid)
    end
    uci_cursor:set("wireless", table_name_0, "disabled", "0")
    uci_cursor:set("wireless", table_name_1, "disabled", "1")
  else    
    uci_cursor:set("wireless", table_name_0 , "disabled", "1")
    uci_cursor:set("wireless", table_name_1 , "disabled", "0")
    if (localhostname) then
      uci_cursor:set("wireless", table_name_0, "ssid", ssid)
    end
    log.syslog("info","Switched to ONLINE")
    log.syslog("info","Bring up new AP "..uci_cursor:get("wireless", table_name_1 , "ssid"))
  end

  uci_cursor:save("wireless")
  conn:call("network", "reload", {})
end


local hostindex = 1

function check_internet_connection()
  print("checking "..hosts[hostindex].."...")
  if (do_internet_check(hosts[hostindex]) == true) then
    -- online
    print("...seems to be online")
    offline_counter = 0
    if (online == false) then
      print("changed state to online")
      online = true
      change_wireless_config(0)
    end
  else
    --offline
    print("...seems to be offline")
    hostindex = hostindex + 1
    if (hostindex > numhosts) then
      hostindex = 1
      -- and activate offline-mode
      print("all hosts offline")
      if (online == true) then
        offline_counter = offline_counter + 1
        if (offline_counter == offline_threshold) then
          print("changed state to offline")
          online = false
          change_wireless_config(1)
        end
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
