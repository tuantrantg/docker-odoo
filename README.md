#### Guide (step by step)
- Clone this repo to your local machine
- Go to the folder `docker-odoo` & build the Docker Image from the Dockerfile
  - Run this command to build the Docker Image: `sudo docker build -t tuan_test_docker .`
  - NOTE: `tuan_test_docker` is the image name. If you change this, you must change the image name in `docker-compose.yml` file
- In folder `docker-odoo`, create the Docker Container from the Docker Image above
  - Run this command to create the Docker Container: `sudo docker-commpose up --force-recreate`
- After create the Docker Container, you can open the new terminal to SSH to the new Docker Container
- Here is some information to use this Docker Container
  - The default URL of Odoo: http://localhost:8369/
  - SSH into the container: ssh openerp@localhost -p 8322
  - PostgreSQL: openerp:openerp@localhost:8332
- Update python3 to the latest verion (3.7)
  - Run the following commands:
  - NOTE:
    - When you run the last command `sudo update-alternatives --config python3`, the terminal will ask: **Press enter to keep the current choice[*], or type selection number:** --> Enter **2** for python3.7
```
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get update
sudo apt-get install build-essential libpq-dev libssl-dev openssl libffi-dev zlib1g-dev
sudo apt-get install python3-pip python3.7-dev
sudo apt-get install python3.7
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.4 1
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 2
sudo update-alternatives --config python3
```
