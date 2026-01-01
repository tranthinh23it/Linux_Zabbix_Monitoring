#!/bin/bash

# Docker Container Statistics Script
# Usage: docker_stats.sh <metric> [container_name]

METRIC="$1"
CONTAINER="$2"

case "$METRIC" in
    "containers.running")
        docker ps -q | wc -l
        ;;
    "containers.total")
        docker ps -aq | wc -l
        ;;
    "containers.stopped")
        TOTAL=$(docker ps -aq | wc -l)
        RUNNING=$(docker ps -q | wc -l)
        echo $((TOTAL - RUNNING))
        ;;
    "container.cpu")
        if [ -z "$CONTAINER" ]; then
            echo "Container name required"
            exit 1
        fi
        docker stats --no-stream --format "{{.CPUPerc}}" "$CONTAINER" | sed 's/%//'
        ;;
    "container.memory")
        if [ -z "$CONTAINER" ]; then
            echo "Container name required"
            exit 1
        fi
        docker stats --no-stream --format "{{.MemPerc}}" "$CONTAINER" | sed 's/%//'
        ;;
    "container.memory.usage")
        if [ -z "$CONTAINER" ]; then
            echo "Container name required"
            exit 1
        fi
        docker stats --no-stream --format "{{.MemUsage}}" "$CONTAINER" | awk '{print $1}' | sed 's/MiB//' | sed 's/GiB//'
        ;;
    "images.total")
        docker images -q | wc -l
        ;;
    "volumes.total")
        docker volume ls -q | wc -l
        ;;
    "networks.total")
        docker network ls -q | wc -l
        ;;
    *)
        echo "Unknown metric: $METRIC"
        echo "Available metrics: containers.running, containers.total, containers.stopped, container.cpu, container.memory, container.memory.usage, images.total, volumes.total, networks.total"
        exit 1
        ;;
esac