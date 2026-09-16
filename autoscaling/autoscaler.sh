#!/bin/bash

SERVICE="express-app_node-app"

MIN_REPLICAS=2
MAX_REPLICAS=6

SCALE_UP_THRESHOLD=8
SCALE_DOWN_THRESHOLD=3

CHECK_INTERVAL=10
COOLDOWN=45

LAST_SCALE_TIME=0

while true; do

    CONTAINERS=$(timeout 5 docker ps -q \
      --filter "label=com.docker.swarm.service.name=$SERVICE" \
      2>/dev/null)

    if [ -z "$CONTAINERS" ]; then
        echo "⚠ No running containers found - skipping"
        sleep "$CHECK_INTERVAL"
        continue
    fi

    CPU=$(timeout 8 docker stats --no-stream \
      --format '{{.CPUPerc}}' \
      $CONTAINERS 2>/dev/null \
      | sed 's/%//' \
      | awk '
        {sum += $1; count++}
        END {
          if (count > 0)
            printf "%.2f", sum/count
        }'
    )

    if [[ ! "$CPU" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        echo "⚠ CPU metric unavailable - skipping this check"
        sleep "$CHECK_INTERVAL"
        continue
    fi

    REPLICAS=$(timeout 5 docker service inspect "$SERVICE" \
      --format '{{.Spec.Mode.Replicated.Replicas}}' \
      2>/dev/null)

    if [[ ! "$REPLICAS" =~ ^[0-9]+$ ]]; then
        echo "⚠ Swarm manager unavailable - skipping this check"
        sleep "$CHECK_INTERVAL"
        continue
    fi

    NOW=$(date +%s)
    SINCE_LAST_SCALE=$((NOW - LAST_SCALE_TIME))

    echo "CPU: ${CPU}% | Replicas: $REPLICAS"

    if [ "$SINCE_LAST_SCALE" -ge "$COOLDOWN" ]; then

        if awk "BEGIN {exit !($CPU > $SCALE_UP_THRESHOLD)}"; then

            if [ "$REPLICAS" -lt "$MAX_REPLICAS" ]; then

                NEW_REPLICAS=$((REPLICAS + 1))

                echo "🔥 HIGH CPU → Scaling UP: $REPLICAS → $NEW_REPLICAS"

                if timeout 8 docker service scale \
                  --detach=true \
                  "$SERVICE=$NEW_REPLICAS"; then

                    LAST_SCALE_TIME=$(date +%s)
                fi
            fi

        elif awk "BEGIN {exit !($CPU < $SCALE_DOWN_THRESHOLD)}"; then

            if [ "$REPLICAS" -gt "$MIN_REPLICAS" ]; then

                NEW_REPLICAS=$((REPLICAS - 1))

                echo "❄ LOW CPU → Scaling DOWN: $REPLICAS → $NEW_REPLICAS"

                if timeout 8 docker service scale \
                  --detach=true \
                  "$SERVICE=$NEW_REPLICAS"; then

                    LAST_SCALE_TIME=$(date +%s)
                fi
            fi
        fi
    fi

    sleep "$CHECK_INTERVAL"

done
