#!/bin/bash

   #################################################################
   #                                                               #
   #                 GNOME WIN11 Layout               		   #
   #           Copyright (C) 2023 Terry Bardell Jr.                #
   #       Licensed under the GNU General Public License 3.0       #
   #                                                               #
   #       https://github.com/tlbardelljr/gnome-like-win11	   #
   #                                                               #
   #################################################################
   
my_options=(   	"aztaskbar@aztaskbar.gitlab.com" 
		"appindicatorsupport@rgcjonas.gmail.com" 
		"arcmenu@arcmenu.com" 
		"blur-my-shell@aunetx" 
		"date-menu-formatter@marcinjakubowski.github.com" 
		"ding@rastersoft.com" 
		"just-perfection-desktop@just-perfection" 
		"mediacontrols@cliffniff.github.com" 
		"user-theme@gnome-shell-extensions.gcampax.github.com"  
		"Win11-icon-theme"
		"Fluent-gtk-theme"
		"settings"
		"wallpaper-windows"
		
	   )
preselection=( 	"true"
		"true"
		"true"
		"true"
		"true"
		"true"
		"true"
		"true"
		"true"
		"true"
		"true"
		"true"
		"true"
	      )
installer_name="tlbardelljr Gnome like win11"
sdoutColor=250
progressBarColorFG=226
progressBarColorBG=242
headerColorFG=255
headerColorBG=242

export terminal=$(tty)

# Check tools availability (curl,git)
command -v curl >/dev/null 2>&1 || {
    echo "Please install curl!"
    echo "command: sudo apt install -y curl"
    exit 1;
}
command -v git >/dev/null 2>&1 || {
     echo "Please install git!"
     echo "command: sudo apt install -y git"
    exit 1;
}

# Set Variables
GNOME_SITE="https://extensions.gnome.org"
GNOME_VERSION="$(DISPLAY=":0" gnome-shell --version | tr -cd "0-9." | cut -d'.' -f1,2)"
EXTENSION_PATH="$HOME/.local/share/gnome-shell/extensions"
PICTURES_FOLDER=$(xdg-user-dir PICTURES)
dirs=( $(find /usr/share/gnome-shell/extensions $HOME/.local/share/gnome-shell/extensions -maxdepth 1 -type d -printf '%P\n') )
declare -A installed_ext
 
#Disable all current extensions
gsettings set org.gnome.shell enabled-extensions []

parse_array () {
	if [[ ${1} == "settings" ]]; then #For Global Menu use GitHub instead
		settings $1
		
	elif [[ ${1} == "Win11-icon-theme" ]]; then
		# Get Icon Theme
		git clone https://github.com/yeyushengfan258/Win11-icon-theme.git
		cd Win11-icon-theme
		./install.sh
		cd ..
		rm -rf Win11-icon-theme
	elif [[ ${1} == "Fluent-gtk-theme" ]]; then
		# Get GTK Theme
		git clone https://github.com/vinceliuice/Fluent-gtk-theme.git
		cd Fluent-gtk-theme
		./install.sh
		cd ..
		rm -rf Fluent-gtk-theme
	elif [[ ${1} == "wallpaper-windows" ]]; then
		#set wallpaper
		if [[ ! -f "$PICTURES_FOLDER"/wallpaper-windows.png ]]; then 
			wget https://raw.githubusercontent.com/tlbardelljr/gnome-like-win11/main/images/wallpaper.png
			mv wallpaper.png "$PICTURES_FOLDER"/wallpaper-windows.png
		fi
		gsettings set org.gnome.desktop.background picture-uri file:///"$PICTURES_FOLDER"/wallpaper-windows.png
		
	else    #for everything else use GNOME site
		install_ext $1
		
	fi

}
 
install_ext () {
	
	# if installed, skip
	if [[ " ${dirs[*]} " == *" $1 "* ]]; then
		echo "Extension ${1} is already installed. Skipping."
	else
		TMP_ZIP=$(mktemp -t ext-XXXXXXXX.zip)

		JSON="${GNOME_SITE}/extension-info/?uuid=${1}&shell_version=${GNOME_VERSION}"
		EXTENSION_URL=${GNOME_SITE}$(curl -s "${JSON}" | sed -e 's/^.*download_url[\": ]*\([^\"]*\).*$/\1/') 

		# download extension archive
		
		#for everything else use GNOME site
		wget --header='Accept-Encoding:none' -O "${TMP_ZIP}" "${EXTENSION_URL}"		
		# unzip extension to installation folder
		mkdir -p "${EXTENSION_PATH}"/"${1}"
		unzip -oq "${TMP_ZIP}" -d "${EXTENSION_PATH}"/"${1}"
		chmod +r "${EXTENSION_PATH}"/"${1}"/*
		

	fi
	rm -f "${TMP_ZIP}" #remove temp files
	
	#Move schema files to local dir and compile
	[[ -e ~/.local/share/glib-2.0/schemas/ ]] || mkdir -p ~/.local/share/glib-2.0/schemas/
	export XDG_DATA_DIRS=~/.local/share:/usr/share
	find ~/.local/share/gnome-shell/extensions/ -name *gschema.xml -exec ln {} -sfn ~/.local/share/glib-2.0/schemas/ \;
	glib-compile-schemas ~/.local/share/glib-2.0/schemas/
	
	
	
}

settings () {
#change theme and settings

	#joined=$(printf ",'%s'" "${my_options[@]}")
	joined=$(printf ",'%s'" "${installed_ext[@]}")
	gsettings set org.gnome.shell enabled-extensions '['${joined:1}']';
	
	gsettings set org.gnome.desktop.interface icon-theme "Win11"
	gsettings set org.gnome.desktop.interface gtk-theme "Fluent-Light"
	gsettings set org.gnome.shell.extensions.user-theme name "Fluent-Dark"
	gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'

	gsettings set org.gnome.shell.extensions.ding icon-size "'small'"
	gsettings set org.gnome.shell.extensions.ding show-trash "true"
	gsettings set org.gnome.shell.extensions.ding show-volumes "false"
	gsettings set org.gnome.shell.extensions.ding start-corner "'top-left'"
	gsettings set org.gnome.shell.extensions.ding arrangeorder "'KIND'"
	gsettings set org.gnome.shell.extensions.ding keep-arranged "true"

	gsettings set org.gnome.shell.extensions.arcmenu alphabetize-all-programs "false"
	gsettings set org.gnome.shell.extensions.arcmenu button-padding "5"
	gsettings set org.gnome.shell.extensions.arcmenu custom-menu-button-icon-size "33.0"
	gsettings set org.gnome.shell.extensions.arcmenu force-menu-location "'BottomCentered'"
	gsettings set org.gnome.shell.extensions.arcmenu menu-height "750"
	gsettings set org.gnome.shell.extensions.arcmenu left-panel-width "175"
	gsettings set org.gnome.shell.extensions.arcmenu menu-item-icon-size "'Large'"
	gsettings set org.gnome.shell.extensions.arcmenu menu-layout "'Eleven'"
	gsettings set org.gnome.shell.extensions.arcmenu position-in-panel "'Center'"

	gsettings set org.gnome.shell.extensions.blur-my-shell.panel brightness "1.0"
	gsettings set org.gnome.shell.extensions.blur-my-shell.panel override-background "false"
	gsettings set org.gnome.shell.extensions.blur-my-shell.panel sigma "10"

	gsettings set org.gnome.shell.extensions.date-menu-formatter pattern "'MM/dd/yy\\nhh : mm aa'"

	gsettings set org.gnome.shell.extensions.aztaskbar panel-location "'BOTTOM'"
	gsettings set org.gnome.shell.extensions.aztaskbar position-in-panel "'CENTER'"
	gsettings set org.gnome.shell.extensions.aztaskbar icon-size "33"
	gsettings set org.gnome.shell.extensions.aztaskbar indicator-location "'BOTTOM'"
	gsettings set org.gnome.shell.extensions.aztaskbar main-panel-height "(true, 44)"

	gsettings set org.gnome.shell.extensions.just-perfection app-menu "false"
	gsettings set org.gnome.shell.extensions.just-perfection clock-menu-position "1"
	gsettings set org.gnome.shell.extensions.just-perfection clock-menu-position-offset "10"
	gsettings set org.gnome.shell.extensions.just-perfection power-icon "false"
	gsettings set org.gnome.shell.extensions.just-perfection startup-status "0"
	gsettings set org.gnome.shell.extensions.just-perfection top-panel-position "1"

	gsettings set org.gnome.shell.extensions.mediacontrols colored-player-icon "true"
	gsettings set org.gnome.shell.extensions.mediacontrols extension-position "'right'"
	gsettings set org.gnome.shell.extensions.mediacontrols mouse-actions "['toggle_info', 'none', 'none', 'none', 'none', 'none', 'none', 'none']"
	gsettings set org.gnome.shell.extensions.mediacontrols show-control-icons "false"
	gsettings set org.gnome.shell.extensions.mediacontrols show-sources-menu "false"
	gsettings set org.gnome.shell.extensions.mediacontrols show-text "false"

	gsettings set org.gnome.shell disabled-extensions "['ubuntu-dock@ubuntu.com']"

	
}


install_app () {
	 
   	tput setaf $sdoutColor
      	tput csr 8 $(($(tput lines) - 5))
    	tput cup 8 0
    	parse_array $1 & progress_bar $!;
	tput sgr0
	
}

function progress_bar() { 
	pid=$1
 	((progress=1))
	while [ -e /proc/$pid ]; do
		kill -s STOP $pid > /dev/null 2>&1
		tput sc
	    	Rows=$(tput lines)
	    	Cols=$(tput cols)-2
	   	tput cup $(($Rows - 2)) 0
	    	((progress=progress+4))
	    	((remaining=${Cols}-${progress}))
	    	tput bold
	    	tput setaf $progressBarColorFG
	    	tput setab $progressBarColorBG
	    	echo -ne "[$(printf "%${progress}s" | tr " " "#")$(printf "%${remaining}s" | tr " " "-")]"
	    	tput cup $(($Rows - 1)) 0
      		tput sgr0
	    	tput ed
	    	if (( $progress > ($((Cols-4))) )); then
	   		((progress=1))
		fi
		tput rc
		sleep .5
		kill -s CONT $pid > /dev/null 2>&1
  		sleep 4
	done
}

function Header() { 
	tput bold
	tput setaf $headerColorFG
	tput setab $headerColorBG
	((ESpace=$(tput cols)-(${#installer_name})))
    	((LSide=((${ESpace}/2))-2))
    	((RSide=$(tput cols)-(${#installer_name})-${LSide}-4))
    	tput cup 0 0
    	echo -ne "[$(printf "%${LSide}s" | tr " " " ") $(printf "$installer_name") $(printf "%${RSide}s" | tr " " " ")]"
    	tput sgr0
    	echo -e ' '
}
function multiselect {
    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()   { printf "$ESC[?25h"; }
    cursor_blink_off()  { printf "$ESC[?25l"; }
    cursor_to()         { printf "$ESC[$1;${2:-1}H"; }
    print_inactive()    { printf "$2   $1 "; }
    print_active()      { printf "$2  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()    { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }

    local return_value=$1
    local -n options=$2
    local -n defaults=$3

    local selected=()
    for ((i=0; i<${#options[@]}; i++)); do
        if [[ ${defaults[i]} = "true" ]]; then
            selected+=("true")
        else
            selected+=("false")
        fi
        printf "\n"
    done

    # determine current screen position for overwriting the options
    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - ${#options[@]}))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    key_input() {
        local key
        IFS= read -rsn1 key 2>/dev/null >&2
        if [[ $key = ""      ]]; then echo enter; fi;
        if [[ $key = $'\x20' ]]; then echo space; fi;
        if [[ $key = "k" ]]; then echo up; fi;
        if [[ $key = "j" ]]; then echo down; fi;
        if [[ $key = $'\x1b' ]]; then
            read -rsn2 key
            if [[ $key = [A || $key = k ]]; then echo up;    fi;
            if [[ $key = [B || $key = j ]]; then echo down;  fi;
        fi 
    }

    toggle_option() {
        local option=$1
        if [[ ${selected[option]} == true ]]; then
            selected[option]=false
        else
            selected[option]=true
        fi
    }

    print_options() {
        # print options by overwriting the last lines
        
        local idx=0
        for option in "${options[@]}"; do
            local prefix="[ ]"
            if [[ ${selected[idx]} == true ]]; then
              prefix="[\e[38;5;46m✔\e[0m]"
            fi

            cursor_to $(($startrow + $idx))
            if [ $idx -eq $1 ]; then
                print_active "$option" "$prefix"
            else
                print_inactive "$option" "$prefix"
            fi
            ((idx++))
        done
       
    	echo -e '\n'
	echo -e '\nPress enter when done with selections'
    }

    local active=0
    while true; do
        print_options $active

        # user key control
        case `key_input` in
            space)  toggle_option $active;;
            enter)  print_options -1; break;;
            up)     ((active--));
                    if [ $active -lt 0 ]; then active=$((${#options[@]} - 1)); fi;;
            down)   ((active++));
                    if [ $active -ge ${#options[@]} ]; then active=0; fi;;
        esac
    done
    
    # cursor position back to normal
    cursor_to $lastrow
    printf "\n"
    printf "\n"
    printf "\n"
    cursor_blink_on

    eval $return_value='("${selected[@]}")'
}

clear
TRows=$(tput lines)
TCols=$(tput cols)
if (( "80" > ${TCols} )); then
   	clear
   	Header
	echo -e ' '
      	echo "Terminal not wide enough ($TCols - columns)"
      	echo "Need 80 columns. Make terminal wider."
      	exit
fi
if (( "23" > ${TRows} )); then
   	clear
   	Header
	echo -e ' '
      	echo "Terminal not tall enough ($TRows - rows)"
      	echo "Need 23 rows. Make terminal taller."
      	exit
fi

clear
Header
echo -e '\nArrow up/down space bar to select'
echo -e ' '
multiselect result my_options preselection

idx=0
for option in "${my_options[@]}"; do
   if [ "true" = "${result[idx]}" ]; then
   	clear
   	Header
	echo -e ' '
	echo "Installing.. $option"
      	install_app $option
      	echo -e ' '
      	tput sgr0
      	echo "Finished option.. $option"
      	installed_ext[$idx]="$option"
      	
      	
   fi
    ((idx++))
done
clear
echo "Thank you for using $installer_name"
read -p "Press enter to restart Gnome"
rm gnome-like-win11.sh
killall -3 gnome-shell
