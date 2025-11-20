# Remove docker images with <none> tag and lable
docker images | grep none | awk '{print $3}' | while read imageid; do docker container ls -a --filter ancestor=$imageid | awk 'NR>1 {print $1}' | xargs docker container rm; docker image rm $imageid; done

