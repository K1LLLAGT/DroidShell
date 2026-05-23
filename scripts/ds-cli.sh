#!/data/data/com.termux/files/usr/bin/bash
case "$1" in init) ./ds-bootstrap.sh;; build) ./ds-build-pipeline.sh;; esac
