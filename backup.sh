#!/bin/bash

# Резервное архивирование (backup) всех файлов в текущем каталоге,
# которые были изменены в течение последних 24 часов
#+ в тарболл (tarball) (.tar.gz - файл).

BACKUPFILE=backup
archive=${1:-$BACKUPFILE}
#  На случай, если имя архива в командной строке не задано,
#+ т.е. по-умолчанию имя архива -- "backup.tar.gz"

tar cvf - `find . -mtime -1 -type f -print` > $archive.tar
gzip $archive.tar
echo "Каталог $PWD заархивирован в файл \"$archive.tar.gz\"."


#  Stephane Chazelas заметил, что вышеприведенный код будет "падать"
#+ если будет найдено слишком много файлов
#+ или если имена файлов будут содержать символы пробела.

# Им предложен альтернативный код:
# -------------------------------------------------------------------
  find . -mtime -1 -type f -print0 | xargs -0 tar rvf "$archive.tar"
#      используется версия GNU утилиты "find".


   find . -mtime -1 -type f -exec tar rvf "$archive.tar" '{}' \;
#         более универсальный вариант, хотя и более медленный,
#         зато может использоваться в других версиях UNIX.
# -------------------------------------------------------------------


exit 0