#!/bin/bash
clear
cd ./games/.minecraft/
#I don't know how this works, it just does. don't touch it 
command -v curl >/dev/null 2>&1 || { echo "" >&2; read -p "missing dependancy 'curl,' may I attempt to install it?" -n 1 -r;
echo
if (( $REPLY =~ ^[Yy]$ )) 
then
    sudo apt-get install curl
    
else
    echo "Please run 'sudo apt-get install curl' in terminal to install curl, if using another distribution, please install curl"
    echo "Press Enter or Return to continue"
    read willexit
    exit
fi
}
function getLogin { 
clear
echo "Please enter your Minecraft Username:"  
read username;
clear
echo "Hello " $username ", Please enter your Password:"
read -s password;
clear
}
#if [ -f ~/.mcsession ]; then
#session=$(cat ~/.mcsession)
#else
#echo Session ID file not found, attempting login
#commented out until I complete the session validation portion


#this sets the sessionID to a variable so it can be used in launching the game
#msjson is just to format the output better for debugging, and jq is for extracting the value we need
function auth {
echo "Logging into Mojang's authentication servers, please wait."
sessionInfo=$(curl -si \
-H "Accept:application/json" \
-H "content-Type:application/json" \
'https://authserver.mojang.com/authenticate' \
-X POST --data '{
  "agent": {
    "name": "Minecraft",
    "version": 1
  },
  "username": "'$username'",
  "password": "'$password'"
}' | grep }| python -mjson.tool)
}
function parseJSON { echo $1 | jq -M $2
}
getLogin
auth
session=`echo $sessionInfo | jq -M .selectedProfile.id`
session=`parseJSON sessionInfo .selectdProfile.id`
accessToken=`parseJSON sessionInfo .accessToken`
clientToken=`parseJSON sessionInfo .clientToken`
if [ ! -z "$session" ] 
#this determines whether the sessionID exists in the server's response, and if not, offer offline mode
then 
    echo "logging into minecraft as "$username" with sessionid "$session 
else 
echo "No sessionID found, use offline mode?"
read
if (( $REPLY =~ ^[Yy]$ ))
then
    echo "Logging into Minecraft as "$username" offline"
    java -Xms512m -Xmx512m -Djava.library.path=natives/ -cp ".;minecraft.jar;lwjgl.jar;lwjgl_util.jar" net.minecraft.client.Minecraft $user
else
echo Press Enter to Exit
read willexit
exit
fi
fi
java -Xms512m -Xmx1g -Djava.library.path=natives/ -cp ".;minecraft.jar;lwjgl.jar;lwjgl_util.jar" net.minecraft.client.Minecraft $user $session
