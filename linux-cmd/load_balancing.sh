# first make sure that docker is installed and running, start docker service by launching Docker Desktop

# create 3 containers, 1st will be load balancer, 2nd and 3rd will be web servers
docker run -it -h h1 --rm --privileged --name h1 -p 8081:80 ubuntu
docker run -it -h h2 --rm --privileged --name h2 -p 8082:80 ubuntu
docker run -it -h h3 --rm --privileged --name h3 -p 8083:80 ubuntu

# install nginx on all containers
apt update
apt install nginx
service nginx start

# create welcome page on all containers
echo '<h1>Salam from h1</h1>' > /var/www/html/index.html # run this on h1 container, http://localhost:8081/
echo '<h1>Salam from h2</h1>' > /var/www/html/index.html # run this on h2 container, http://localhost:8082/
echo '<h1>Salam from h3</h1>' > /var/www/html/index.html # run this on h3 container, http://localhost:8083/


# now on the first container we will setup nginx as load balancer
apt install nano
nano /etc/nginx/conf.d/loadbalancing.conf
# put following code in loadbalancing.conf file, use ctl+o to save and ctl+x to exit
upstream loadbalancer1 {
    server ip_address_of_second_container;
    server ip_address_of_third_container;
}

server {
    listen 80;

    location / {
        proxy_pass http://loadbalancer1;
    }
}

# now remove default configuration file on the first container
rm /etc/nginx/sites-enabled/default 

# restart nginx on first container to apply configuration
service nginx restart

# in browser go to http://localhost:8081/ and refresh the page, 
# you will see that it will show 'Salam from h1' and 'Salam from h2' alternatively


# now let's use weight parameter to make 2nd container receive more requests
nano /etc/nginx/conf.d/loadbalancing.conf

# put following code in loadbalancing.conf file, use ctl+o to save and ctl+x to exit
server ip_address_of_second_container weight=2;

# now check http://localhost:8081/, you will see that it will show 'Salam from h2' twice more often
