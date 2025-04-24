#!/bin/sh
# Copyright (C) 2025 stemsee
#
if [[ $(id -u) -ne 0 ]]; then
	[[ "$DISPLAY" ]] && exec gtksu "hashtext" "$0" "$@" || exec su -c "$0 $*"
fi
mkfifo /tmp/piper
exec 4<>/tmp/piper
mkfifo /tmp/viewer
exec 5<>/tmp/viewer
export ACTIONCMND='bash -c "savefn %1"'
export DELCMND='bash -c "deletefn"'
function viewfn {
echo -e '\f' >/tmp/piper
ls /usr/share/locale/hashtext/"$1"/* | while read line; do printf "%s\n" "$line" >/tmp/piper;done
echo "$1" > /tmp/lang
}; export -f viewfn
function savefn {
file=$(cat /tmp/selection)
HANDLE=$(echo $file | rev | cut -f1 -d'/' | rev | cut -f1 -d'.')
TRANDLE=$(cat $file | md5sum | cut -f1 -d' ')
BANDLE=$(echo "${HANDLE}${TRANDLE}" | md5sum | cut -f1 -d' ')
way=$(echo "$file" | rev | cut -c42- | rev)
sed -i "s/$BANDLE//" ${way}register
echo -e "$1" > "$file"
HANDLE=$(echo $1 | rev | cut -f1 -d'/' | rev | cut -f1 -d'.')
TRANDLE=$(cat $1 | md5sum | cut -f1 -d' ')
BANDLE=$(echo "${HANDLE}${TRANDLE}" | md5sum | cut -f1 -d' ')
echo "${BANDLE}" >> register
}; export -f savefn
function setupfn {
	echo -e '\f' >/tmp/viewer
	T_TEXT=$(cat "$1")
	echo -e '\f' >/tmp/viewer
	A_TEXT=$(while read -r line; do printf "%s" "$line\n"; done <<< $(printf "%q" "$T_TEXT" | sed -e "s/'$//" -e "s/^$'//"))
	printf "%s\n%s\n%s\n" "$A_TEXT" "$ACTIONCMND" "$DELCMND" >>/tmp/viewer
	echo "$1" > /tmp/selection
}; export -f setupfn
function deletefn {
	rm -f $(cat /tmp/selection)
	viewfn $(cat /tmp/lang)
}; export -f deletefn
yad --plug=$$ --tabnum=1 --list --editable --column=list --print-column=1 --select-action="bash -c \"setupfn "%s" \"" <&4 &
yad --plug=$$ --tabnum=2 --formatted --cycle-read --wrap --scroll --form --field=:txt --field="save:fbtn" --field="delete:fbtn" <&5 &
yad --title="hashtext editor" --geometry=989x803-0+1 --paned --orient=hor --splitter=600 --width=800 --height=800 --key=$$ --tab=list --tab=viewer --on-top --no-buttons &
ls /usr/share/locale/hashtext | yad --list --geometry=193x800+730+5 --column=language --select-action="bash -c \"viewfn "%s" \"" --no-buttons &
