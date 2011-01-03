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


display_source()
{
	echo "GefGameLib"
	echo "Cross"
}

source_cmd()
{
	case $source in
		GefGameLib )
			echo "not yet";;
		Cross )
			cd cross/FromLinux
			./make_cross.sh $cible
			cd ../../;;
	esac
}

display_cible()
{
	$GEFGAME/cross/FromLinux/target.sh
}

display_help()
{
	echo -e "Syntax"
	echo -e "\tlinux.sh [source] [cible]"
	echo -e "Sources :"
	for temp in `display_source`; do
		echo -e "\t$temp" | cut -f1 -d:
	done
	echo -e "Cibles :"
	for temp in `display_cible`; do
		echo -e "\t$temp" | cut -f1 -d:
	done
}


if [[ $GEFGAME == "" ]]; then
	source ./scr/to_source.sh
fi

source=$1
cible=$2

if [[ $source == "" ]]; then
	display_help
	exit 1
fi

if [[ $cible == "" ]]; then
	display_help
	exit 1
fi

flag=0
for temp in `display_source`; do
	temp_source=`echo $temp | cut -f1 -d:`
	if [[ $temp_source == $source ]]; then
		flag=1
	fi
done
if [[ $flag == 0 ]]; then
	echo "$source source inconnue"
	display_help
	exit 1
fi

flag=0
for temp in `display_cible`; do
	temp_cible=`echo $temp | cut -f1 -d:`
	if [[ $temp_cible == $cible ]]; then
		flag=1
	fi
done
if [[ $flag == 0 ]]; then
	echo "$cible cible inconnue"
	display_help
	exit 1
fi

source_cmd


