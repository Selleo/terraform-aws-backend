#!/usr/bin/env bash

echo "Configure ECS cluster"
cat <<'CONFIG' >> /etc/ecs/ecs.config
ECS_CLUSTER=${ecs_cluster}
ECS_LOGLEVEL=debug
CONFIG
