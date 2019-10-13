#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
READY="/usr/local/docker/ready"

LOG_LEVEL=4
INIT_LOG="/var/log/docker/init.log"

source /etc/bash/logger.sh
source /etc/bash/replace.sh
source /etc/bash/function.sh

ping -c 1 8.8.8.8 &> /dev/null
IS_ONLINE=$?

if [[ ! -f "$READY" ]]; then
  info "First run, initialize the container..."
  source $DIR/init.sh
fi

for file in $DIR/update/*.sh; do
    [ -e "$file" ] && source $file
done

source $DIR/run.sh
