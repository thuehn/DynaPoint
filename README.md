```
(                         (                         
 )\ )                      )\ )                   )  
(()/(   (               ) (()/(     (          ( /(  
 /(_))  )\ )   (     ( /(  /(_)) (  )\   (     )\()) 
(_))_  (()/(   )\ )  )(_))(_))   )\((_)  )\ ) (_))/  
 |   \  )(_)) _(_/( ((_)_ | _ \ ((_)(_) _(_/( | |_   
 | |) || || || ' \))/ _` ||  _// _ \| || ' \))|  _|  
 |___/  \_, ||_||_| \__,_||_|  \___/|_||_||_|  \__|  
        |__/                                         
```

Dynamic Access Point creation with LEDE Linux [www.lede-project.org]

### What is DynaPoint about?

In today's Freifunk networks it is quite common to have multiple access points connected to the actual Freifunk router (by Ethernet) in order to provide a dedicated wireless access network for all kinds of clients in addition to the Freifunk mesh network. Such access point setups are quite static once configured in LEDE and are prone to the following challenges in practice: The wireless access network is announced as soon as the ap interface is up and running, regardless of e.g. its state of internet connectivity. To inform a non-technical user of the circumstance that the router is up & running but no internet connectivity is available yet, different browser/dns based redirect approaches to inform about the non-internet-connectivity by a web site have been tested over time with little success in terms of robustness and usability. 
The goal of DynaPoint is that the configuration of an LEDE access interface via UCI/Luci is extended in such a way, that the wireless interface bring up via UBUS depends on a set of network conditions - so does the ability for the user to connect to it with its client device and his expectations.

An example scenario would look like this:

    1. as soon as the Freifunk ap is up and running bring up the access ssid: "maintainance-mode"
    2. based on the pingcheck package in LEDE, we try to reach a reasonable set of host on the internet via ICMP
    3. the dns service and its proper relosution is check 
    4. in case of all checks been working we create the access point network with ssid "freifunk.net" and stop announcing the ssid: "freifunk-maintainance-mode"
    5. cyclic test the conditions of internet accessibility in a regular manner and in case the reachability changes, switch off the access point network with ssid "freifunk.net" and switch on the ssid: "freifunk-maintenance-mode"

With this kind of dynamic access ssid creation, the expectations about the connectivity to a certain ssid are glued to the actual ssid itself, rather than todays approach to create a single accesspoint ssid where current network connectivity can only be tested in the second step after having connected to it. 

### How to install DynaPoint ?

1. Add `src-git dynapoint https://github.com/thuehn/dynapoint.git` to your feeds.conf
2. Run `./scripts/feeds update dynapoint`
3. Run `./scripts/feeds install dynapoint`
4. Run `make menuconfig` and select dynapoint under network / wireless
5. in case you use Luci as web interface, you can add dynapoint integration by adding luci-app-dynapoint in Luci apps section
6. Run `make package/feeds/dynapoint/dynapoint/install`

### How to use Dynapoint?
Example of how to use it in /etc/config/wireless:

```
config wifi-iface
	option device 'radio0'
	option network 'lan2'
	option mode 'ap'
	option encryption 'none'
	option ssid 'access.freifunk.net'
	option dynapoint '1'

config wifi-iface
	option device 'radio0'
	option network 'lan2'
	option mode 'ap'
	option encryption 'none'
	option ssid 'freifunk_maintenance-mode'
	option dynapoint '0'
```
