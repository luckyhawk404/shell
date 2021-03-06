#!/bin/bash
source=$1 #в переменную source засовываем первый параметр скрипта
dest=$2 #в переменную dest засовываем второй параметр скрипта

if [[ "$source" -eq "$dest" ]] # в ковычках указываем имена переменных для сравнения. -eq - логическое сравнение обозначающие "равны"
then # если они действительно равны, то
echo "Применик $dest и источник $source один и тот же файл!" #выводим сообщение об ошибке, т.к. $source и $dest у нас равны
exit 1 # выходим с ошибкой (1 - код ошибки)
else # если же они не равны
cp $source $dest # то выполняем команду cp: копируем источник в приемник
echo "Удачное копирование!"
fi #обозначаем окончание условия.