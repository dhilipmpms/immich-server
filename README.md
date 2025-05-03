# immich-server
chmod +x setup-immich.sh

./setup-immich.sh

# To stop immich server 

sudo docker compose down 

# To run again immich server

inside the folder created after the bash script is executed , enter into the folder and run " sudo docker compose up -d "

dont run the immich-server bash script agin it will delete the existing folder and recreate it you will lose data
