#!/bin/bash
if [ -z ${location:?error&exit} ]; 
then 
    echo "The location is unset, exiting";
    break;
fi
if [ -z ${RG:?error&exit} ]; 
then 
    echo "the ResourceGroup is unset, exiting";
    break;
fi

# Create Resource Group and it set as default
az group create -l $location -n $RG
az configure --defaults location=$location group=$RG output=table