# quickly setup ubuntu docker container
docker run -it -h naa1 --rm ubuntu # -it for interactiave shell, -h for hostname, --rm means remove container on exit, ubuntu is docker image name

# install package
dnf install package_name # centos
yum install package_name # centos, dnf is preferred
apt-get install package_name # ubuntu

##### user management, istifadəçilərin idarə edilməsi
cat /etc/passwd # list users, mövcud istifadəçilərin siyahısı
useradd user1 # create new user (low level command), yeni istifadəçi yarat
adduser user1 # adduser is high level and preferred
userdel user1 # delete user, istifadəçini sil
cat /etc/group # list groups, qrupların siyahısı
groupadd group1 # add new group, yeni qrup əlavə et
groupdel group1 # remove group, qrupu silmək
passwd user1 # set/change user password, istifadəçinin şifrəsini dəyişmək
groups user1 # view groups of user1, istifadəçinin aid olduğu qrupları göstərmək
usermod [options] user1 # modify user, istifadəçi məlumatlarını dəyişmək
usermod -a -G group_name username # add user to additional groups, istifadəçini əlavə qrupa əlavə etmək
yum install sudo -y # install sudo or apt install sudo for debian/ubuntu, sudo quraşdırmaq
cat /etc/sudoers # view sudoers, to make user sudo we add user to wheel group or directly modify /etc/sudoers file. İstifadəçini sudoer etmək üçün onu ya wheel qrupuna əlavə etməli və ya /etc/sudoers faylını redaktə etməliyik
su -l user1 # login as user1, change the current user to user1, user1 kimi daxil olmaq, cari istifadəçini user1 adlı istifadəçiyə dəyişmək
sudo <cmd> # execute command with super privileges, commands like shutdown, poweroff, reboot require sudo, əmri super privilegiyalarla icra etmək, məsələn shutdown, poweroff, reboot  kimi əmrlər sudo tələb edir

##### permission management, icazələrin idarə edilməsi
# Permission levels in Linux: u – User (Owner), g – Group, o – Others
# Permission type in Linux: r – read (4), w – write (2), e - execute (1)
chmod a+rw file1 # give all user read/write access, bütün istifadəçilərə oxumaq/yazmaq icazəsi ver
chmod a-rw file1 # revoke read write access from all users, bütün istifadəçilərdən oxumaq/yazmaq icazəsini sil
chmod 775 file1 # give owner full, group full and other read/write access
chmod -r 775 /folder1/* # set 755 permissions to all files inside folder
chown user:group file1 # change file owner, faylın sahibini dəyişmək




##### setup ssh

# centos
yum install -y openssh-server openssh-clients
ssh-keygen -A
nano /etc/ssh/sshd_config # PermitRootLogin yes, PasswordAuthentication yes
service sshd restart # or systemctl restart sshd or /usr/sbin/sshd


# ubuntu
apt-get install openssh-server openssh-client -y
ssh-keygen -A
nano /etc/ssh/sshd_config # PermitRootLogin yes, PasswordAuthentication yes
service ssh start # or systemctl restart ssh

# ssh passwordless login
ssh-keygen # this will generate private/public key pair, public/private key cütlüyünü yarat
ssh-copy-id root@naa2 # register your public key in destination server for passwordless login, açarınızı şifrəsiz qoşulmaq istədiyiniz serverdə qeydiyyatdan keçirin
ssh root@naa2 # this will not require password after above command, daha serverə ssh-lə qoşulmaq üçün şifrə tələb olunmayacaq
nano /etc/ssh/sshd_config # PasswordAuthentication no, set to no to disable password authentification, təhlükəsizliyi artırmaq üçün şifrə ilə autentifikasiyanı söndürün

##### sshfs is a filesystem client to mount and interact with directories and files located 
# on a remote server or workstation over a normal ssh connection
yum --enablerepo=powertools install fuse-sshfs -y # centos
apt-get install sshfs -y # ubuntu
sshfs user@host:/path local_mount_path # usage

### md5

md5sum file_name # or md5 file_name, used to get md5 signature of file, can be used for file or string integrity verification


### chroot - restrict user to specific root folder, istifadəçini ayrılmış qovluqla limitləmək and root qovluğu dəyişmək

nano /etc/ssh/sshd_config

# single chrooted user
userdel -r chroot_user1 # remove user and its files if exists
useradd chroot_user1 # create user
passwd chroot_user1 # set password
mkdir /home/chroot_user1 # run this if home directory is not created
chmod 755 /home/chroot_user1 && chown root:root /home/chroot_user1 # chroot folder must be owned by root with 755 permissions
mkdir /home/chroot_user1/{tmp,Desktop,Downloads,Documents} # create folder for user files
chown -R chroot_user1:chroot_user1 /home/chroot_user1/* # change owner of files inside chroot folder to the chroot user
# change sshd_config file as below
sftp chroot_user1@naa2 # sftp to remote server or sftp chroot_user1@ip_address
put file_path # upload file

nano /etc/ssh/sshd_config

# add following lines 
Subsystem sftp internal-sftp # only single line of Subsystem is allowed
Match User chroot_user1
  X11Forwarding no
  AllowTcpForwarding no
  ChrootDirectory /home/chroot_user1
  ForceCommand internal-sftp


# after changing sshd_config file we need to restart ssh service
systemctl restart sshd # service sshd restart


# specify group and all user from this group will be chrooted to home directory
groupadd chroot_group # create group
useradd -g chroot_user2 -G chroot_group chroot_user2 # create user and add to chroot_group
mkdir /home/chroot_user2 # run this if home directory is not created
chmod 755 /home/chroot_user2 && chown chroot_user2:chroot_user2 /home/chroot_user2 # chroot folder must be owned by root with 755 permissions
passwd chroot_user2

Match Group chroot_group
  X11Forwarding no
  AllowTcpForwarding no
  ChrootDirectory /home
  ForceCommand internal-sftp -d /%u # automatically redirect to user folder



##### cron is a job scheduler on Unix-like operating systems
service cron start
service cron status
crontab -e # edit crontab
crontab -l # view crontab list
* * * * * cmd # minute hour day month weekday


##### samba, network file system
yum install samba samba-client # centos
smbd start && nmbd start

mkdir /samba
groupadd sambashare
chgrp sambashare /samba
useradd -M -d /samba/user1 -s /usr/sbin/nologin -G sambashare user1
mkdir /samba/user1
chown user1:sambashare /samba/user1
chmod 2770 /samba/user1
sudo smbpasswd -a user1
sudo smbpasswd -e user1

useradd -M -d /samba/users -s /usr/sbin/nologin -G sambashare sadmin
sudo smbpasswd -a sadmin
sudo smbpasswd -e sadmin

mkdir /samba/users
chown sadmin:sambashare /samba/users
chmod 2770 /samba/users

## configure smb.conf
nano /etc/samba/smb.conf 
[users]
    path = /samba/users
    writable = yes
    browseable = yes
    read only = no
    force create mode = 0660
    force directory mode = 2770
    valid users = @sambashare

[user1]
    path = /samba/user1
    writable = yes
    browseable = yes
    read only = no
    force create mode = 0660
    force directory mode = 2770
    valid users = user1 @sadmin

# always reload after config change
smbd restart && nmbd restart

# mounting samba shared folder
yum install cifs-utils -y # centos
apt install cifs-utils -y # ubuntu

mount //naa2/user1 /local_path -o 'user=naa1,password=123456' # mount the shared folder

mount # display all mounted resources, bütün mount edilmiş resursları göstərmək

# Using the systemctl command
systemctl status <service_name>
systemctl start <service_name>
systemctl stop <service_name>
systemctl enable <service_name> # make service autostart on boot, servisi avtomatik başlatmaq
systemctl --type=service # list services, servisləri göstərmək

## network security

# proxy - gateway between network and user, hides network from outside, e.g: nginx
dnf install nginx -y # centos, or yum install nginx -y
apt-get install nginx -y # ubuntu

# nginx load balancing: https://docs.nginx.com/nginx/admin-guide/load-balancer/http-load-balancer/

# firewall - for blocking ports and programs (services), e.g: firewalld, iptables

# open http and https ports
firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload

# list open services
firewall-cmd --list-service


# SSH port forwarding

# lokal 8000 portunu ssh üzərindən qoşulacağımız serverin 80-ci portuna yönləndir
# forward local 8000 port to 80 port of remote server over ssh protocol
ssh -L 8000:remote_host:80 root@remote_host

# qoşulacağımız serverin 8000 portunu lokal 80 porta ssh üzərindən yönləndir
# forward remote 8000 port to local 80 port over ssh protocol
ssh -R 8000:localhost:80 root@remote_host

# crontab examples:
crontab -l # list cron jobs
crontab -e # add/remove/edit cron job list

# https://crontab-generator.org/
# the minimal interval for cron is 1 minute
* * * * * command_to_execute # job that executes every minute
*/8 * * * * command_to_execute # job that executes every 8 minutes
0 10 * * * command_to_execute # job that executes dail at 10:00 AM
*/15 9-18 * * * command_to_execute # job that executes every 15 minutes between 9:00 AM and 6:00 PM


# transfer files from local to remote server (rsync and scp)
rsync -vuar /local_path user@remote_host:/remote_path


# default ports
ssh - 22
http - 80
https - 443
smtp - 25
dns - 53
mysql - 3306



