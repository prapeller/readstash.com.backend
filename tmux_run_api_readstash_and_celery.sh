#!/bin/bash

session="run_api_readstash_and_celery"

# Ensure the session is not already running
if tmux has-session -t $session 2>/dev/null; then
  tmux kill-session -t $session
fi

# Start tmux server and new session
tmux start-server
tmux new-session -d -s $session

# keycloak, redis, postgres containers
tmux send-keys "make keycloak-readstash-build-loc" C-m
tmux send-keys "make rabbit-readstash-build-loc" C-m
tmux send-keys "make redis-readstash-build-loc" C-m
tmux send-keys "make postgres-readstash-build-loc" C-m

# api_readstash local
tmux send-keys "source ./export_local_envs.sh" C-m
tmux send-keys "cd api_readstash" C-m
tmux send-keys "if [ ! -d venv ]; then python3.11 -m venv venv && source venv/bin/activate && pip install --upgrade pip && pip install -r requirements/local.txt; else source venv/bin/activate; fi" C-m
tmux send-keys "../docker/api_readstash/entrypoint_api.sh" C-m
tmux send-keys "../docker/api_readstash/start_api_local.sh" C-m

tmux splitw -h

# api_readstash celery worker
tmux send-keys "source ./export_local_envs.sh" C-m
tmux send-keys "cd api_readstash" C-m
tmux send-keys "if [ ! -d venv ]; then python3.11 -m venv venv && source venv/bin/activate && pip install --upgrade pip && pip install -r requirements/local.txt; else source venv/bin/activate; fi" C-m
tmux send-keys "../docker/api_readstash/entrypoint_api.sh" C-m
tmux send-keys "../docker/api_readstash/start_api_celery_worker.sh" C-m

tmux splitw -h

# api_readstash celery flower
tmux send-keys "source ./export_local_envs.sh" C-m
tmux send-keys "cd api_readstash" C-m
tmux send-keys "if [ ! -d venv ]; then python3.11 -m venv venv && source venv/bin/activate && pip install --upgrade pip && pip install -r requirements/local.txt; else source venv/bin/activate; fi" C-m
tmux send-keys "../docker/api_readstash/entrypoint_api.sh" C-m
tmux send-keys "../docker/api_readstash/start_api_celery_flower.sh" C-m

# Attach to the session
tmux attach-session -t $session
