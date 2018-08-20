# image-constructor
Constructor of images for docker.

Consists of two scripts:
 1. debootstrap.sh: Base image constructor.
 2. docker-build.sh: Construct images from Dockerfile and particular base image.

Usage: 
 1. debootstrap.sh OS release_codename base_image_tag  
    Default: debootstrap.sh ubuntu xenial ubuntu/bionic:18.04

 2. docker-build.sh SOURCE_IMAGE_tag TARGET_IMAGE_tag  
    Default: docker-build.sh ubuntu/bionic:18.04-minbase polygon:initial
