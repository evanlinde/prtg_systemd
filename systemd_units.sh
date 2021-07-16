#!/bin/bash
#
# PRTG Advanced Sensor script for systemd units
#
# Monitor whether systemd services and other systemd units are active.
# Each unit to be monitored will be a channel under the sensor. 
# Unit types other than "service" must have a type suffix specified;
# mount points (without a suffix) may also work to identify mount units.
#
# Requires: bash, systemctl
#

# Static list of unit names, for example: units=(sshd httpd firewalld)
units=()

# Expand the units list with unit names received on the command line
units+=("${@}")

exit_error(){
    printf "<prtg><error>1</error><text>%s</text></prtg>\n" "$1"
    exit 1
}

# Make sure we have all dependencies and at least one unit
(which systemctl) > /dev/null 2>&1 || exit_error "Cannot find systemctl."
[[ ${#units[@]} -gt 0 ]] || exit_error "No systemd units specified."

# Define XML format string for unit status
read -r -d '' UNIT_XML_FMT << 'EOF_UNIT_XML'
<result>
  <channel>%s: %s</channel>
  <value>%d</value>
  <valuelookup>prtg.standardlookups.activeinactive.stateactiveok</valuelookup>
</result>
EOF_UNIT_XML

# Make readings and print the XML-formatted results
echo "<prtg>"
for u in "${units[@]}"; do
    utype="${u##*.}"
    [[ "${u:0:1}" == "/" ]] && utype="mount"
    [[ "${u}" == "${utype}" ]] && utype="service"
    systemctl --quiet is-active "${u}" && v=1 || v=2
    printf "${UNIT_XML_FMT}\n" "${utype^}" "${u%.${utype}}" "${v}"
done
echo "</prtg>"

exit 0
