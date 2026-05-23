#!/usr/bin/env bash
set -euo pipefail
echo "== resolv.conf =="
su -c "cat /etc/resolv.conf"
echo
echo "== net.dns props =="
su -c "getprop | grep -i net.dns"
