# PHP - Examples: PHP-FPM & NGINX & MySQL (using DHI) for K8s/Kubernetes

(see also folder: `fpm-nginx-dhi`)  

## Steps:
1. ```kubectl apply -f namespace.yaml```
2. Registry Login (needed for DHI), see below.
3. Preparation:
    * Change `ConfigMap` and `Secret` (Passwords) in `wsc-db.yaml` and `wsc-db.yaml`.
    * Set Domain/Host(s) in `Ingress` in `wsc-db.yaml` and set ssl-cert.
    * Set `storageClassName` in `volumes.yaml`.
    * check rest of yaml`s/configs ...
4. ```kubectl apply -f volumes.yaml```
5. ```kubectl apply -f wsc-db.yaml```
    * create database and user and set permission:
      ```sh
      # Database
      kubectl -n wsc exec -it deployment/wsc-db -c mysql -- sh -c 'mysql -uroot -e "CREATE DATABASE ${MYSQL_DATABASE};"'
      # User with Password and Permission for Database
      kubectl -n wsc exec -it deployment/wsc-db -c mysql -- sh -c 'mysql -uroot -e "CREATE USER \"${MYSQL_USER}\"@\"%\" IDENTIFIED BY \"${MYSQL_PASSWORD}\"; GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO \"${MYSQL_USER}\"@\"%\";"'
      ```
    * create exporter user with password and set permission:
      ```sh
      kubectl -n wsc exec -it deployment/wsc-db -c mysql -- sh -c 'mysql -uroot -e "CREATE USER \"${MYSQL_EXPORTER_USER}\"@\"%\" IDENTIFIED BY \"${MYSQL_EXPORTER_PASSWORD}\"; GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO \"${MYSQL_EXPORTER_USER}\"@\"%\";"'
      ```
    * check:
      ```sh
      kubectl -n wsc exec -it deployment/wsc-db -c mysql -- sh -c 'mysql -h localhost -uroot -e "SELECT user, host, max_user_connections FROM mysql.user;"'
      kubectl -n wsc exec -it deployment/wsc-db -c mysql -- sh -c 'mysql -h localhost -uroot -e "SELECT host, user, db FROM mysql.db;"'
      ```
    * Now you can edit `wsc-db.yaml` and use `MYSQL_EXPORTER_USER` and `MYSQLD_EXPORTER_PASSWORD` for exporter and optional use other user instead root for healtcheck. Then redeploy.
6. ```kubectl apply -f wsc-web.yaml```
7. check:
   ```sh
   kubectl -n wsc get secrets,configmaps,ingresses,services,pods,deployments,pvc,pv
   ```
8. [Download WSC](https://www.woltlab.com/en/woltlab-suite-download/) and unzip archive and copy wsc files form upload-folder to html-folder in wsc-web deployment: 
   ```sh
   kubectl -n wsc cp ./upload/. $(kubectl -n wsc get pod -l app.kubernetes.io/name=wsc-web -o jsonpath="{.items[0].metadata.name}"):/var/www/html/ -c helper
   ```
9. Call your domain and file test.php, example: `http://example.com/test.php`
10. Now follows the installation setup of the WSC.  
   Manual/Help: https://manual.woltlab.com/en/installation/  
   (Notice: Database Host is `wsc-db`!)
11. Installation complete.
12. Optional: example Backup-Script `kubectl apply -f wsc-backup-cronjob.yaml` (Please Test Backup and Recovery!)

## Registry Login

Login to docker.io and dhi.io Registries!

```sh
# Steps:

# 1. User and Password
REGISTRY_USER_NAME="<username>"      # Docker Hub Username
REGISTRY_USER_PASSWORD="<password>"  # Password or Token

# 2. Registry: Docker Hub
REGISTRY_NAME="index.docker.io/v1/"
K8S_REGCRED_NAME="regcred-dockerhub"

# 3. Login command
kubectl create secret docker-registry ${K8S_REGCRED_NAME} \
--docker-server="${REGISTRY_NAME}" \
--docker-username="${REGISTRY_USER_NAME}" \
--docker-password="${REGISTRY_USER_PASSWORD}" \
--save-config --dry-run=client -o yaml | \
kubectl --namespace=wsc apply -f -

# 4. Registry: DHI
REGISTRY_NAME="dhi.io"
K8S_REGCRED_NAME="regcred-dhi"

# 5. repeat "3. Login command" again
```