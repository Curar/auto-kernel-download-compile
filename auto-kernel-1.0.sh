#!/bin/bash
# 
# By Curar 2020r.
#
# Skrypt który automatycznie pobiera i kompiluje źródło jądra ze strony 
# https://kernel.org przy użyciem programu curl, gpg.
# https://github.com/gpg/gnupg
# https://gnupg.org/
#
# Write using vim editor
# https://github.com/vim/vim
# https://www.vim.org/

clear
tablica_info["0"]="
==============================================================
Skrypt automatyzujący pobieranie kernela oraz jego kompilację
==============================================================
 https://kernel.org
 
Write using vim editor
 
 https://github.com/vim/vim
 https://www.vim.org/
==============================================================
"
tablica_logo["0"]="
==============================================================
     ...::: KERNEL AUTO DOWNLOAD'S AND COMPILATION :::...       
==============================================================
"
echo -e "\e[33m${tablica_info["0"]}\e[0m"
echo -e "\e[32m${tablica_logo["0"]}\e[0m"
echo -e "\e[33mDZIEŃ DOBRY\e[0m"
echo ""
read -p "Naduś ENTER"
clear

# Definicja zmiennych
function zmienne() {
numer=""
KERNEL_EXIST="linux-${KERNEL}.tar.xz"
KERNEL_SIGN="linux-${KERNEL}.tar.sign"
KERNEL_D="linux-${KERNEL}"
ADRES_KERNELA_PLIKI="https://cdn.kernel.org/pub/linux/kernel/v5.x/sha256sums.asc"
ADRES_KERNELA="https://cdn.kernel.org/pub/linux/kernel/v5.x/${wybor}"
}

# Definicja funkcji używanych w skrypcie
function curl_gpg_tar_exist() {
	if ! [ -x "$(command -v curl)" ]; then {
  		echo 'UWAGA curl nie jest zainstalowany !' >&2
		exit 1
    	}
	elif ! [ -x "$(command -v gpg)" ]; then {
		echo 'UWAGA gpg nie jest zainstalowane !' >&2
       		exit 1
    	}  
	elif ! [ -x "$(command -v tar)" ]; then {
		echo 'UWAGA tar nie jest zainstalowane !' >&2
		exit 1
	} fi
}

function pauza() {	
	read -p "Naduś klawisz ENTER aby kontynować ..."
}

function rdzenie() {
	RDZENIE=`getconf _NPROCESSORS_ONLN`
	if [ ! "$RDZENIE -le 4" ]
	then
		echo -e "\e[32mWykryłem ,że masz : $RDZENIE wątki, dostosuję skrypt automatycznie\e[0m"
		sleep 3
	else
		echo -e	"\e[32mWykryłem ,że masz : $RDZENIE wątków, dostosuję skrypt automatycznie\e[0m"
        sleep 3	
	fi
}


function archlinux {
	echo -e "\e[32m===========================================\e[0m"
	echo -e "\e[32m=  Wgrywam domyślną konfigurację kernela  =\e[0m"
	echo -e "\e[32m===========================================\e[0m"
	pwd
	sleep 3	
	make localmodconfig
	echo -e "\e[33mCzy wejść w opcje konfiguracyjne kernela (make menuconfig)\e[0m"
	read -r -p "Press Y or N" wybory	
		if [[ "$wybory" =~ ^([yY][eE][sS]|[yY])$ ]]; then {
		make menuconfig
		} else {
		echo -e "\e[33mKontynuuje z domyślną konfiguracją\e[0m"
		} fi
	make clean
	echo -e "\e[32m============================\e[0m"
	echo -e "\e[32m=  Rozpoczynam kompilację  =\e[0m"
	echo -e "\e[32m============================\e[0m"
	sleep 3	
	make -j $RDZENIE
	echo -e "\e[33mCo mam zrobić :\e[0m"
	opcje=("Wgraj kernela" "Wyjście")
	select opcja in "${opcje[@]}"
	do
		case $opcja in
			"Wgraj kernela")
				sudo make modules_install
				sudo cp -v arch/x86_64/boot/bzImage /boot/vmlinuz-$katalog
				echo "Zakończyłem wgrywanie do katalogu /boot"
				cd ..
				sleep 3
			;;
			"Wyjście")
				cd ..
				clear
			;;
			*) echo "Brak wyboru"
		esac
		break
	done

	cat << EOF > $katalog.preset
	ALL_config="/etc/mkinitcpio.conf"
	ALL_kver="/boot/vmlinuz-$katalog"
	PRESETS=('default' 'fallback')
	default_image="/boot/initramfs-$katalog.img"
	fallback_image="/boot/initramfs-$katalog-fallback.img"
	fallback_options="-S autodetect"
	
EOF

	sudo cp $katalog.preset /etc/mkinitcpio.d/$katalog.preset	
	sudo mkinitcpio -p $katalog
	sudo grub-mkconfig -o /boot/grub/grub.cfg
}

function debian() {
echo "Dział w budowie"
}

function inna() {
echo "Dział w budowie"
}

function kompilacja() {
	rdzenie;
	if [ ! -d $wybor ]; then {
		tar xavf $wybor
	} else {
	echo ""
	} fi
	katalog=`echo $wybor | sed -n '/\.tar.xz$/s///p'` 
	echo $katalog
	cd $katalog


	echo "Jaką masz dystrybucję : ?"
	select ARCH in ArchLinux Debian Inna WYJŚCIE
	do
	  case "$ARCH" in
	  	"ArchLinux") archlinux;;
		"Debian") debian;;
		"Inna") inna;;
	  	"WYJŚCIE") echo "Wychodzę";;
	  	*) echo "Brak wyboru"
	  esac
	break
	done

#	echo -e "\e[32m===========================================\e[0m"
#	echo -e "\e[32m=  Wgrywam domyślną konfigurację kernela  =\e[0m"
#	echo -e "\e[32m===========================================\e[0m"
#	pwd
#	sleep 3	
#	make localmodconfig
#	echo -e "\e[33mCzy wejść w opcje konfiguracyjne kernela (make menuconfig)\e[0m"
#	read -r -p "Press Y or N" wybory	
#		if [[ "$wybory" =~ ^([yY][eE][sS]|[yY])$ ]]; then {
#		make menuconfig
#		} else {
#		echo -e "\e[33mKontynuuje z domyślną konfiguracją\e[0m"
#		} fi
#	make clean
#	echo -e "\e[32m============================\e[0m"
#	echo -e "\e[32m=  Rozpoczynam kompilację  =\e[0m"
#	echo -e "\e[32m============================\e[0m"
#	sleep 3	
#	make -j $RDZENIE
#	echo -e "\e[33mCo mam zrobić :\e[0m"
#	opcje=("Wgraj kernela" "Wyjście")
#	select opcja in "${opcje[@]}"
#	do
#		case $opcja in
#			"Wgraj kernela")
#				sudo make modules_install
#				sudo cp -v arch/x86_64/boot/bzImage /boot/vmlinuz-$katalog
#				echo "Zakończyłem wgrywanie do katalogu /boot"

#				echo "Jaką masz dystrybucję : ?"
#				select ARCH in ArchLinux Debian Inna WYJŚCIE
#				do
#	  				case "$ARCH" in
#	  				"ArchLinux") archlinux;;
#					"Debian") debian;;
#	  				"WYJŚCIE") echo "Wychodzę";;
#	  					*) echo "Brak wyboru"
#					esac
#					break
#				done
#				cd ..
#				sleep 3
#			;;
#			"Wyjście")
#				cd ..
#				clear
#			;;
#			*) echo "Brak wyboru"
#		esac
#		break
#	done
}

function kernele() {
	zmienne;	
	while [[ ! $numer =~ [5].[0-9] ]]; do
	echo "Podaj numer wersji gałęzi kernela którą mam sprawdzić np. 5.9"
    	read numer
	done
	curl --compressed --progress-bar -o kernele.asc $ADRES_KERNELA_PLIKI
	awk '/linux-'$numer'.tar.xz/' kernele.asc > linux-$numer.txt
	if [[ ! `grep linux-$numer linux-$numer.txt` ]]; then {
		echo "Brak kerneli na stronie https://kernel.org !"
		} else {
			echo -e "\e[33mKernel istnieje\e[0m"
			cat linux-$numer.txt
			echo -e "\e[33mZ tej gałęzi dostępne są również kernele:\e[0m"
			awk '/linux-'$numer'[^a-z]+.tar.xz/' kernele.asc > linux-$numer.txt
			sort -n -t "." -k3 linux-$numer.txt | more
			echo -e "\e[33mDostępne łaty:\e[0m"
			awk '/patch-'$numer'[^a-z]+.xz/' kernele.asc > patch-$numer.txt
			sort -n -t "." -k3 patch-$numer.txt | more
			kernele_file=$(cat linux-$numer.txt |tr "\n" " ")
			kernele_tablica=($kernele_file)
			readarray -t menu < linux-$numer.txt
			for i in "${!menu[@]}"; do
				menu_list[$i]="${menu[$i]%% *}"
			done
			select wybor in "${menu_list[@]}"; do
				case "$wybor" in
					"") brake ;;
					*) Kernel "${menu_list[$wybor]}" ;;
				esac
			done
			echo -e "\e[33mWyniki zapisałem w plikach:"
			echo -e "\e[32mlinux-$numer.txt\e[0m"
			echo -e "\e[32mpatch-$numer.txt\e[0m"
			read -p "Press ENTER"
		} fi
	echo "Zakończyłem sprawdzanie"
}


# Głowny rdzeń skryptu
    while :
    do {
	clear
	echo -e "\e[32m${tablica_logo["0"]}\e[0m"
	echo -e "\e[32mCo mam zrobić :\e[0m"
	opcje_wyboru=(
		"Pobrać tylko wskazane źródło kernela" 
		"Pobrać i skompilować wskazane źródło" 
		"Sprawdzić dostępne kernele z kernel.org"
		"Wyjście"
	)
	select opcja in "${opcje_wyboru[@]}"
	do
		case $opcja in
		"Pobrać tylko wskazane źródło kernela") 		
		zmienne;		
		curl --compressed -o kernele.asc $ADRES_KERNELA_PLIKI
		clear
		echo -e "\e[32m${tablica_logo["0"]}\e[0m"
		grep -o "linux-[0-9]\+.[0-9]\+.[0-9]\+.tar.xz" kernele.asc > kernele.txt	
		sort -n -t "." kernele.txt > kernele-sort.txt
		readarray -t menu < kernele-sort.txt
		echo $ADRES_KERNELA
		for i in "${!menu[@]}"; do
			menu_list[$i]="${menu[$i]%% *}"
		done
		echo -e "\e[32mChoose a kernel :\e[0m"
		select wybor in "${menu_list[@]}" "EXIT"; do
		case "$wybor" in
			"EXIT")
			clear
			exit 1
			;;
			*)
			echo "You chose : $wybor"		
			sign=`echo $wybor | cut -f1 -d "t" | awk '{ printf("%star.sign", $1); }'` 
			ADRES_PODPISU="https://cdn.kernel.org/pub/linux/kernel/v5.x/${sign}"
			zmienne;
			echo "$ADRES_KERNELA"
			if [ ! -f "$wybor" ] && [ ! -f "$KERNEL_SIGN" ]; then {
		         	if curl --output /dev/null --silent --head --fail "$ADRES_KERNELA"; then {
			                echo -e "\e[32m Kernel exists : $ADRES_KERNELA , download :\e[0m"
			                curl --compressed --progress-bar -o "$wybor" "$ADRES_KERNELA"
					curl --compressed --progress-bar -o "$sign" "$ADRES_PODPISU"
                            		clear
                            		echo -e "\e[33mDownload key GPG\e[0m"
	                        	gpg --locate-keys torvalds@kernel.org gregkh@kernel.org
	                        	unxz -c $wybor | gpg --verify $sign -
	                            		if [ $? -eq 0 ]; then {
                                    		echo -e "\e[32m============================\e[0m"
                                    		echo -e "\e[32m= The signature is correct =\e[0m"
                                    		echo -e "\e[32m============================\e[0m"	
                                   	 	sleep 2
						echo -e "\e[33mKernel download: $wybor\e[0m"	
                                		} else {
    		                        	echo "Signature problem : $wybor"
                                		} fi
                            	}
		                else {
  			             echo "Kernel not exist : $ADRES_KERNELA"
			             sleep 2
                            	} fi
                        }
	                else {
	                     echo -e "\e[32m====================================\e[0m"
	                     echo -e "\e[32m= The kernel is already downloaded =\e[0m"
	                     echo -e "\e[32m====================================\e[0m"
			     echo -e "\e[33mKernel download: $wybor.tar.xz\e[0m"	
			     sleep 2
                        } fi
			;;
			esac
			break
			done
			read -p "Press ENTER"
			clear
			;;
            		"Pobrać i skompilować wskazane źródło")	
		
			zmienne;		
			curl --compressed -o kernele.asc $ADRES_KERNELA_PLIKI
			clear
			echo -e "\e[32m${tablica_logo["0"]}\e[0m"
			grep -o "linux-[0-9]\+.[0-9]\+.[0-9]\+.tar.xz" kernele.asc > kernele.txt	
			sort -n -t "." kernele.txt > kernele-sort.txt
			readarray -t menu < kernele-sort.txt
			echo $ADRES_KERNELA
			for i in "${!menu[@]}"; do
				menu_list[$i]="${menu[$i]%% *}"
			done
			echo -e "\e[32mChoose a kernel :\e[0m"
			select wybor in "${menu_list[@]}" "EXIT"; do
			case "$wybor" in
			"EXIT")
			clear
			exit 1
			;;
			*)
			echo "You chose : $wybor"		
			sign=`echo $wybor | cut -f1 -d "t" | awk '{ printf("%star.sign", $1); }'` 
			ADRES_PODPISU="https://cdn.kernel.org/pub/linux/kernel/v5.x/${sign}"
			zmienne;
			echo "$ADRES_KERNELA"
			if [ ! -f "$wybor" ] && [ ! -f "$KERNEL_SIGN" ]; then {
		         	if curl --output /dev/null --silent --head --fail "$ADRES_KERNELA"; then {
			                echo -e "\e[32m Kernel exists : $ADRES_KERNELA , download :\e[0m"
			                curl --compressed --progress-bar -o "$wybor" "$ADRES_KERNELA"
					curl --compressed --progress-bar -o "$sign" "$ADRES_PODPISU"
                            		clear
                            		echo -e "\e[33mDownload key GPG\e[0m"
	                        	gpg --locate-keys torvalds@kernel.org gregkh@kernel.org
	                        	unxz -c $wybor | gpg --verify $sign -
	                            		if [ $? -eq 0 ]; then {
                                    		echo -e "\e[32m============================\e[0m"
                                    		echo -e "\e[32m= The signature is correct =\e[0m"
                                    		echo -e "\e[32m============================\e[0m"	
                                   	 	sleep 2
						echo -e "\e[33mKernel download: $wybor\e[0m"	
                                		} else {
    		                        	echo "Signature problem : $wybor"
                                		} fi
                            	}
		                else {
  			             echo "Kernel not exist : $ADRES_KERNELA"
			             sleep 2
                            	} fi
                        }
	                else {
	                     echo -e "\e[32m====================================\e[0m"
	                     echo -e "\e[32m= The kernel is already downloaded =\e[0m"
	                     echo -e "\e[32m====================================\e[0m"
			     echo -e "\e[33mKernel download: $wybor.tar.xz\e[0m"	
			     sleep 2
                        } fi
			;;
			esac
			break
			done
			kompilacja;
			read -p "Press ENTER"
			clear
			;;
            		"Sprawdzić dostępne kernele z kernel.org")
			zmienne;	
			while [[ ! $numer =~ [5].[0-9] ]]; do
				echo "Podaj numer wersji gałęzi kernela którą mam sprawdzić np. 5.9"
    				read numer
			done
			curl --compressed --progress-bar -o kernele.asc $ADRES_KERNELA_PLIKI
			awk '/linux-'$numer'.tar.xz/' kernele.asc > linux-$numer.txt
			if [[ ! `grep linux-$numer linux-$numer.txt` ]]; then {
				echo "Brak kerneli na stronie https://kernel.org !"
			} else {
				echo -e "\e[33mKernel istnieje\e[0m"
				cat linux-$numer.txt
				echo -e "\e[33mZ tej gałęzi dostępne są również kernele:\e[0m"
				awk '/linux-'$numer'[^a-z]+.tar.xz/' kernele.asc > linux-$numer.txt
				sort -n -t "." -k3 linux-$numer.txt | more
				echo -e "\e[33mDostępne łaty:\e[0m"
				awk '/patch-'$numer'[^a-z]+.xz/' kernele.asc > patch-$numer.txt
				sort -n -t "." -k3 patch-$numer.txt | more
				echo -e "\e[33mWyniki zapisałem w plikach:"
				echo -e "\e[32mlinux-$numer.txt\e[0m"
				echo -e "\e[32mpatch-$numer.txt\e[0m"
				read -p "Press ENTER"
				clear
			} fi
			echo "Zakończyłem sprawdzanie"
		;;
		"Wyjście")
			clear
			exit 1
		;;
	*) echo "Brak wyboru !"
	esac
	break
done
}
echo -e "\e[32mBy Curar :) 2020 r.\e[0m"
unset KERNEL
pauza
done
