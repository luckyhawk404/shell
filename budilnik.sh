#!/bin/bash

# Будильник

# включаем музыку
alarm_start()
{
	# убиваем все процессы mplayer-а
	jbs=(`ps al | grep [m]player | gawk -F ' ' '{print $3}'`)
	for job in ${jbs[*]} ; do
		kill -15 $jbs
	done
	
	# включаем случайную мелодию с бесконечным повтором
	if [ -z "$1" ] ; then
		mplayer -loop 0 -shuffle $folder &> /dev/null &
	fi
}

# время по умолчанию
tm='07:05'

# начальная громкость
volume=10

# максимальная громкость
volume_max=90

# время для смены задачи
sec=2

# папка с музыкой
folder=~username/Music/alarm/*

# временный файл для статуса
temp=`mktemp -t alarm_status_XXX.txt`

# от намеренного закрытия сонного человека
trap "echo -e '\nНеа, решите задачу!' && sleep 1 && alarm_start" SIGINT SIGTERM SIGHUP SIGQUIT SIGTSTP SIGSTOP


if [[ $# > 0 ]] ; then
	if [[ "$1" == [0-9]:[0-9][0-9] ]] || [[ "$1" == [0-9][0-9]:[0-9][0-9] ]] ; then
		tm=$1
	else
		echo 'Установите правильное время. Пример: "07:00".' >&2
		exit 10
	fi
fi

date1=$(date -d "`date +%m/%d/%y` $tm" +%s)
date2=$(date -d "`date +%m/%d/%y` $tm tomorrow" +%s)

# последняя ошибка (если неверная дата)
err=$?
if [[ $err > 0 ]] ; then
	echo 'Установите правильное время. Пример: "07:00".' >&2
	exit $err
fi

# если настоящее время больше времени для пробуждения, то ставим завтрашний день
if [[ $date1 < `date -u +%s` ]] ; then
	date=$date2
else
	date=$date1
fi


# засыпаем
sudo rtcwake -m mem -t $date
# sudo echo "$date" > /sys/class/rtc/rtc0/wakealarm

# устанавливаем громкость
amixer -q set Master $volume%

# день недели
# day=$(( `date +%u` - 1 ))

# включаем музыку
alarm_start

# повышаем уровень громкости
while true ; do
	amixer sset Master 1%+ &> /dev/null
	volume=$(( $volume+1 ))
	
	if [ $volume -eq $volume_max ] ; then
		break
	elif [ -s "$temp" ] ; then
		rm "$temp"
		
		# возвращаем нормальную громкость
		amixer -q set Master 50%
		
		break
	fi
	sleep 2
done &

clear
echo 'Чтобы выключить музыку решите пример:'

while true ; do
	# ждём
	echo "Ждите $sec сек."
	sleep $sec
	
	# пример который надо решить
	var1=$(( $RANDOM % 10000 - 5000 ))
	var2=$(( ($RANDOM % 100000 - 50000)/($RANDOM % 800 + 1) ))
	
	# операторы
	case $(( $RANDOM % 3 )) in
		0)
			opt='+'
			result=$(( $var1 + $var2 ))
		;;
		1)
			opt='-'
			result=$(( $var1 - $var2 ))
		;;
		2)
			opt='*'
			var2=$(( ($RANDOM % 5 + 5) ))
			result=$(( $var1 * $var2 ))
		;;
	esac
	
	# для красоты
	if [[ $var2 < 0 ]] ; then
		if [[ "$opt" == '-' ]] ; then
			opt='+'
			var2=$(( $var2 * -1 ))
		elif [[ "$opt" == '+' ]] ; then
			opt='-'
			var2=$(( $var2 * -1 ))
		fi
	fi
	
	# ответ
	read -p "$var1 $opt $var2 = " answer
	
	# завершаем цикл если ответ был правильный
	if [[ $answer == $result ]] ; then
		echo "Правильно! Ответ: $result."
		break
	else
		clear
		echo -n "Неверно! Правильный ответ был: $var1 $opt $var2 = $result."
		if [ -n "$answer" ] ; then
			echo " Вы ответили: $answer."
		else
			echo ""
		fi
	fi
done

alarm_start false

# для выключения увеличения громкости
echo "done" > "$temp"