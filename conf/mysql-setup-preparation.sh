#!/bin/sh

: "${MYSQL_SETUP_ENABLED:="0"}"                  # set to 1 to enable
: "${MYSQL_HOST:=""}"                            # set Host of MySQL/MariaDB Server
: "${MYSQL_PORT:="3306"}"                        # set Port of MySQL/MariaDB Server
: "${MYSQL_ROOT_PASSWORD:=""}"                   # set MySQL/MariaDB Root Password
: "${MYSQL_DATABASE:=""}"                        # set Databasename for User
: "${MYSQL_USER:=""}"                            # set Username
: "${MYSQL_PASSWORD:=""}"                        # set Password for User
: "${MYSQL_EXPORTER_USER:="exporter"}"           # set Exporter-Username, default: exporter
: "${MYSQL_EXPORTER_PASSWORD:=""}"               # set Password for Exporter-Username
: "${MYSQL_EXPORTER_MAXUSERCONNECTIONS:="0"}"    # max connection, set to 0 for unlimited, recommended: 3

: "${MARIADB_SETUP_ENABLED:="$MYSQL_SETUP_ENABLED"}"
: "${MARIADB_HOST:="$MYSQL_HOST"}"
: "${MARIADB_PORT:="$MYSQL_PORT"}"
: "${MARIADB_ROOT_PASSWORD:="$MYSQL_ROOT_PASSWORD"}"
: "${MARIADB_DATABASE:="$MYSQL_DATABASE"}"
: "${MARIADB_USER:="$MYSQL_USER"}"
: "${MARIADB_PASSWORD:="$MYSQL_PASSWORD"}"
: "${MARIADB_EXPORTER_USER:="$MYSQL_EXPORTER_USER"}"
: "${MARIADB_EXPORTER_PASSWORD:="$MYSQL_EXPORTER_PASSWORD"}"
: "${MARIADB_EXPORTER_MAXUSERCONNECTIONS:="$MYSQL_EXPORTER_MAXUSERCONNECTIONS"}"

host='%'  # set '%' to allow from all host
options='--skip-ssl-verify-server-cert'

if [ "$MARIADB_SETUP_ENABLED" -eq "1" -a -n "$MARIADB_HOST" -a -n "$MARIADB_PORT" -a -n "$MARIADB_ROOT_PASSWORD" ]; then
    echo ">> MySQL Setup preparation on Host ${MARIADB_HOST} and Port ${MARIADB_PORT} ..."

    echo ">> MySQL waiting for Server ..."
    until mariadb-admin ping -h ${MARIADB_HOST} -P ${MARIADB_PORT} -u root --password="${MARIADB_ROOT_PASSWORD}" ${options} --skip-verbose --silent >/dev/null 2>&1; do
        sleep 2
    done
    echo ">> MySQL Server ready ..."

    # User
    if [ -n "$MARIADB_USER" -a -n "$MARIADB_PASSWORD" -a -n "$MARIADB_DATABASE" ]; then
        echo ">> MySQL Database (${MARIADB_DATABASE}) and User (${MARIADB_USER}) ..."
        mariadb -h ${MARIADB_HOST} -P ${MARIADB_PORT} -u root --password="${MARIADB_ROOT_PASSWORD}" ${options} -sNe \
        "SELECT user FROM mysql.user WHERE user = '${MARIADB_USER}' GROUP BY user;" \
        | grep -q ${MARIADB_USER} \
        || mariadb -h ${MARIADB_HOST} -P ${MARIADB_PORT} -u root --password="${MARIADB_ROOT_PASSWORD}" ${options} -sN <<EOSQL
        CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE};
        CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'${host}' IDENTIFIED BY '${MARIADB_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'${host}';
        FLUSH PRIVILEGES;
EOSQL
    else
        echo ">> MySQL Database (${MARIADB_DATABASE}) and User (${MARIADB_USER}) skipped."
    fi

    # Exporter
    if [ -n "$MARIADB_EXPORTER_USER" -a -n "$MARIADB_EXPORTER_PASSWORD" -a -n "$MARIADB_EXPORTER_MAXUSERCONNECTIONS" ]; then
        echo ">> MySQL Exporter-User (${MARIADB_EXPORTER_USER}) ..."
        mariadb -h ${MARIADB_HOST} -P ${MARIADB_PORT} -u root --password="${MARIADB_ROOT_PASSWORD}" ${options} -sNe \
        "SELECT user FROM mysql.user WHERE user = '${MARIADB_EXPORTER_USER}' GROUP BY user;" \
        | grep -q ${MARIADB_EXPORTER_USER} \
        || mariadb -h ${MARIADB_HOST} -P ${MARIADB_PORT} -u root --password="${MARIADB_ROOT_PASSWORD}" ${options} -sN <<EOSQL
        CREATE USER IF NOT EXISTS '${MARIADB_EXPORTER_USER}'@'${host}' IDENTIFIED BY '${MARIADB_EXPORTER_PASSWORD}' WITH MAX_USER_CONNECTIONS ${MARIADB_EXPORTER_MAXUSERCONNECTIONS};
        GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO '${MARIADB_EXPORTER_USER}'@'${host}';
        FLUSH PRIVILEGES;
EOSQL
    else
        echo ">> MySQL Exporter-User (${MARIADB_EXPORTER_USER}) skipped."
    fi

    # checks
    echo ">> MySQL checks:"
    mariadb -h ${MARIADB_HOST} -P ${MARIADB_PORT} -u root --password="${MARIADB_ROOT_PASSWORD}" ${options} -e 'SELECT user, host, max_user_connections FROM mysql.user;'
    mariadb -h ${MARIADB_HOST} -P ${MARIADB_PORT} -u root --password="${MARIADB_ROOT_PASSWORD}" ${options} -e 'SELECT host, user, db FROM mysql.db;'
fi