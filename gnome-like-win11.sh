#!/bin/bash

   ################################################################
   #                                                               #
   #                 GNOME WIN11 Layout               		   #
   #           Copyright (C) 2023 Terry Bardell Jr.                #
   #       Licensed under the GNU General Public License 3.0       #
   #                                                               #
   #               						   #
   #                                                               #
   #################################################################


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
declare -a EXT_WIN11=('aztaskbar@aztaskbar.gitlab.com' 'appindicatorsupport@rgcjonas.gmail.com' 'arcmenu@arcmenu.com' 'blur-my-shell@aunetx' 'date-menu-formatter@marcinjakubowski.github.com' 'ding@rastersoft.com' 'just-perfection-desktop@just-perfection' 'mediacontrols@cliffniff.github.com' 'user-theme@gnome-shell-extensions.gcampax.github.com')
declare -a arr=( "${EXT_WIN11[@]}" )

#Disable all current extensions
gsettings set org.gnome.shell enabled-extensions []

#install all extensions from array
for EXT_UUID in "${arr[@]}"
do
	# if installed, skip
	if [[ " ${dirs[*]} " == *" $EXT_UUID "* ]]; then
		echo "Extension ${EXT_UUID} is already installed. Skipping."
	else
		TMP_ZIP=$(mktemp -t ext-XXXXXXXX.zip)

		JSON="${GNOME_SITE}/extension-info/?uuid=${EXT_UUID}&shell_version=${GNOME_VERSION}"
		EXTENSION_URL=${GNOME_SITE}$(curl -s "${JSON}" | sed -e 's/^.*download_url[\": ]*\([^\"]*\).*$/\1/') 

		# download extension archive
		if [[ ${EXT_UUID} == "mediacontrols@cliffniff.github.com" ]]; then #For Global Menu use GitHub instead
			EXTENSION_URL="https://github.com/cliffniff/media-controls/releases/download/v24/extension.zip"	
			wget --header='Accept-Encoding:none' -O "${TMP_ZIP}" "${EXTENSION_URL}"		
			# unzip extension to installation folder
			mkdir -p "${EXTENSION_PATH}"/"${EXT_UUID}"
			unzip -o "${TMP_ZIP}" -d /tmp/
			cp -R "/tmp/." -d "${EXTENSION_PATH}"/"${EXT_UUID}"
			chmod +r "${EXTENSION_PATH}"/"${EXT_UUID}"/*
			glib-compile-schemas "${EXTENSION_PATH}"/"${EXT_UUID}"/"schemas"
		elif [[ ${EXT_UUID} == "pixel-saver@deadalnix.me" ]]; then #For Pixel Saver use GitHub instead
			EXTENSION_URL="https://github.com/bill-mavromatis/pixel-saver/archive/master.zip"	
			wget --header='Accept-Encoding:none' -O "${TMP_ZIP}" "${EXTENSION_URL}"		
			# unzip extension to installation folder
			mkdir -p "${EXTENSION_PATH}"/"${EXT_UUID}"
			unzip -o "${TMP_ZIP}" -d /tmp/
			cp -R "/tmp/pixel-saver-master/pixel-saver@deadalnix.me/" -d "${EXTENSION_PATH}"
			chmod +r "${EXTENSION_PATH}"/"${EXT_UUID}"/*
		else    #for everything else use GNOME site
			wget --header='Accept-Encoding:none' -O "${TMP_ZIP}" "${EXTENSION_URL}"		
			# unzip extension to installation folder
			mkdir -p "${EXTENSION_PATH}"/"${EXT_UUID}"
			unzip -oq "${TMP_ZIP}" -d "${EXTENSION_PATH}"/"${EXT_UUID}"
			chmod +r "${EXTENSION_PATH}"/"${EXT_UUID}"/*
		fi

	fi
	rm -f "${TMP_ZIP}" #remove temp files
done

# Get Icon Theme
git clone https://github.com/yeyushengfan258/Win11-icon-theme.git
cd Win11-icon-theme
./install.sh
cd ..

# Get GTK Theme
git clone https://github.com/vinceliuice/Fluent-gtk-theme.git
cd Fluent-gtk-theme
./install.sh
cd ..

#Move schema files to local dir and compile
[[ -e ~/.local/share/glib-2.0/schemas/ ]] || mkdir -p ~/.local/share/glib-2.0/schemas/
export XDG_DATA_DIRS=~/.local/share:/usr/share
find ~/.local/share/gnome-shell/extensions/ -name *gschema.xml -exec ln {} -sfn ~/.local/share/glib-2.0/schemas/ \;
glib-compile-schemas ~/.local/share/glib-2.0/schemas/

#enable extensions
gsettings set org.gnome.shell enabled-extensions "['aztaskbar@aztaskbar.gitlab.com', 'appindicatorsupport@rgcjonas.gmail.com', 'arcmenu@arcmenu.com', 'blur-my-shell@aunetx', 'date-menu-formatter@marcinjakubowski.github.com', 'ding@rastersoft.com', 'just-perfection-desktop@just-perfection', 'mediacontrols@cliffniff.github.com', 'user-theme@gnome-shell-extensions.gcampax.github.com']"

#set wallpaper
if [[ ! -f "$PICTURES_FOLDER"/wallpaper-windows.png ]]; then 
wget https://4kwallpapers.com/images/wallpapers/windows-11-dark-mode-blue-stock-official-3840x2400-5630.jpg
mv windows-11-dark-mode-blue-stock-official-3840x2400-5630.jpg "$PICTURES_FOLDER"/wallpaper-windows.png
fi
gsettings set org.gnome.desktop.background picture-uri file:///"$PICTURES_FOLDER"/wallpaper-windows.png

#change theme and settings
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

read -p "Press enter to restart Gnome"
killall -3 gnome-shell
	

    
 
  
  
