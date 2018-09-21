# image-constructor
Constructor of images for docker.

Consists of two scripts:
 1. debootstrap.sh: build base image.
 2. build.sh: build images from Dockerfile and particular base image.

Usage: 
 1. debootstrap.sh OS release_codename base_image_tag  
    Default: debootstrap.sh ubuntu xenial ubuntu/bionic:18.04

 2. builder.sh SOURCE_IMAGE_tag TARGET_IMAGE_tag
