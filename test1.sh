#!/bin/bash
# Чтение строк из файла /etc/fstab.

File=/Users/user/Desktop/devops/bash/test.sh

{
read line1
read line2
} < $File

echo "Первая строка в $File :"
echo "$line1"
echo
echo "Вторая строка в $File :"
echo "$line2"