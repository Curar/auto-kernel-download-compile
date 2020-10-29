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
RDZENIE=`getconf _NPROCESSORS_ONLN`
KERNEL_EXIST="linux-${KERNEL}.tar.xz"
KERNEL_SIGN="linux-${KERNEL}.tar.sign"
KERNEL_D="linux-${KERNEL}"
ADRES_KERNELA="https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-${KERNEL}.tar.xz"
ADRES_PODPISU="https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-${KERNEL}.tar.sign"
}

# Definicja funkcji używanych w skrypcie
function curl_gpg_sudo_exist() {
	if ! [ -x "$(command -v curl)" ]; then {
  		echo 'UWAGA curl nie jest zainstalowany !' >&2
		exit 1
    	}
	elif ! [ -x "$(command -v gpg)" ]; then {
		echo 'UWAGA gpg nie jest zainstalowane !' >&2
       		exit 1
    	}  
	elif ! [ -x "$(command -v sudo)" ]; then {
		echo 'UWAGA gpg nie jest zainstalowane !' >&2
		exit 1
	} fi
}

function pauza() {	
	read -p "Naduś klawisz ENTER aby kontynować ..."
}

function rdzenie() {
	if [ ! "$RDZENIE -le 4" ]
	then
		echo -e "\e[32mWykryłem ,że masz : $RDZENIE wątki, dostosuję skrypt automatycznie\e[0m"
		sleep 3
	else
		echo -e	"\e[32mWykryłem ,że masz : $RDZENIE wątków, dostosuję skrypt automatycznie\e[0m"
        sleep 3	
	fi
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
			echo -e "\e[32mPracujesz jako :\e[0m"; whoami 
                	echo -e "\e[33mPodaj wersję kernela którą mam skompilować np.: 5.9.2\e[0m"
                	read KERNEL
                	zmienne;
                	rdzenie;
                        if [ ! -e "$KERNEL_EXIST" ] && [ ! -e "$KERNEL_SIGN" ]; then {
		         	if curl --output /dev/null --silent --head --fail "$ADRES_KERNELA"; then {
			                echo -e "\e[32m Kernel istnieje : $ADRES_KERNELA , pobieram :\e[0m"
			                sleep 3			
			                curl --compressed --progress-bar -o "$KERNEL_EXIST" "$ADRES_KERNELA"
			                curl --compressed --progress-bar -o "$KERNEL_SIGN" "$ADRES_PODPISU"
			                clear
                            		curl_gpg_sudo_exist;
                            		echo "Pobierma klucze GPG"
	                        	gpg --locate-keys torvalds@kernel.org gregkh@kernel.org
	                        	unxz -c linux-${KERNEL}.tar.xz | gpg --verify linux-${KERNEL}.tar.sign -
	                            		if [ $? -eq 0 ]; then {
                                    		echo -e "\e[32m=====================\e[0m"
                                    		echo -e "\e[32m=  Podpis poprawny  =\e[0m"
                                    		echo -e "\e[32m=====================\e[0m"	
                                   	 	sleep 3	
                                		} else {
    		                        	echo "Problem z podpisem : linux-${KERNEL}.tar.xz"
                                		} fi
                            	}
		                else {
  			             echo "Kernel nie istnieje : $ADRES_KERNELA"
			             exit
                            	} fi
                        }
	                else {
	                     echo -e "\e[32m===========================\e[0m"
	                     echo -e "\e[32m= Kernel jest już pobrany =\e[0m"
	                     echo -e "\e[32m===========================\e[0m"
	                     sleep 3
                        } fi
			;;
            	"Pobrać i skompilować wskazane źródło")
            	;;
            	"Sprawdzić dostępne kernele z kernel.org")
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
pauza
done
