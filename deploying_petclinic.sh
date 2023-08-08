#!/bin/bash

PETCLINIC_APP_LOCAL_LOCATION="/Users/aushkov/maven_final"
GCP_PROJECT_ID="playground-s-11-b2c45588"

#Creating network
gcloud compute networks create petclinic-network \
	--subnet-mode=custom
#Creating subnet
gcloud compute networks subnets create petclinic-subnet \
	--network=petclinic-network \
	--range=10.0.1.0/24 \
	--region=us-central1
#Creating firewall rules
gcloud compute firewall-rules create petclinic-firewall \
	--network petclinic-network \
	--action allow \
	--rules tcp:8080,tcp:22
#Creating docker artifact repository
gcloud artifacts repositories create image-repo \
	--location=us-central1 \
	--repository-format=docker
#Building application in repository
gcloud builds submit $PETCLINIC_APP_LOCAL_LOCATION \
	--region=us-central1 \
	--tag=us-central1-docker.pkg.dev/$GCP_PROJECT_ID/image-repo/petclinic-image:tag1
#Reserving external IP address
gcloud compute addresses create petaddress \
	--region=us-central1
#Creating VM with dockerized application inside
gcloud compute instances create-with-container petclinic-instance-1 \
	--zone us-central1-a \
	--machine-type=e2-medium \
	--container-image=us-central1-docker.pkg.dev/$GCP_PROJECT_ID/image-repo/petclinic-image:tag1 \
	--network=petclinic-network \
	--subnet=petclinic-subnet \
	--address=petaddress
