#!/bin/bash

tag = ""
echo Enter service details.

read -p 'Registry Name' regName
read -p 'Port to Open' portNum
read -p 'Tag Name' tag

if [$tag != ""]
then 
  docker service create --name $regName --publish published=$portNum,target=$portNum $regName:$tag
  response=$(curl http://localhost:portNum/v:$tag)
else
  docker service create --name $regName --publish published=$portNum,target=$portNum $regName
  response=$(curl http://localhost:portNum)
fi

if[response != ""]
then
    if [[-f docker-compose.yml]]
    then
        docker service ls
        docker compose up -d
        read -p 'enter port to test from' composePort
        if($(curl http://localhost:$composePort))
        then
            docker compose down --volumes
            docker compose push
            
            read -p 'Enter Preferred Stack Name' stackName
            docker stack deploy --compose-file docker-compose.yml $stackName
            docker stack services $stackName

            response = $(curl http://localhost:$composePort)

            if[response != ""]
            then 
                echo Setup success, response from compose with response: $response
            else
                echo Setup failed, removing stack and service. Leaving swarm.
                docker stack rm $stackName
                docker service rm $regName
                docker swarm leave --force
        else
            echo No response, push aborted.
            docker compose down --volumes
            docker compose push
    else
        echo No docker-compose file, aborting test.
        docker service rm $regName
else
    docker service rm $regName
    echo No response from given registry, service setup failed.
    

    

  



