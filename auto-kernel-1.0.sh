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
ADRES_KERNELA="https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-${KERNEL}.tar.xz"
ADRES_PODPISU="https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-${KERNEL}.tar.sign"
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

function kompilacja() {
	if [ ! -d linux-$KERNEL ]; then {
		tar xavf linux-$KERNEL.tar.xz
	} else {
	echo ""
	} fi
	cd linux-$KERNEL
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
	make -j $RDZENIE clean
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
				sudo cp -v arch/x86_64/boot/bzImage /boot/vmlinuz-linux-$KERNEL
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
                	echo -e "\e[33mPodaj wersję kernela którą mam pobrać np.: 5.9.2\e[0m"
                	read KERNEL
			zmienne;
                        if [ ! -f "$KERNEL_EXIST" ] && [ ! -f "$KERNEL_SIGN" ]; then {
		         	if curl --output /dev/null --silent --head --fail "$ADRES_KERNELA"; then {
			                echo -e "\e[32m Kernel istnieje : $ADRES_KERNELA , pobieram :\e[0m"
			                sleep 3			
			                curl --compressed --progress-bar -o "$KERNEL_EXIST" "$ADRES_KERNELA"
			                curl --compressed --progress-bar -o "$KERNEL_SIGN" "$ADRES_PODPISU"
			                clear
                            		curl_gpg_tar_exist;
                            		echo "Pobierma klucze GPG"
	                        	gpg --locate-keys torvalds@kernel.org gregkh@kernel.org
	                        	unxz -c linux-$KERNEL.tar.xz | gpg --verify linux-$KERNEL.tar.sign -
	                            		if [ $? -eq 0 ]; then {
                                    		echo -e "\e[32m=====================\e[0m"
                                    		echo -e "\e[32m=  Podpis poprawny  =\e[0m"
                                    		echo -e "\e[32m=====================\e[0m"	
                                   	 	sleep 2
						echo -e "\e[33mKERNEL POBRANY: linux-$KERNEL.tar.xz\e[0m"	
                                		} else {
    		                        	echo "Problem z podpisem : linux-$KERNEL.tar.xz"
                                		} fi
                            	}
		                else {
  			             echo "Kernel nie istnieje : $ADRES_KERNELA"
			             sleep 2
                            	} fi
                        }
	                else {
	                     echo -e "\e[32m===========================\e[0m"
	                     echo -e "\e[32m= Kernel jest już pobrany =\e[0m"
	                     echo -e "\e[32m===========================\e[0m"
			     echo -e "\e[33mKERNEL POBRANY: linux-$KERNEL.tar.xz\e[0m"	
			     sleep 2
                        } fi
			;;
            		"Pobrać i skompilować wskazane źródło")	
			echo -e "\e[32mPracujesz jako :\e[0m"; whoami 
                	echo -e "\e[33mPodaj wersję kernela którą mam pobrać i skompilować np.: 5.9.2\e[0m"
                	read KERNEL
                	rdzenie;
 			zmienne;
 			if [ ! -f "$KERNEL_EXIST" ] && [ ! -f "$KERNEL_SIGN" ]; then {
		         	if curl --output /dev/null --silent --head --fail "$ADRES_KERNELA"; then {
			                echo -e "\e[32m Kernel istnieje : $ADRES_KERNELA , pobieram :\e[0m"
			                sleep 3			
			                curl --compressed --progress-bar -o "$KERNEL_EXIST" "$ADRES_KERNELA"
			                curl --compressed --progress-bar -o "$KERNEL_SIGN" "$ADRES_PODPISU"
			                clear
                            		curl_gpg_tar_exist;
                            		echo "Pobierma klucze GPG"
	                        	gpg --locate-keys torvalds@kernel.org gregkh@kernel.org
	                        	unxz -c linux-$KERNEL.tar.xz | gpg --verify linux-$KERNEL.tar.sign -
	                            		if [ $? -eq 0 ]; then {
                                    		echo -e "\e[32m=====================\e[0m"
                                    		echo -e "\e[32m=  Podpis poprawny  =\e[0m"
                                    		echo -e "\e[32m=====================\e[0m"	
                                   	 	sleep 3	
                                		} else {
    		                        	echo "Problem z podpisem : linux-$KERNEL.tar.xz"
                                		} fi
					kompilacja;
				} else {
  			             echo "Kernel nie istnieje : $ADRES_KERNELA"
			             sleep 2
                            	} fi
                        } else {
	                 	echo -e "\e[32m===========================\e[0m"
	                  	echo -e "\e[32m= Kernel jest już pobrany =\e[0m"
	                   	echo -e "\e[32m===========================\e[0m"
	                    	sleep 3
				kompilacja;
                       } fi
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
