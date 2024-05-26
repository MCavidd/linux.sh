docker run -it --name h1 -h h1 --rm ubuntu

# install gcc
apt update
apt install build-essential -y

# install nano
apt install nano -y

# create bash script to calculate number of items in a directory, ask chatgpt to generate the script
nano naa.sh

# paste the following code in the script and save the file
find "/test" -mindepth 1 -maxdepth 1 | wc -l

# make the script executable
chmod +x naa.sh

# now create naa.c file to call the script from c program
nano naa.c

# paste the following code in the file and save it

#include<stdio.h>
#include<stdlib.h>
#include <unistd.h>

int main(int argc, char const *argv[])
{
    char *programName = "sh";
    char *args[] = {programName, "naa.sh", ".", NULL};
    execvp(programName, args);
}


# now compile the c program
gcc -o naa  naa.c

# run the program
./naa


# change shell script to accept command line arguments
nano naa.sh

# paste the following code in the script and save the file
find "$1" -mindepth 1 -maxdepth 1 | wc -l


# now modify C file to work with command line arguments
nano naa.c

#include<stdio.h>
#include<stdlib.h>
#include <unistd.h>

int main(int argc, char const *argv[])
{
    char p[20];
    sprintf(p, "%s", argv[1]);
    char *programName = "sh";
    char *args[] = {programName, "naa.sh", p, NULL};
    execvp(programName, args);
}


# now compile the c program
gcc -o naa  naa.c

# run the program
./naa /test
./naa /etc
