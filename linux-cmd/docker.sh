#####################################################################
## docker-compose commands, works with service names ################
## docker-compose will look for docker-compose.yml file by default ##
#####################################################################

docker-compose up -d # build and start all the containers
docker-compose up -d service_name # build and start specific container

# stop and remove all the containers, 
# removes all the data unless the data persistence is specified
docker-compose down 
docker-compose rm -f -s service_name # remove the specific container
docker rmi $(docker images | grep service_name | awk '{ print $3 }') # remove specific image
docker system prune -a # remove all images and dangling data
docker-compose down --rmi all -v # stop and remove containers, remove all images and volumes

docker-compose down && docker-compose up -d # recreate all the containers

docker-compose start # start all the containers
docker-compose start service_name # start specific container
docker-compose stop # stop all the containers
docker-compose stop service_name # stop specific container

docker-compose up --no-start # create but do not start all the containers

docker-compose logs service_name # view container logs

#################################################
## docker commands, works with container names ##
#################################################

docker ps -a # view the container list
docker exec -it container_name bash # access command line of the container
docker start $(docker ps -aq) # start all the containers
docker start container_name # stop the specific container
docker stop container_name # stop the specific container
docker rm -f container_name # stop and remove specific container

docker exec container_name path/inside # execute specific script from within container

docker exec -it container_name echo "test" # execute inline command from within container

docker cp src/path container_name:dest/path #copy file to container

echo "" > $(docker inspect --format='{{.LogPath}}' <container_name_or_id>) # clear container logs