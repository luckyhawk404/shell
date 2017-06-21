#!/bin/bash
user=User
if grep $user /etc/passwd
then
echo "The user $user Exists"
fi