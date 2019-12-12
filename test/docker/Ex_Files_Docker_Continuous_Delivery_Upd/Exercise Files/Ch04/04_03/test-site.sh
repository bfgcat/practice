#!/bin/bash

aws cloudformation wait stack-create-complete --region us-east-1 --stack-name testing
sleep 180
curl [ADD_SERVER_ADDRESS_HERE]| grep '<title>Welcome to example-webapp</title>'
if [ $? -eq 0 ]
then
    echo tests pass
else
    echo tests failed
    exit 1
fi
aws cloudformation delete-stack --region us-east-1 --stack-name testing
