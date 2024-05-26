# first make sure that docker is installed and running

# next we setup 2 ubuntu containers
docker run -it -h host1 --rm ubuntu
docker run -it -h host2 --rm ubuntu

# use hostname -i command to get the ip address of the container
hostname -i
# next run apt update to update repositories and be able to install packages
apt update # run this on both containers

# now install ssh on both containers
apt-get install openssh-server openssh-client -y

# now install nano which is a text editor
apt install nano -y

# we want to initiate SSH from host1 to host2
# we enable root login and password authentication in host2
# set PermitRootLogin yes, PasswordAuthentication yes in /etc/ssh/sshd_config
nano /etc/ssh/sshd_config # use this to change ssh configuration file

service ssh restart # restart ssh service to apply configuration

passwd # change root password in host2

ssh root@172.17.0.3 # 172.17.0.3 is ip address of host2 that we got from hostname -i command


mkdir /naa # on host2 and create some files inside it
cd naa
touch a.txt b.txt # create some files inside /naa folder of host2

mkdir /test # on host1 and create some files inside it
cd /test
touch d.txt e.txt # create some files inside /test folder of host1

scp root@172.17.0.3:/naa/*.txt /test # copy files from host2 to host1
scp /test/*.txt root@172.17.0.3:/naa # copy files from host1 to host2

touch /test/f.txt # create a new file on host1
apt install rsync -y # install rsync on host1 and host2
rsync -vuar /test/* root@172.17.0.3:/naa # copy files from host1 to host2


mkdir /main_folder # create a folder on host1
mkdir /backup_folder # create a folder on host2


apt install cron # install cron on host1
cron start # start cron

# add following line * * * * * sh /main_folder/backup.sh >/dev/null 2>&1
crontab -e # edit cron jobs on host1
crontab -l # list cron jobs on host1

# now let's setup passwordless login from host1 to host2
ssh-keygen # generate key pair on host1
ssh-copy-id root@172.17.0.3 # transfer key from host1 to host2

cd /main_folder
touch c.txt # create file in main_folder of host1 and wait until cron is executed
ls /test_folder # run this on host2 and make sure c.txt is transferred


