#!/bin/env bash

# Helper functions to display the date in Spanish

function get_day() {
        declare -A days=(
                [Mon]="lun"
                [Tue]="mar"
                [Wed]="mié"
                [Thu]="jue"
                [Fri]="vie"
                [Sat]="sáb"
                [Sun]="dom"
        )

        last_login_day=$(last | head -1 | tr -s " " | cut -f5 -d " ")
	
	echo ${days[$last_login_day]}	
}

function get_month() {
	declare -A months=(
	        [Jan]="ene"
        	[Feb]="feb"
        	[Mar]="mar"
	        [Apr]="abr"
	        [May]="may"
	        [Jun]="jun"
	        [Jul]="jul"
        	[Aug]="ago"
	        [Sep]="sep"
        	[Oct]="oct"
        	[Nov]="nov"
        	[Dec]="dic"
	)

        last_login_month=$(last | head -1 | tr -s " " | cut -f6 -d " ")
	
	echo ${months[$last_login_month]}
}

function get_date() {
	echo $(last | head -1 | tr -s " " | cut -f7,8 -d " ")
}

function get_uptime() {
	declare -A time=(
        	[minutes]="minutos"
        	[hours]="horas"
		[days]="días"
		[weeks]="semanas"
	)

	uptime=$(uptime -p | awk 'gsub("up", "", $1); print $0}')

	# TODO: Finish this function	
}

# CMDs
lastlogin="$(get_day) $(get_month) $(get_date)"
uptime="`uptime -p | sed -e 's/up //g'`"
host=`hostnamectl hostname`

# Options
hibernate=''
shutdown='⏻'
reboot=''
lock=''
suspend=''
logout=''
yes=''
no=''

# Rofi CMD
rofi_cmd() {
	rofi -dmenu \
		-p " $USER@$host" \
		-mesg " Último Login: $lastlogin |  Uptime: $uptime" \
		-theme $HOME/.config/rofi/powermenu/config.rasi
}

# Confirmation CMD
confirm_cmd() {
	rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
		-theme-str 'mainbox {children: [ "message", "listview" ];}' \
		-theme-str 'listview {columns: 2; lines: 1;}' \
		-theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
		-dmenu \
		-p 'Confirmation' \
		-mesg '¿Estás seguro?' \
		-theme $HOME/.config/rofi/powermenu/config.rasi
}

# Ask for confirmation
confirm_exit() {
	echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$lock\n$suspend\n$logout\n$hibernate\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
	selected="$(confirm_exit)"
	if [[ "$selected" == "$yes" ]]; then
		if [[ $1 == '--shutdown' ]]; then
			systemctl poweroff
		elif [[ $1 == '--reboot' ]]; then
			systemctl reboot
		elif [[ $1 == '--hibernate' ]]; then
			systemctl hibernate
		elif [[ $1 == '--suspend' ]]; then
			mpc -q pause
			amixer set Master mute
			systemctl suspend
		elif [[ $1 == '--logout' ]]; then
			bspc quit
		fi
	else
		exit 0
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
		run_cmd --shutdown
        ;;
    $reboot)
		run_cmd --reboot
        ;;
    $hibernate)
		run_cmd --hibernate
        ;;
    $lock)
		if [[ -x '/usr/bin/betterlockscreen' ]]; then
			betterlockscreen -l
		fi
        ;;
    $suspend)
		run_cmd --suspend
        ;;
    $logout)
		run_cmd --logout
        ;;
esac
