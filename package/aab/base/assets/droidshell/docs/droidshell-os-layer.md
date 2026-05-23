# DroidShell OS Layer

## API

- Transport: JSON over file queue (default), Binder (stub), HTTP (stub)
- Request:
  - version, id, command, args
- Response:
  - version, id, status, data, error

Core commands (v1):

- env.info
- fs.list
- backup.app
- apk.disassemble
- apk.rebuild
- sync.push
- sync.pull
