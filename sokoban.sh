#!/bin/bash
#Компьютерная игра Sokoban
#Определим карту как массив
map=( W W W W W W W W W W W W W W W W W W W W
W W W W W W W W W W W W W W W W W W W W
W W W W W _ _ _ W W W W W W W W W W W W
W W W W W = _ _ W W W W W W W W W W W W
W W W W W _ _ = W W W W W W W W W W W W
W W W _ _ = _ = _ W W W W W W W W W W W
W W W _ W _ W W _ W W W W W W W W W W W
W _ _ _ W _ W W _ W W W W W W _ _ o o W
W _ = _ _ = _ _ _ _ _ _ _ _ _ _ _ o o W
W W W W W _ W W W _ W _ W W W _ _ o o W
W W W W W _ _ _ _ _ W W W W W W W W W W
W W W W W W W W W W W W W W W W W W W W
W W W W W W W W W W W W W W W W W W W W
W W W W W W W W W W W W W W W W W W W W
W W W W W W W W W W W W W W W W W W W W
W W W W W W W W W W W W W W W W W W W W
W W W W W W W W W W W W W W W W W W W W
W W W W W W W W W W W W W W W W W W W W
W W W W W W W W W W W W W W W W W W W W
W W W W W W W W W W W W W W W W W W W W )

#И зададим начальные координаты грузчика
x=9
y=11
#За одно на всякий случай очистим переменную B, в которую будем сохранять ввод с клавиатуры
B=""

#установим счетчик цикла (а за одно размер игровой карты)
LIMIT=20

#Очистим экран
echo -en "\E[2J"

#И перейдем к главному циклу
while ( [ "$B" != "q" ] ) do

#Выведем карту на экран
for (( mx=1 ; mx<LIMIT; mx++ )) do
for (( my=1 ; my<LIMIT; my++ )) do
r=$(($mx*20+$my)) #у нас нет двумерных массивов, поэтому обойдемся одномерным
echo -en "\E[${mx};${my}f${map[${r}]}"
done
done

#За одно выведем всякую полезную информацию
echo -en "\E[22;2fWASD - move, Q - quit"
echo -en "\E[23;2fW - wall, X - hero, = and @ - chest, o - place for chest"
#И наконец - героя (чтобы курсор моргал в том месте, где он стоит)
echo -en "\E[${x};${y}fX\E[${x};${y}f" 

#Теперь очистим переменную для ввода с клавиатуры
B=""
#И прочитаем один символ
read -s -t 1 -n 1 B

#Сбросим переменные, в которые будем сохранять относительное перемещение грузчика
nx=0
ny=0

#Пришло время узнать, в какую сторону пользователь хочет переместить грузчика
case "$B" in
  [wW]   )  nx=$(( - 1));;
  [sS]   )  nx=$(( 1));;
  [aA]   )  ny=$(( - 1));;
  [dD]   )  ny=$(( 1));;
#На случай, если у кого-то нажат CAPS LOCK
  [qQ]   )  B="q";; 
esac

#Найдем координату клетки, на которую грузчик хочет перейти
r=$(( ($x + $nx) * $LIMIT + $y + $ny ))
#И сразу - следующую за ней
r2=$(( ($x + $nx + $nx) * $LIMIT + $y + $ny +$ny ))

#Если в этой клетке пусто, то
if [[ "${map[${r}]}" = "_" ]]
then
#Можно смело менять координаты
x=$(( $x + $nx ))
y=$(( $y + $ny ))
fi

#По местам для сундуков тоже можно ходить
if [[ "${map[${r}]}" = "o" ]] 
then
x=$(( $x + $nx ))
y=$(( $y + $ny ))
fi

#Ага, а что если ящик?
if [[ "${map[${r}]}" = "=" ]] 
then
#Если за ящиком пусто, то можно двигать
if [[ "${map[${r2}]}" = "_" ]] 
then
map[${r2}]="="
map[${r}]="_"
x=$(( $x + $nx ))
y=$(( $y + $ny ))
fi
#Если место для ящика свободно - тоже можно двигать
if [[ "${map[${r2}]}" = "o" ]] 
then
map[${r2}]="@"
map[${r}]="_"
x=$(( $x + $nx ))
y=$(( $y + $ny ))
fi
fi

#Столкнулись с ящиком, который стоит на месте
if [[ "${map[${r}]}" = "@" ]] 
then
#Если за ним пусто - значит, сдвинем ящик
if [[ "${map[${r2}]}" = "_" ]] 
then
map[${r2}]="="
map[${r}]="o"
x=$(( $x + $nx ))
y=$(( $y + $ny ))
fi
#Если за ним другое место - то тоже сдвинем
if [[ "${map[${r2}]}" = "o" ]] 
then
map[${r2}]="@"
map[${r}]="o"
x=$(( $x + $nx ))
y=$(( $y + $ny ))
fi
fi

#Возвращаемся к выводу на экран и опросу клавиатуры
done       
                    
#Пользователь нажал на Q - пора очистить экран от строительного мусора
echo -en "\E[2J"