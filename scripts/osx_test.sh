#!/bin/bash
# Run test on osx worker and collect log
# Usage: osx_test.sh <command>

set -o errexit -o pipefail

# Load local environment variables
source .solano-env-set.sh 

function attach_log {
  # Collect log and attach it to the test results 
  scp -P $OSX_SSH_PORT $OSX_USER@$OSX_IP_ADDR:$OSX_REMOTE_DIR/osx-$TDDIUM_TEST_EXEC_ID.log $HOME/results/$TDDIUM_SESSION_ID/$TDDIUM_TEST_EXEC_ID/
}
trap attach_log EXIT

echo "Running on OS X: $@"
echo "Test results saved to osx-$TDDIUM_TEST_EXEC_ID.log"

# Run test
ssh -l $OSX_USER -A $OSX_IP_ADDR -p $OSX_SSH_PORT "source ~/.solano_profile && cd $OSX_REMOTE_DIR && source .solano-osx-env-set.sh && $@ 2>&1 > osx-$TDDIUM_TEST_EXEC_ID.log"
