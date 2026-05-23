# DroidShell OS CLI

Usage examples:

  droidshell-os env.info
  droidshell-os fs.list --path /sdcard
  droidshell-os backup.app --package com.example.app --mode both

The CLI:
- builds a JSON request
- writes it to ~/droidshell/os/inbox/request.json
- waits for ~/droidshell/os/outbox/response.json
- prints the JSON response
