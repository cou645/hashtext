#!/bin/sh
# Copyright (C) 2025 stemsee
#

if [[ $(id -u) -ne 0 ]]; then
	[[ "$DISPLAY" ]] && exec gtksu "hashtext" "$0" "$@" || exec su -c "$0 $*"
fi
export FONTNAME="sans Italic 24"
export LANGUAGES=" Afrikaans - af! Albanian - sq! Amharic - am! Arabic - ar! Armenian - hy! Azerbaijani - az! Basque - eu! Belarusian - be! Bengali - bn! Bosnian - bs! Bulgarian - bg! Cantonese - yue! Catalan - ca! Cebuano - ceb! Chichewa - ny! ChineseSimple - zh-CN! ChineseTrad - zh-TW! Corsican - co! Croatian - hr! Czech - cs! Danish - da! Dutch - nl! English - en! Esperanto - eo! Estonian - et! Fijian - fj! Filipino - tl! Finnish - fi! French - fr! Frisian - fy! Galician - gl! Georgian - ka! German - de! Greek - el! Gujarati - gu! Haitian-Creole - ht! Hausa - ha! Hawaiian - haw! Hebrew - he! Hindi - hi! Hmong - hmn! Hmong-Daw - mww! Hungarian - hu! Icelandic - is! Igbo - ig! Indonesian - id! Irish - ga! Italian - it! Japanese - ja! Javanese - jv! Kannada - kn! Kazakh - kk! Khmer - km! Klingon - tlh! Korean - ko! Kurdish - ku! Kyrgyz - ky! Lao - lo! Latin - la! Latvian - lv! Lithuanian - lt! Luxembourgish - lb! Macedonian - mk! Malagasy - mg! Malay - ms! Malayalam - ml! Maltese - mt! Maori - mi! Marathi - mr! Mongolian - mn! Myanmar - my! Nepali - ne! Norwegian - no! Pashto - ps! Persian - fa! Polish - pl! Portuguese - pt! Punjabi - pa! Queretaro-Otomi - otq! Roman - rm! Romanian - ro! Russian - ru! Samoan - sm! Scots-Gaelic - gd! SerbianCyr - sr-Cyrl! SerbianLatin - sr-Latn! Sesotho - st! Shona - sn! Sindhi - sd! Sinhala - si! Slovak - sk! Slovenian - sl! Somali - so! Spanish - es! Sundanese - su! Swahili - sw! Swedish - sv! Tahitian - ty! Tajik - tg! Tamil - ta! Tatar - tt! Telugu - te! Thai - th! Tongan - to! Turkish - tr! Udmurt - udm! Ukrainian - uk! Urdu - ur! Uzbek - uz! Vietnamese - vi! Welsh - cy! Xhosa - xh! Yiddish - yi! Yoruba - yo! Yucatec-Maya - yua! Zulu - zu"

case "$1" in
'5269') yad --form --item-separator='!' --field="Select Language":cb "$LANGUAGES" --fontname="$FONTNAME" | sed -E -e 's/\|//g' | awk '{print $NF}'  > "$track"/lng
export lng=$(cat "$track"/lng)
 yad --form --item-separator=',' --field="Enter Translation Engine - bing or google":cb "bing,google" --fontname="$FONTNAME"  | sed -E -e 's/\|//g' > "$track"/engine
export ENGINE=$(cat "$track"/engine)
exit;;
esac

[ ! -e /bin/gettext ] && ln -s /bin/hashtext /bin/gettext

if [[ "$1" == 'live' && "$2" == 'live' && "$3" == 'live' ]]; then
	touch /tmp/hashtext-live
	exit
fi

if [[ "$1" == 'die' && "$2" == 'die' && "$3" == 'die' ]]; then
	rm -f /tmp/hashtext-live
	exit
fi

echo "$1" >>/tmp/hashtext.log

if [[ -z "$lng" ]]; then lng="$(echo $LANG | cut -f1 -d'_')";fi 
[[ "$ENGINE" != bing||google ]] && export ENGINE=bing
if [[ ! -d /usr/share/locale/hashtext/"$lng" ]]; then mkdir -p /usr/share/locale/hashtext/"$lng";fi
		
unset WORK
HANDLE=$(echo "$1" | md5sum | awk '{print $1}')

if [[ -f /tmp/hashtext-live ]]; then
	WORK=$(trans -b -e $ENGINE -tl "$lng" "$1")
	if [[ ! -z "$WORK" ]]; then
		echo "$WORK"
	fi
exit
fi
if [[ -f /usr/share/locale/hashtext/"$lng"/"${HANDLE}".hashtext ]]; then
		RETRIEVED=$(cat /usr/share/locale/hashtext/"$lng"/"${HANDLE}".hashtext)
		TRANDLE=$(echo "${RETRIEVED}" | md5sum | awk '{print $1}')
		BANDLE=$(echo "${HANDLE}${TRANDLE}" | md5sum | awk '{print $1}')
		OK=$(grep "${BANDLE}" /usr/share/locale/hashtext/"${lng}"/register)

		if [[ ! -z "$OK" ]]; then
		echo "$RETRIEVED" 
		else
		echo "$1"
		rm -f /usr/share/locale/hashtext/"$lng"/"${HANDLE}".hashtext
		fi
elif [[ ! -f /usr/share/locale/hashtext/"$lng"/"$HANDLE".hashtext ]]; then
			WORK=$(trans -b -e $ENGINE -tl "$lng" "$1")
			if [[ ! -z "$WORK" ]]; then
				echo "$WORK"			
				TRANDLE=$(echo "$WORK" | md5sum | awk '{print $1}')
				BANDLE=$(echo "${HANDLE}${TRANDLE}" | md5sum | awk '{print $1}')
				echo "${BANDLE}" >> /usr/share/locale/hashtext/"$lng"/register
				echo -e "$WORK" > /usr/share/locale/hashtext/"$lng"/"$HANDLE".hashtext
    			else
       				echo "$1"
			fi
fi
