# DroidShell OS Transports

## Default: File Queue

Root:
  ~/droidshell/os/
    inbox/request.json
    outbox/response.json

CLI:
  - writes JSON request to inbox/request.json
  - waits for outbox/response.json
  - prints response

Service:
  - polls inbox/request.json
  - processes request
  - writes outbox/response.json

## Binder / HTTP

Binder and HTTP transports are stubbed for future expansion.
