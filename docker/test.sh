#!/bin/ash

timeout 10 /bin/ash /entrypoint.sh
exit_status=$?

if [ $exit_status -ne 0 ]; then
  echo "Failed self test"
  exit $exit_status
fi
mariadb -e "SHUTDOWN;" && sleep 2
