# first make sure that docker is installed and running, start docker service by launching Docker Desktop

# next we setup 2 ubuntu containers, we also map port 80 of container to port 8080 and 8081 of the host
docker run -it -h h1 --rm --privileged --name h1 -p 8080:80 ubuntu
docker run -it -h h1 --rm --privileged --name h2 -p 8081:80 ubuntu

# then install nginx on both containers and start it
# go to http://localhost:8080/ in browser, it will show nginx welcome page
# go to http://localhost:8081/ in browser, it will show nginx welcome page
apt update
apt install nginx -y
service nginx start

# let's modify welcome page on both containers
echo '<h1>Salam from h1</h1>' > /var/www/html/index.html # run this on h1 container
echo '<h1>Salam from h2</h1>' > /var/www/html/index.html # run this on h2 container

# you may also install nano and paste some text in index.html file, use chatgpt to generate sample html code
apt install nano -y
nano /var/www/html/index.html

# install firewall on both containers
apt install iptables -y

# now let's block port 80 on both containers
# this will block port 80, verify this on the browser by going to http://localhost:8080/ and http://localhost:8081/
iptables -A INPUT -p tcp --dport 80 -j DROP 

# delete the rule and unblock port 80, replace -A with -D to delete the rule and verify from browser
iptables -D INPUT -p tcp --dport 80 -j DROP 

# install curl on both containers and get the ip address of 2nd container
apt install curl -y
curl http://ip_of_h2_container

 # on the 2nd container allow ip address of the 1st containers, use hostname -i to get the ip address on the 1st container
iptables -A INPUT -p tcp  -s ip_adress_of_h1_container --dport 80 -j ACCEPT

# block 80 port for all other
iptables -A INPUT -p tcp --dport 80 -j DROP 

# now let's verify rules
iptables -L

#output must be following, notice the order of rules, first we have ACCEPT rule, then we have DROP rule:
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     tcp  --  172.17.0.2           anywhere             tcp dpt:http
DROP       tcp  --  anywhere             anywhere             tcp dpt:http

# now let's block port 80 on 2nd containers and allow only connections from localhost
iptables -F # flush all rules
iptables -A INPUT -p tcp -s 127.0.0.1 --dport 80 -j ACCEPT # accept connections from localhost
iptables -A INPUT -p tcp --dport 80 -j DROP # block all other connections

# let's install ssh on both containers
apt-get install openssh-server openssh-client -y

# permit root login on the second container
nano /etc/ssh/sshd_config # set PermitRootLogin yes

passwd # change root password on the second container

# start ssh on both containers
service ssh start

# make sure that curl is not working on the first container
curl http://ip_adress_of_h2_container

# let's establish ssh tunnel from the first container to the second container
# we forward 8888 port of the first container to 80 port of the second container
ssh -L 8888:localhost:80 root@172.17.0.3

# now go inside h1 container in new terminal and run curl command
docker exec -it h1 bash
curl http://localhost:8888 # this should output html code of the second container





