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

#repertoire de GEFGAME
export GEFGAME=$PWD

#PATH pour scripts GEFGAME
export PATH=$PATH:$GEFGAME/scr

#PATH pour cross-compilateurs
for temp in `$GEFGAME/cross/FromLinux/target.sh`; do
	cible=`echo "$temp" | cut -f1 -d:`
	export PATH=$PATH:$GEFGAME/cross/FromLinux/$cible/bin
done


