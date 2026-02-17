#!/bin/sh

: "${MYSQL_SETUP_ENABLED:="0"}"                  # set to 1 to enable
: "${MYSQL_HOST:=""}"                            # set Host of MySQL/MariaDB Server
: "${MYSQL_PORT:="3306"}"                        # set Port of MySQL/MariaDB Server
: "${MYSQL_ROOT_PASSWORD:=""}"                   # set MySQL Root Password
: "${MYSQL_DATABASE:=""}"                        # set Databasename for User
: "${MYSQL_USER:=""}"                            # set Username
: "${MYSQL_PASSWORD:=""}"                        # set Password for User
: "${MYSQL_EXPORTER_USER:="exporter"}"           # set Exporter-Username, default: exporter
: "${MYSQL_EXPORTER_PASSWORD:=""}"               # set Password for Exporter-Username
: "${MYSQL_EXPORTER_MAXUSERCONNECTIONS:="0"}"    # max connection, set to 0 for unlimited, recommended: 3

host='%'  # set '%' to allow from all host
options='--skip-ssl-verify-server-cert'

if [ "$MYSQL_SETUP_ENABLED" -eq "1" -a -n "$MYSQL_HOST" -a -n "$MYSQL_PORT" -a -n "$MYSQL_ROOT_PASSWORD" ]; then
    echo ">> MySQL Setup preparation on Host ${MYSQL_HOST} and Port ${MYSQL_PORT} ..."

    echo ">> MySQL waiting for Server ..."
    until mariadb-admin ping -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u root --password="${MYSQL_ROOT_PASSWORD}" ${options} --skip-verbose --silent >/dev/null 2>&1; do
        sleep 2
    done
    echo ">> MySQL Server ready ..."

    # User
    if [ -n "$MYSQL_USER" -a -n "$MYSQL_PASSWORD" -a -n "$MYSQL_DATABASE" ]; then
        echo ">> MySQL Database (${MYSQL_DATABASE}) and User (${MYSQL_USER}) ..."
        mariadb -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u root --password="${MYSQL_ROOT_PASSWORD}" ${options} -sNe \
        "SELECT user FROM mysql.user WHERE user = '${MYSQL_USER}' GROUP BY user;" \
        | grep -q ${MYSQL_USER} \
        || mariadb -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u root --password="${MYSQL_ROOT_PASSWORD}" ${options} -sN <<EOSQL
        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'${host}' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'${host}';
        FLUSH PRIVILEGES;
EOSQL
    else
        echo ">> MySQL Database (${MYSQL_DATABASE}) and User (${MYSQL_USER}) skipped."
    fi

    # Exporter
    if [ -n "$MYSQL_EXPORTER_USER" -a -n "$MYSQL_EXPORTER_PASSWORD" -a -n "$MYSQL_EXPORTER_MAXUSERCONNECTIONS" ]; then
        echo ">> MySQL Exporter-User (${MYSQL_EXPORTER_USER}) ..."
        mariadb -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u root --password="${MYSQL_ROOT_PASSWORD}" ${options} -sNe \
        "SELECT user FROM mysql.user WHERE user = '${MYSQL_EXPORTER_USER}' GROUP BY user;" \
        | grep -q ${MYSQL_EXPORTER_USER} \
        || mariadb -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u root --password="${MYSQL_ROOT_PASSWORD}" ${options} -sN <<EOSQL
        CREATE USER IF NOT EXISTS '${MYSQL_EXPORTER_USER}'@'${host}' IDENTIFIED BY '${MYSQL_EXPORTER_PASSWORD}' WITH MAX_USER_CONNECTIONS ${MYSQL_EXPORTER_MAXUSERCONNECTIONS};
        GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO '${MYSQL_EXPORTER_USER}'@'${host}';
        FLUSH PRIVILEGES;
EOSQL
    else
        echo ">> MySQL Exporter-User (${MYSQL_EXPORTER_USER}) skipped."
    fi

    # checks
    echo ">> MySQL checks:"
    mariadb -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u root --password="${MYSQL_ROOT_PASSWORD}" ${options} -e 'SELECT user, host, max_user_connections FROM mysql.user;'
    mariadb -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u root --password="${MYSQL_ROOT_PASSWORD}" ${options} -e 'SELECT host, user, db FROM mysql.db;'
fi