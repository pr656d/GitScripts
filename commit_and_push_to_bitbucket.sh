#!/bin/bash

# Colors for showing colored output
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

clear
echo

# Checking status of executed command. If unsuccessful then terminate.
check_status () {
    if [[ $? -ne 0 ]];
    then
        echo
        echo "$red>>> Something went wrong. Check above output for help. $reset"
        exit 1
    fi
}

# Adds new remote connection.
remote_add () {
    echo
    printf "$green>>> Enter remote address : $reset"
    read address
    git remote add origin $address
    check_status
}

# Navigate to directory.
printf "$green>>> Do you want to navigate to directory? y/n: $reset"
read opt
if [ "$opt" == 'y' ]
then
    echo
    printf "$green>>> Enter directory path: $reset"
    read path
    cd "$path"
    check_status
fi

echo

# Check if directory exist.
if ! [ -d .git ];
then
    echo "$red>>> This directory is not git repository. $reset"
    echo
    printf "$green>>> Do you want to make repository? y/n: $reset"
    read opt
    if [ "$opt" == 'y' ];
    then
        git init
        check_status
        remote_add
    else
        echo
        echo "$green>>> DONE $reset"
        exit 0
    fi
fi

remote_add

echo

# Start SSH agent
echo "$green>>> STARTING SSH AGENT $reset"
eval `ssh-agent -s`
check_status

echo

# Add key to BitBucket
echo "$green>>> ADD SSH KEY FOR BITBUCKET$reset"
ssh-add ~/.ssh/id_rsa_bb
check_status

echo

# Add files to commit
git add .
echo "$green>>> FILES ADDED $reset"
check_status

echo

# commit to repository
printf "$green>>> COMMIT MESSAGE : $reset"
read message
git commit -am "$message"
check_status

echo
echo

printf "$green>>>Is it default remote: origin? y/n: $reset"
read opt
remote_name="origin"
if [ "$opt" == 'n' ];
then
    printf "$green>>> Enter remote name: $reset"
    read remote_name
fi

echo

echo "$green>>> PUSHING TO BITBUCKET $reset"
git push $remote_name master
check_status

echo
echo

echo "$green>>> DONE $reset"
exit 0