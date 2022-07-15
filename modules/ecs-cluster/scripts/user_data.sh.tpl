#!/usr/bin/env bash

echo "Configure ECS cluster"
cat <<'CONFIG' >> /etc/ecs/ecs.config
ECS_CLUSTER=${ecs_cluster}
ECS_LOGLEVEL=${ecs_loglevel}
ECS_CONTAINER_INSTANCE_TAGS=${ecs_tags}
CONFIG
