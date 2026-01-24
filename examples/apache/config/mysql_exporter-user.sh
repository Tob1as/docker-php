#!/bin/sh
set -e

# SOURCE: https://github.com/Tob1as/docker-kubernetes-collection/blob/master/examples_docker-compose/config_mariadb/20_exporter-user.sh

: "${EXPORTER_USER:="exporter"}"
: "${EXPORTER_PASSWORD:="Exp0rt3r!"}"
: "${EXPORTER_MAXUSERCONNECTIONS:="3"}"
host='%' # set '%' to allow from all host

mariadb -h localhost -u root --password="${MARIADB_ROOT_PASSWORD}" -sNe \
"SELECT user FROM mysql.user WHERE user = '${EXPORTER_USER}' GROUP BY user;" \
| grep -q ${EXPORTER_USER}} \
|| mariadb -h localhost -u root --password="${MARIADB_ROOT_PASSWORD}" -sN <<EOSQL
    CREATE USER '${EXPORTER_USER}'@'${host}' IDENTIFIED BY '${EXPORTER_PASSWORD}' WITH MAX_USER_CONNECTIONS ${EXPORTER_MAXUSERCONNECTIONS};
    GRANT PROCESS, REPLICATION CLIENT, SELECT, SLAVE MONITOR ON *.* TO '${EXPORTER_USER}'@'${host}';
    GRANT SELECT ON performance_schema.* TO '${EXPORTER_USER}'@'${host}';
    FLUSH PRIVILEGES;
EOSQL

mariadb -h localhost -u root --password=${MARIADB_ROOT_PASSWORD} -e "SELECT user, host, max_user_connections FROM mysql.user;"
