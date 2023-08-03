#!/bin/bash

USERNAME="terry"
PASSWORD="terry"

# useradd
useradd -m -s /bin/bash $USERNAME
# password
echo "$USERNAME:$PASSWORD" | chpasswd
# sudo with no password
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers
