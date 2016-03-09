#!/bin/bash

set -e

# Solano CI pre_setup hook
# Runs once on the Solano master after repository is checked out and dependencies are installed.

# Customize settings
OSX_HOST_VARS="$ISAAC_OSX_HOST"
OSX_ENV_VARS_FILE=config/solano_osx_env_vars.txt

# Get the OSX worker settings
read -a vars <<< "$OSX_HOST_VARS"
OSX_USER=${vars[0]}
OSX_IP_ADDR=${vars[1]}
OSX_SSH_PORT=${vars[2]}
OSX_REMOTE_HOME=`ssh -l $OSX_USER -A $OSX_IP_ADDR -p $OSX_SSH_PORT 'echo \$HOME'`
OSX_REMOTE_DIR=$OSX_REMOTE_HOME/SolanoCI/`basename $TDDIUM_REPO_ROOT`

# Ensure the remote directory exists
ssh -l $OSX_USER -A $OSX_IP_ADDR -p $OSX_SSH_PORT "mkdir -p $OSX_REMOTE_DIR"

# Create .solano-osx-env-set.sh for OSX worker usage
echo "#!/bin/bash" > .solano-osx-env-set.sh
echo "# Sets local environment variables on OS X" >> .solano-osx-env-set.sh
echo "export TDDIUM_REPO_ROOT=$OSX_REMOTE_DIR" >> .solano-osx-env-set.sh
echo "export TDDIUM_REPO_CONFIG_DIR=$OSX_REMOTE_DIR/config" >> .solano-osx-env-set.sh
if [ -f $OSX_ENV_VARS_FILE ]; then
  # Add any variables named in $OSX_ENV_VARS_FILE
  for e in `cat $OSX_ENV_VARS_FILE | grep -v ^"#"`; do
    eval val=\$$e
    echo "export $e=\"$val\"" >> .solano-osx-env-set.sh
  done
fi
chmod +x .solano-osx-env-set.sh

# Collect relevant ~/.ssh/known_hosts entries
grep -v ^"localhost" $HOME/.ssh/known_hosts | grep -v ^"127.0.0.1" > .solano-known_hosts
scp -P $OSX_SSH_PORT .solano-known_hosts $OSX_USER@$OSX_IP_ADDR:$OSX_REMOTE_HOME/.ssh/known_hosts

# Sync files from linux worker to OSX worker (--delete to ensure a clean workspace)
rsync -az --delete -e "ssh -p $OSX_SSH_PORT" ./ $OSX_USER@$OSX_IP_ADDR:$OSX_REMOTE_DIR

# Create solano-env-set.sh for linux worker usage
echo "#!/bin/bash" > .solano-env-set.sh
echo "# Sets additional local environment variables on Solano CI" >> .solano-env-set.sh
echo "export OSX_USER=$OSX_USER" >> .solano-env-set.sh
echo "export OSX_IP_ADDR=$OSX_IP_ADDR" >> .solano-env-set.sh
echo "export OSX_SSH_PORT=$OSX_SSH_PORT" >> .solano-env-set.sh
echo "export OSX_REMOTE_HOME=$OSX_REMOTE_HOME" >> .solano-env-set.sh
echo "export OSX_REMOTE_DIR=$OSX_REMOTE_DIR" >> .solano-env-set.sh
chmod +x .solano-env-set.sh

