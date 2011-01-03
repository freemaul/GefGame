#!/bin/bash
#
#    This file is part of GefGame.
#
#    GefGame is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Lesser General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    GefGame is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Lesser General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public License
#    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
#

display_types()
{
	echo "c:template.c"
	echo "cpp:template.cpp"
	echo "h:template.h"
	echo "hpp:template.hpp"
	echo "bash:template.sh"
	echo "make:template.mk"
}

display_help()
{
	echo -e "Syntax :"
	echo -e "\tnew_file.sh [file_name] [file_type]"
	echo -e "File types :"

	for temp in `display_types`; do
		type=`echo $temp | cut -f1 -d:`
		file_template=`echo $temp | cut -f2 -d:`
		echo -e "\t$type\tuse\t$file_template"
	done
}

create_file()
{
	file_name_without_ext=${1%"."*}
	file_name_without_ext=${file_name_without_ext##*"/"}

	file_content=`cat -A $2 | tr "\r\n" "!"`
	file_content=${file_content//"<FILE>"/"$file_name_without_ext"}
	file_content=${file_content//"<NAME>"/"GefGame"}
	file_content=${file_content//"\$!"/"\n"}
	file_content=${file_content//"^I"/"\t"}

	echo -e "$file_content" > ./$1
}

file_name=$1
file_type=$2

if [[ $file_name == "" ]]; then
	display_help
	exit 1
fi

if [[ $file_type == "" ]]; then
	display_help
	exit 1
fi

for temp in `display_types`; do
	type=`echo $temp | cut -f1 -d:`
	file_template=`echo $temp | cut -f2 -d:`
	if [[ $file_type == $type ]]; then
		create_file $file_name $GEFGAME/template/$file_template
		exit 0;
	fi
done

