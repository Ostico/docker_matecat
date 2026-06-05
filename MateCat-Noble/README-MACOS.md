# Running MateCat-Noble on macOS

This stack runs on macOS (Intel and Apple Silicon) with Docker Desktop. The notes below cover the parts that differ from a stock Linux setup.

## 1. Prerequisites

- Docker Desktop for Mac (recent release, VirtioFS file sharing enabled).
- On Apple Silicon: enable **Use Rosetta for x86_64/amd64 emulation** in Docker Desktop settings (Settings → General). Several upstream images in this stack are amd64-only.
- `gh` and `git` for normal repo workflow.

## 2. One-time setup

### 2.1 Environment file

```sh
cd MateCat-Noble
cp .env.example .env
```

Edit `.env` and set, at minimum:

```sh
docker_uid=$(id -u)     # e.g. 501
docker_gid=$(id -g)     # e.g. 20
DOCKER_PLATFORM=linux/amd64
MATECAT_SOURCE_PATH=/absolute/path/to/your/MateCat checkout
MATECAT_CERTS_PATH=/absolute/path/to/cert/dir/letsencrypt
TEMP_VOLUME_PATH=/absolute/path/to/a/scratch/dir
```

`TEMP_VOLUME_PATH` is mounted at `/mnt/external_volume` in the MySQL and ProxySQL containers. Drop a `*-dump.sql` file here to seed the database (see §5).

### 2.2 Host name resolution

Apache inside the matecat container serves the vhosts `dev.matecat.com` and `0.ajax.dev.matecat.com` through `3.ajax.dev.matecat.com`. Add them to `/etc/hosts`:

```sh
echo "127.0.0.1  dev.matecat.com 0.ajax.dev.matecat.com 1.ajax.dev.matecat.com 2.ajax.dev.matecat.com 3.ajax.dev.matecat.com" | sudo tee -a /etc/hosts
sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder
```

Without these entries the browser returns `ERR_NAME_NOT_RESOLVED`.

### 2.3 Certificates

The matecat container expects a Let's Encrypt-style directory at `MATECAT_CERTS_PATH`. For local development a self-signed cert is fine; create one with `mkcert` or `openssl` and point `MATECAT_CERTS_PATH` at the directory containing `live/dev.matecat.com/{fullchain,privkey}.pem`.

## 3. Start the stack

```sh
cd MateCat-Noble
docker compose up -d
```

Open `https://dev.matecat.com/` (accept the self-signed warning the first time).

## 4. MySQL storage: named volumes (not bind mounts)

`mysql-master` and `mysql-slave` write to Docker-managed **named volumes** (`master-mysql-data`, `slave-mysql-data`), not to host folders. The reason:

- macOS bind mounts go through VirtioFS, which rewrites file ownership. mysqld runs as `mysql` inside the container but sees files owned by your host uid, which can corrupt the InnoDB system tablespace on restart.
- Named volumes live in the Docker Desktop VM (native Linux ext4). Permissions and `fsync` behave the same as on a real Linux host.

Side effects:

- You can no longer browse MySQL data files from Finder. Use `docker exec` for inspection and `mysqldump` for backup.
- `docker compose down` keeps the volumes; data survives restarts. `docker compose down -v` or `docker volume rm matecat-noble_master-mysql-data matecat-noble_slave-mysql-data` deletes the volumes and triggers a fresh bootstrap on next start.

## 5. Seeding the database from a dump

Drop a `*-dump.sql` file into `TEMP_VOLUME_PATH` (the directory you pointed at in `.env`). On the next fresh boot of `mysql-master` the entrypoint detects an empty datadir and runs:

```sh
mysql -e "CREATE DATABASE IF NOT EXISTS matecat CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql matecat < /mnt/external_volume/<first matching dump>.sql
```

The dump replicates to `mysql-slave` through the binlog. **The dump is only loaded when the `matecat` database does not exist** — normal restarts skip it.

### Producing a portable dump from another MySQL

`mysqldump` defaults are not replication-friendly. Either dump with the right flags:

```sh
mysqldump -uroot -p \
  --single-transaction --routines --triggers --events \
  --set-gtid-purged=OFF \
  --default-character-set=utf8 \
  matecat > matecat-dump.sql
```

Or strip the two offending lines from an existing dump before placing it in `TEMP_VOLUME_PATH`:

```sh
sed -i '' '/SET @@SESSION.SQL_LOG_BIN= 0;/d; /SET @@GLOBAL.GTID_PURGED=/d' matecat-dump.sql
```

Without these adjustments the slave ends up empty (binlog disabled during load) and/or the import aborts with `ERROR 1840: @@GLOBAL.GTID_PURGED can only be set when @@GLOBAL.GTID_EXECUTED is empty`.

## 6. Slave restart auto-recovery

`MySQL/run.sh` checks `Slave_IO_Running` / `Slave_SQL_Running` on every container start and, if either is not `Yes`, re-establishes replication against `mysql-master` automatically. No manual `RESET SLAVE` / `CHANGE MASTER` after a `docker restart matecat-mysql-slave`.

## 7. Apache restart auto-recovery

`MateCatApache/run.sh` removes `/var/run/apache2/apache2.pid` before `service apache2 restart`. On `docker restart matecat` the pid file from the previous container life survives in the writable layer; sysvinit would otherwise see it, conclude Apache is already running, and exit without starting anything. Symptoms: `Apache Started` in the log, no apache process, `curl` returns `000`.

## 8. XDebug

The matecat service injects `host.docker.internal` via `extra_hosts: ["host.docker.internal:host-gateway"]` and sets `XDEBUG_CONFIG=client_host=host.docker.internal`. Configure your IDE listener on port 9003 (XDebug 3 default). No `lo0` alias hack is required.
