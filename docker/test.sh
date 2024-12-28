#!/bin/ash

timeout 10 /bin/ash /entrypoint.sh
exit_status=$?

if [ $exit_status -ne 0 ]; then
  echo "Failed to start MySQL"
  exit $exit_status
fi
