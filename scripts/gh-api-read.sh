#!/bin/bash
# Read-only gh api wrapper. Rejects any flags that would make a write request.
# For write operations, use `gh api` directly so the user can approve.

for arg in "$@"; do
  case "$arg" in
    --method|-X|--method=*|-f|-F|--field|--field=*|--raw-field|--raw-field=*|--input|--input=*)
      echo "ERROR: Write operation detected ($arg). Use 'gh api' directly for write operations so the user can approve." >&2
      exit 1
      ;;
    --)
      break
      ;;
  esac
done

exec gh api --method GET "$@"
