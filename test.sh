
	wybor="linux-5.9.11.tar.xz"
	if [ ! -d $wybor ]; then {
		tar xavf $wybor
	} else {
	echo ""
	} fi
	katalog=`echo $wybor | sed -n '/\.tar.xz$/s///p'` 
	echo $katalog
	cd $katalog
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
	make -j 8 clean
	echo -e "\e[32m============================\e[0m"
	echo -e "\e[32m=  Rozpoczynam kompilację  =\e[0m"
	echo -e "\e[32m============================\e[0m"
	sleep 3	
	make -j 8
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
