# Collection of monitoring tools
## [GKrellM](http://gkrellm.srcbox.net/)
- local or remote monitoring. gkrellm can run in client mode, collect data from gkrellmd server
- plugin capable (supports custom monitors)
- multiple monitors managed by a single process to reduce system load
- reads data from `/proc`

## [Sysstat/SAR](http://sebastien.godard.pagesperso-orange.fr/)
- utility/command line tool to monitor wide variety of low-level OS/hardware metrics (e.g. all the common metrics, kernel interal tables utilization, interrupt statistics, fan speed, device temperature)
- seems to make more sense for local monitoring not remote

## [KSysGuard](https://userbase.kde.org/KSysGuard)
## [GNOME System Monitor](https://help.gnome.org/users/gnome-system-monitor/3.26/)

## [Cacti](https://cacti.net/)
- main appeal is RRDtool graphing solution
- support for per user, per group permissions at a per graph, per device etc level. permission model based on RBAC model.

## [Nagios](https://www.nagios.com/products/nagios-core/)
- monitor private attributes: CPU load, memory usage, disk usage, logged in users, running processes, ping rates etc.
- public attributes (HTTP, FTP, SSH, SMTP) can be monitored easily
- Nagios monitoring host can monitor a remote linux/unix host using NRPE [plugin](https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/4/en/plugins.html), which communicates over an SSL channel.
	- plugins provide a monitoring abstraction btwn Nagios Core daemon and monitored hosts; Nagios doesn't know what you're monitoring
	- could be a cool demo--just sandbox the NRPE plugin itself. Nagios could be a long-running application on separate host, while monitoring plugins could be spun-up quickly in containers. Nagios tracks changes in resources for the plugin. 
	- Nagios provides a [plugin API](https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/4/en/pluginapi.html), so custom plugins can be installed for whatever application you're monitoring. 

