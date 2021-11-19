#!/bin/bash -x
#
# docker-entrypoint.sh
#
# The Dockerfile CMD, or any "docker run" command option, gets
# passed as command-line arguments to this script.

# Abort on any error (good shell hygiene)
set -e

env

APP_MAIN=${APP_MAIN:-setup.sh}

base_app=$(basename $APP_MAIN)
find_app_main=`find $HOME -name $base_app -print | head -n 1`
if [ "${find_app_main}" != "" ]; then
    APP_MAIN=${find_app_main}
    echo "--- Found the actual location of APP_MAIN: ${APP_MAIN}"
else
    echo "***** ERROR *****: Can't find"
    exit 1
fi

# If we're running "myAppName", provide default options
if [[ ${APP_MAIN} =~ "$1" ]]; then
    echo ">> Running: ${APP_MAIN}"
    shift 1
    # Then run it with default options plus whatever else
    # was given in the command
    #exec ${APP_HOME}/${APP_MAIN} "$@"
    exec ${APP_HOME}/${base_app} "$@"
else
   # Otherwise just run what was given in the command
   echo ">> Running: $@"
   #exec "$@"
   $@
fi

