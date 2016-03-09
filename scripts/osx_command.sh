#!/bin/bash
# Run arbitrary command on osx worker and collect log
# Usage: osx_command.sh <log-file> <command>

set -o errexit -o pipefail

# Load local environment variables
source .solano-env-set.sh 

# Attach log file on exit
LOG_FILE=$1
shift
function attach_log {
  scp -P $OSX_SSH_PORT $OSX_USER@$OSX_IP_ADDR:$OSX_REMOTE_DIR/$LOG_FILE.log $HOME/results/$TDDIUM_SESSION_ID/session/
}
trap attach_log EXIT

# Run arbitrary command on osx worker
# `source ~/.solano_profile` since full $PATH may be needed, even though it is a non-interactive shell
echo "Running on OS X: $@"
ssh -l $OSX_USER -A $OSX_IP_ADDR -p $OSX_SSH_PORT "source ~/.solano_profile && cd $OSX_REMOTE_DIR && source .solano-osx-env-set.sh && $@ 2>&1 > $LOG_FILE.log"

