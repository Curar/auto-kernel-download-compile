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
   A script that automates kernel download and compilation
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
echo -e "\e[33mHELLOW\e[0m"
echo ""
read -p "Press ENTER"
clear

# Definicja zmiennych
function zmienne() {
numer=""
ADRES_KERNELA_PLIKI="https://cdn.kernel.org/pub/linux/kernel/v5.x/sha256sums.asc"
ADRES_KERNELA="https://cdn.kernel.org/pub/linux/kernel/v5.x/${wybor}"
CONFIG="config/.config"
}

# Definicja funkcji 
function polecenia() {
echo -e "\e[33mI will check if you have the appropriate programs in the system\e[0m"
sleep 2
for program in curl pahole which sudo rsync sed patch make m4 gzip groff grep gettext gcc flex file fakeroot bison bc automake autoconf; do
      	printf '%-10s' "$program"
  if hash "$program" 2>/dev/null; then
    echo -e "\e[32m- It is installed\e[0m"
    sleep 0.1 
 else
    echo -e "\e[31m- It is not installed\e[0m"
    sleep 0.1
  fi
done
}

function rodzaje_kompilacji() {
	echo -e "\e[33mHow we configure the kernel : ?\e[0m"
	select kompilacja in allnoconfig defconfig allyesconfig allmodconfig localyesconfig localmodconfig tinyconfig R-A-K-I-E-T-K-A WYJŚCIE
	do
	  case "$kompilacja" in
		  "allnoconfig") make allnoconfig;;
		  "defconfig") make defconfig;;
  		  "allyesconfig") make allyesconfig;;
		  "allmodconfig") make allmodconfig;;
		  "localyesconfig") make localyesconfig;;		  
		  "localmodconfig") make localmodconfig;;
		  "tinyconfig") make tinyconfig;;
		  "R-A-K-I-E-T-K-A") cd .. && pwd && cp $CONFIG $katalog && cd $katalog;;
		  "WYJŚCIE") exit 1;;
	  	  *) echo "Brak wyboru"
	  esac
	break
	done
}

function pauza() {	
	read -p "Press ENTER"
}

function rdzenie() {
	RDZENIE=`getconf _NPROCESSORS_ONLN`
	if [ ! "$RDZENIE -le 4" ]
	then
		echo -e "\e[32mI have detected you have : $RDZENIE threads, I'll customize the script\e[0m"
		sleep 3
	else
		echo -e	"\e[32mI have detected you have : $RDZENIE threades,I'll customize the script\e[0m"
        sleep 3	
	fi
}


function archlinux {
	cd ..
	cd $katalog
	pwd
	sleep 2	
	rodzaje_kompilacji;	
	echo -e "\e[33mWhether to enter kernel configuration mode (make menuconfig)\e[0m"
	read -r -p "Press Y or N" wybory	
		if [[ "$wybory" =~ ^([yY][eE][sS]|[yY])$ ]]; then {
		konfiguracja;
		} else {	
		echo -e "\e[33mI am continuing my earlier choice\e[0m"
		} fi
	make clean
	echo -e "\e[32m============================\e[0m"
	echo -e "\e[32m=   Starting compilation   =\e[0m"
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

function debian() {
	pwd
	sleep 3
	rodzaje_kompilacji;	
	echo -e "\e[33mWhether to enter kernel configuration mode (make menuconfig)\e[0m"
	read -r -p "Press Y or N" wybory	
		if [[ "$wybory" =~ ^([yY][eE][sS]|[yY])$ ]]; then {
		konfiguracja;
		} else {		
		echo -e "\e[33mI am continuing my earlier choice\e[0m"
		} fi
	make clean
	echo -e "\e[32m============================\e[0m"
	echo -e "\e[32m=   Starting compilation   =\e[0m"
	echo -e "\e[32m============================\e[0m"
	sleep 3	
	make -j`nproc` bindeb-pkg
	cd ..
}

function konfiguracja() {
	echo -e "\e[33mKernel custom configure : ?\e[0m"
	select kompilacja in config menuconfig nconfig WYJŚCIE
	do
	  case "$kompilacja" in
		  "config") make config;;
		  "menuconfig") make menuconfig;;
  		  "nconfig") make nconfig;;
		  "WYJŚCIE") exit 1;;
	  	  *) echo "Brak wyboru"
	  esac
	break
	done
}

function ubuntu() {
	pwd
	sleep 3	
	rodzaje_kompilacji;
	echo -e "\e[33mWhether to enter kernel configuration mode (make menuconfig)\e[0m"
	read -r -p "Press Y or N" wybory	
		if [[ "$wybory" =~ ^([yY][eE][sS]|[yY])$ ]]; then {
		konfiguracja;
		} else {
		echo -e "\e[33mI am continuing my earlier choice\e[0m"
		} fi
	make clean
	echo -e "\e[32m============================\e[0m"
	echo -e "\e[32m=   Starting compilation   =\e[0m"
	echo -e "\e[32m============================\e[0m"
	sleep 3	
	make -j`nproc` bindeb-pkg
	cd ..
}

function kompilacja() {
	rdzenie;
	if [ ! -d $wybor ]; then {
		xz -cd $wybor | tar xvf -
	} else {
	echo ""
	} fi
	katalog=`echo $wybor | sed -n '/\.tar.xz$/s///p'` 
	echo $katalog
	cd $katalog
	echo -e "\e[33mWhat is your linux distribution : ?\e[0m"
	select ARCH in Archlinux Debian Ubuntu WYJŚCIE
	do
	  case "$ARCH" in
	  	"Archlinux") archlinux;;
		"Debian") debian;;
		"Ubuntu") ubuntu;;
	  	"WYJŚCIE") exit 1;;
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
	echo -e "\e[32mWhat should I do :\e[0m"
	opcje_wyboru=(
		"Download kernel source" 
		"Download and compile kernel source" 
		"Checking exist kernel source"
		"Exit"
	)
	select opcja in "${opcje_wyboru[@]}"
	do
		case $opcja in
		"Download kernel source") 		
		zmienne;		
		curl --compressed -o kernele.asc $ADRES_KERNELA_PLIKI
		clear
		echo -e "\e[32m${tablica_logo["0"]}\e[0m"
		grep -o "linux-[[:digit:]]\+.[[:digit:]]\+.[[:digit:]]\+.tar.xz" kernele.asc > kernele.txt	
		grep -o "linux-[[:digit:]]\+.[[:digit:]]\+.tar.xz" kernele.asc >> kernele.txt	
		sort -V kernele.txt > kernele-sort.txt
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
			     echo -e "\e[33mKernel download: $wybor\e[0m"	
			     sleep 2
                        } fi
			;;
			esac
			break
			done
			read -p "Press ENTER"
			clear
			;;
            		"Download and compile kernel source")	
			polecenia;
			read -p 'Press ENTER'
			zmienne;		
			curl --compressed -o kernele.asc $ADRES_KERNELA_PLIKI
			clear
			echo -e "\e[32m${tablica_logo["0"]}\e[0m"	
			grep -o "linux-[[:digit:]]\+.[[:digit:]]\+.[[:digit:]]\+.tar.xz" kernele.asc > kernele.txt	
			grep -o "linux-[[:digit:]]\+.[[:digit:]]\+.tar.xz" kernele.asc >> kernele.txt	
			sort -V kernele.txt > kernele-sort.txt
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
			     echo -e "\e[33mKernel download: $wybor\e[0m"	
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
            		"Checking exist kernel source")
			zmienne;	
			while [[ ! $numer =~ [[:digit:]].[[:digit:]] ]]; do
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
				sort -n -t "." -k 3 linux-$numer.txt | more
				echo -e "\e[33mDostępne łaty:\e[0m"
				awk '/patch-'$numer'[^a-z]+.xz/' kernele.asc > patch-$numer.txt
				sort -n -t "." -k 3 patch-$numer.txt | more
				echo -e "\e[33mWyniki zapisałem w plikach:"
				echo -e "\e[32mlinux-$numer.txt\e[0m"
				echo -e "\e[32mpatch-$numer.txt\e[0m"
				read -p "Press ENTER"
				clear
			} fi
			echo "Zakończyłem sprawdzanie"
		;;
		"Exit")
			clear
			exit 1
		;;
	*) echo "No choice !"
	esac
	break
done
}
unset KERNEL
done
