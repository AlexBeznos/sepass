#! /usr/bin/env bash
echo '>>>>>>>>>>>>>>>>>>>>>>>>>> WAIT FOR DB <<<<<<<<<<<<<<<<<<<<<<<<<<'
set -e

host="$1"
shift
cmd="$@"

until PGPASSWORD='postgres' psql -h "$host" -U "postgres" -c '\l'; do
  >&2 echo ">>>>>>> Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo ">>>>>>>>> Postgres is up - executing command"
exec $cmd
