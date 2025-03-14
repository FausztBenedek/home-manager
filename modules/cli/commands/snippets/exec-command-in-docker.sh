# Execute a command in a running docker container
docker exec -it $(docker ps | sed 1d | awk '{print $17}' | fzf) /bin/bash -c "echo 'Hello world'"
