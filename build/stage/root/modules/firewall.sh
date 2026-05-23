#!/usr/bin/env bash
set -euo pipefail
echo "== iptables =="
su -c "iptables -L -n -v"
echo
echo "== ip6tables =="
su -c "ip6tables -L -n -v"
