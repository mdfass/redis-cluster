#!/bin/sh
IP="${2:-$IP}"

if [ -z "$IP" ]; then
    IP=$(hostname -I)
fi

BIND_ADDRESS=0.0.0.0
if [ -z "$INITIAL_PORT" ]; then # set Default port to 7000
  INITIAL_PORT=7000
fi

if [ -z "$MASTERS" ]; then # Default to 3 masters
  MASTERS=3
fi

if [ -z "$SLAVES_PER_MASTER" ]; then # Default to 1 slave for each master
  SLAVES_PER_MASTER=1
fi

MAX_PORT=$(($INITIAL_PORT + $MASTERS * ( $SLAVES_PER_MASTER  + 1 ) - 1))
echo "INITIAL_PORT: $INITIAL_PORT"
echo "MAX_PORT: $MAX_PORT"

# remove any previous configurations
rm -rf /redis-data/*

for port in $(seq $INITIAL_PORT $MAX_PORT); do
  mkdir /redis-data/${port}

  # create the redis.conf file for this port
  PORT=${port} envsubst < /redis-config/redis-cluster.tmpl > /redis-data/${port}/redis.conf
  nodes="$nodes $IP:$port"

  # navigate to the redis data directory
  cd /redis-data/${port}
  # start the redis server daemon
  redis-server redis.conf
done

echo "List of created nodes: $nodes"

NODES_COUNT=$(($MAX_PORT-$INITIAL_PORT + 1))
echo "Waiting for ${NODES_COUNT} Redis server nodes to be up..."
sleep 5

echo "Cluster creation using redis-cli..."
echo "yes" | eval /redis/src/redis-cli --cluster create --cluster-replicas "$SLAVES_PER_MASTER" "$nodes"
echo "Redis cluster with ${NODES_COUNT} nodes is Up and Running!!!"

# keep Docker process running, otherwise container will exit with code 0
tail -f /dev/null