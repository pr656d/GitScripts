#!/bin/bash

# Colors for showing colored output
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

clear
echo

check_status () {
    if [[ $? -ne 0 ]];
    then
        echo
        echo "$red>>> Something went wrong. Check above output for help. $reset"
        exit 1
    fi
}

remote_add () {
    directory=$( basename "$PWD" )
    if ! ( $( git config remote.$directory.url > /dev/null ) );
    then
        echo
        printf "$green>>> Choose remote: ssh/https? : $reset"
        address=""
        read opt
        if [ "$opt" == "ssh" ];
        then
            echo
            printf "$green>>> SSH Address: $reset"
            read address
        elif [ "$opt" == "https" ];
        then
            echo
            printf "$green>>> HTTPS Address: $reset"
            read address
        else
            echo
            echo "$red>>> Choose ssh or https. $reset"
        fi
        git remote add origin $address
        check_status
    fi
}

# Navigate to directory
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

# Add key to Git
echo "$green>>> ADD SSH KEY FOR GITHUB$reset"
ssh-add ~/.ssh/id_rsa
check_status

echo

git add .
echo "$green>>> FILES ADDED $reset"
check_status

echo

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

echo "$green>>> PUSHING TO GITHUB $reset"
git push $remote_name master
check_status

echo
echo

echo "$green>>> DONE $reset"    
exit 0  