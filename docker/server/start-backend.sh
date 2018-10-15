#!/bin/bash
  
export PORT=4001
export MIX_ENV=prod

mix deps.get
/usr/local/bin/mix phx.server & echo $! > ./phx.server.pid

