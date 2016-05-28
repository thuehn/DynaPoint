# dynapoint
Dynamic Access Point creation with LEDE (former OpenWrt)

Example of how to use it in /etc/config/wireless:

```
config wifi-iface
	option device 'radio0'
	option network 'lan2'
	option mode 'ap'
	option encryption 'none'
	option ssid 'freifunk'
	option dynapoint_internet '1'

config wifi-iface
	option device 'radio0'
	option network 'lan2'
	option mode 'ap'
	option encryption 'none'
	option ssid 'freifunk-maintenance'
	option dynapoint_internet '0'
	option disabled '1'
```