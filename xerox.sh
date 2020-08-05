#!/bin/bash

while getopts u:p:l:r:t:e flag
do
    case "${flag}" in
        u) username=${OPTARG};;
        p) password=${OPTARG};;
        l) login_url=${OPTARG};;
        r) repository=${OPTARG};;
        t) new_tag=${OPTARG};;
        e) exit=${OPTARG};;

    esac
done

cleanup()
{
    echo -e "config dir cleaned up:$(rm -r $context_dir) $?.\n";
    icm=`docker image rm $repository $new_tag 2>&1`;
    echo -e "images cleaned up: $icm \tcode: $?.\n\n";
}

echo -e "params [Username:$username,\tpassword:$(cut -c-3 <<< $password)******,\tlogin_url:$login_url,\trepository:$repository,\tnew_tag:$new_tag]\n";


# trying to logn to given registry and save credentials on $config_dir folder for this user
echo -e "1. loging in...";
context_dir="./$(date '+%s')"
config_dir="$context_dir/$username";

login_result_message=`docker --log-level error --config $config_dir login $login_url --username $username --password $password  2>&1`;
login_result_code=$?;

if [ $login_result_code -eq 0 ]; then
    echo -e "\tlogged in successfully!\n";
else
    echo -e "\tcant login to registry with given credential: $login_result_message.\n";
    exit 1;
fi

#=======================================================================================================
# trying to pull image from registry
echo -e "2. pulling image...";
pull_result_message=`docker --config $config_dir pull $repository 2>&1`;
pull_result_code=$?;
if [ $pull_result_code -eq 0 ]; then
    echo -e "\tpulled successfully!\n";
else
    echo -e "\tcant pull image: $pull_result_message.";
    cleanup;
    exit 2;
fi

#=======================================================================================================
# trying to tag image
echo -e "3. tagging image...";
tag_result_message=`docker --config $config_dir tag $repository  $new_tag 2>&1`;
tag_result_code=$?;
if [ $tag_result_code -eq 0 ]; then
    echo -e "\timage tagged successfully!\n";
else
    echo -e "\tcant tag image: $tag_result_message.";
    cleanup;
    exit 3;
fi

#=======================================================================================================
# trying to push image
echo -e "3. pushing image...";
push_result_message=`docker --config $config_dir push $new_tag 2>&1`;
push_result_code=$?;
if [ $push_result_code -eq 0 ]; then
    echo -e "\timage pushed successfully!\n";
else
    echo -e "\tcant push image: $push_result_message.";
    cleanup;
    exit 4;
fi

#=======================================================================================================
# trying to logout from registry
echo -e "5. loging out...";
logout_result_message=`docker --log-level error --config $config_dir logout $login_url  2>&1`;
logout_result_code=$?;

if [ $logout_result_code -eq 0 ]; then
    echo -e "\tlogged out in successfully!"
    cleanup;
else
    echo -e "\tcant logout from registry: $logout_result_message.";
    cleanup;
    exit 5
fi
