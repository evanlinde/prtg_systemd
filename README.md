# prtg_systemd

Monitor one or more systemd units with PRTG.

Set an OK status for units that are active or an Error status for units that are not active.

The units monitored can be services, any other [unit type](https://www.freedesktop.org/software/systemd/man/systemd.unit.html), or any combination of unit types.


## Requirements

- Linux
- systemd
- bash


## How to use

The script outputs XML suitable for PRTG's advanced sensor types. It can be used with the SSH Script Advanced sensor or the HTTP Push Data Advanced sensor (with the help of the [`prtg_push_advanced`](https://github.com/evanlinde/prtg_push)).

The units you want to monitor can be specified staticly inside the script, for example:
```bash
units=(sshd httpd firewalld)
```

Or they can be passed to the script as command line arguments. The combined list of unit names in the script and unit names passed via command line argument will be monitored.

Unit types other than services must have their type suffix specified. You may also be able to specify mount units by their mount point path instead of their unit name.


## Setup as SSH Sensor

Copy `systemd_units.sh` into `/var/prtg/scriptsxml` on the system you want to monitor. Make sure that your PRTG user has read and execute permissions to the script.

Edit the script and add any unit names that you want into the `units=()` list.

Add an "SSH Script Advanced" sensor to your target system in PRTG and select the `systemd_units.sh` script.

List any unit names you want to provide via command line argument in the Parameters setting of the sensor.


## Setup as HTTP Push Sensor

Copy `systemd_units.sh` and [`prtg_push_advanced`](https://github.com/evanlinde/prtg_push) to the system you want to monitor. Make sure that the scripts are readable and executable by the account that will run them.

Edit `systemd_units.sh` and add any unit names that you want into the `units=()` list.

Add an "HTTP Push Data Advanced" sensor to your target system in PRTG. Note the automatically generated token after you create the sensor, or set your own token.

Test pushing data with a command like this:
```bash
systemd_units.sh ${optional_list_of_units} | prtg_push_advanced -a "${probe_address}" -t "${token}"
```

Schedule your push command to run on a regular basis (e.g. with cron or a systemd timer).

