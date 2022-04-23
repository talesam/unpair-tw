#!/usr/bin/env bash
# Desemparelhar TicWatch sem redefinir de fábrica
# Por Tales A. Mendonça - talesam@gmail.com
# https://developer.android.com/studio/command-line/fakeroot adb
# https://fakeroot adbshell.com/commands/fakeroot adb-shell-pm-list-packages

# Versão do script
VER="v0.0.8"

# Definição de Cores
# Tabela de cores: https://misc.flogisoft.com/_media/bash/colors_format/256_colors_fg.png

# Cores degrade
RED001='\e[38;5;1m'		# Vermelho 1
RED009='\e[38;5;9m'		# Vermelho 9
CYA122='\e[38;5;122m'	# Ciano 122
CYA044='\e[38;5;44m'	# Ciano 44
ROX063='\e[38;5;63m'	# Roxo 63
ROX027='\e[38;5;27m'	# Roxo 27
GRE046='\e[38;5;46m'	# Verde 46
GRY247='\e[38;5;247m'	# Cinza 247
LAR208='\e[38;5;208m'	# Laranja 208
LAR214='\e[38;5;214m'	# Laranja 214
AMA226='\e[38;5;226m'	# Amarelo 226
BLU039='\e[38;5;44m'	# Azul 39
MAR094='\e[38;5;94m'	# Marrom 94
MAR136='\e[38;5;136m'	# Marrom 136

# Cores chapadas
CIN='\e[30;1m'			# Cinza
RED='\e[31;1m'			# Vermelho
GRE='\e[32;1m'			# Verde
YEL='\e[33;1m'			# Amarelo
BLU='\e[34;1m'			# Azul
ROS='\e[35;1m'			# Rosa
CYA='\e[36;1m'			# Ciano
NEG='\e[37;1m'			# Negrito
CUI='\e[40;31;5m'		# Vermelho pisacando, aviso!
STD='\e[m'				# Fechamento de cor

# --- Início Funções --- 

# Separação com cor
separacao(){
	for i in {16..21} {21..16} ; do
		echo -en "\e[38;5;${i}m____\e[0m"
	done ; echo
}

# Função pause
pause(){
	read -p "$*"
}

# Verifica se está usando Termux
termux(){
	clear
	separacao
	echo -e " ${NEG}Bem vindo(a) ao script${STD} ${BLU}Unpair Ticwatch${STD} - ${CIN}${VER}${STD}"
	echo -e " ${NEG}Modelos compatíveis:${STD}"
	echo -e " ${CYA}PRO 3${STD}, ${CYA}PRO 3 ULTRA${STD}, ${CYA}PRO 3 ULTRA LTE${STD}."
	separacao
	echo "" 
	pause "Tecle [Enter] para continuar..."
	clear
	echo ""
	echo -e " ${ROX063}Verificando dependências, aguarde...${STD}" && sleep 2
	if [ -f "/data/data/com.termux/files/usr/bin/adb.bin" ] || [ -f "/usr/bin/adb" ]; then
		echo -e " ${GRE046}Dependencias encontradas, conecte-se ao relógio.${STD}"
		echo ""
		pause " Tecle [Enter] para continuar..." ; conectar_relogio
	else
		echo -e " ${BLU}*${STD} ${NEG}Baixando as dependências para utilizar o script${SDT}"
		echo -e " ${BLU}*${STD} ${NEG}no Termux, aguarde a conclusão...${SDT}" && sleep 2
		pkg update -y -o Dpkg::Options::=--force-confold
		pkg install -y android-tools && pkg install -y fakeroot && clear
		if [ "$?" -eq "0" ]; then
			echo ""
			echo -e " ${GRE}*${STD} ${NEG}Instalação conluida com sucesso!${STD}" && sleep 2
			clear
			echo -e " ${ROS}Vejo que essa é a primeira vez que utiliza este script${STD}"
			echo ""
			echo -e " Você precisará ativar o modo DEPURAÇÂO no"
			echo -e " seu relógio. Vá em ${YEL}Configurações${STD}, ${YEL}Sistema${STD}, ${YEL}Sobre${STD} e"
			echo -e " toque em ${YEL}Número da versão${STD} 7 vezes, rapidamente,"
			echo -e " para desbloquear as opções de desenvolvedor."
			echo ""
			echo -e " Em ${YEL}configurações${STD} terá ${YEL}Opções do desenvolvedor${STD}"
			echo -e " abaixo de ${YEL}Sistema${STD}. Ative as opções ${YEL}Depuração USB${STD}"
			echo -e " e ${YEL}Depurar por Wifi${STD}. O relógio pode exibir inicialmente"
			echo -e " uma mensagem dizendo ${YEL}Indisponível${STD} que em breve será"
			echo -e " substituída por uma sequência de caracteres incluindo o"
			echo -e " endereço IP (caso demore aparecer, retorne uma tela e"
			echo -e " acesse novamente) .Isso significa que o fakeroot adb sobre Wi-Fi"
			echo -e " foi ativado. Anote o endereço IP exibido aqui."
			echo -e " Será algo como:"
			echo ""
			echo -e " ${ROS}192.168.68.119${STD}"
			echo ""
			pause " Tecle [Enter] para se conectar ao relógio..." ; conectar_relogio
		else
			echo ""
			echo -e " ${RED}*${STD} ${NEG}Erro ao baixar e instalar as dependências.\n Verifique sua conexão e tente novamente.${STD}" ; exit 0
		fi
	fi
}

# Conexão do relógio
conectar_relogio(){
	clear
	export ANDROID_NO_USE_FWMARK_CLIENT=1
	echo ""
	echo " Digite o endereço IP do seu relógio que encontra-se no"
	echo -e " caminho abaixo e tecle ${NEG}[Enter]${STD} para continuar:"
	echo ""
	echo -e " ${AMA226}Configurações${STD}, ${AMA226}Opções do desenvolvedor${STD},"
	echo -e " ${AMA226}Depuração USB${STD}(Desative/Ative), ${AMA226}Depurar por Wi-Fi${STD}."
	echo ""
	read IP

	ping -c 1 $IP >/dev/null

	# Testa se o relógio está ligado com o modo depuração ativo
	if [ "$?" -eq "0" ]; then
		echo ""
		echo -e " ${LAR214}Conectando-se ao seu relógio...${STD}" && sleep 3
		fakeroot fakeroot adb connect $IP > /dev/null 2>&1
		if [ "$?" -eq "0" ]; then
			echo -e " ${GRE046}Conectado com sucesso ao relógio!${STD}" && sleep 3
			echo ""
			clear
			until fakeroot fakeroot adb shell pm list packages -e 2>&1 > /dev/null; do
				clear
				echo ""
				echo -e " ${NEG}Autorize a conexão no seu relógio${STD}"
				echo -e " Aparecerá no relógio: ${BLU}Depuração USB?${STD}"
				echo -e " Toque em:${STD}"
				echo -e " ${GRE}Sempre permitir a partir deste computador${STD}."
				echo ""
				pause " Tecle [Enter] para continuar..." ;

				# Testa se o humano marcou a opção no relógio			
				fakeroot fakeroot adb disconnect $IP >/dev/null && fakeroot fakeroot adb connect $IP >/dev/null
				if [ "$(fakeroot fakeroot adb connect $IP | cut -f1,2 -d" ")" = "already connected" ]; then
					desemparelhar
				else
					echo ""
					echo -e " ${CYA}Não me engana, você ainda\n não marcou a opção no relógio :-(\n Vou te dar outra chance!${STD}"
					echo ""
					pause " Ative a opção e tecle [Enter]"
				fi
			done
				desemparelhar
		else
			echo -e " ${RED}*${STD} ${NEG}Erro! Falha na conexão, Verifique seu endereço de IP${STD}"
			pause " Tecle [Enter] para tentar novamente..." ; conectar_relogio
		fi
	else
		echo -e " ${RED}*${STD} ${NEG}Erro! Falha na conexão, Verifique seu endereço de IP${STD}"
		pause " Tecle [Enter] para tentar novamente..." ; conectar_relogio
	fi
}

# Desemparelhar
desemparelhar(){
	clear
	echo ""
	echo -e " ${ROX027}Aguarde...${STD}" && sleep 1

	# Limpando as configurações e reiniciando o relógio
	if [ "$(fakeroot fakeroot adb connect $IP | cut -f1,2 -d" ")" = "already connected" ]; then
		fakeroot fakeroot adb shell "pm clear com.google.android.gms && reboot" >/dev/null
		
		# Se a execução for bem sussedida, então...
		if [ "$?" -eq "0" ]; then
			clear
			echo ""
			echo -e " ${GRE046}Reiniciando o relógio e limpando as configurações,${STD}" && sleep 1
			
			# Verifica se o relógio já reiniciou e conectou via fakeroot adb
			echo ""
			echo -e " ${CYA044}Aguardando o relógio se conectar...😴${STD}"
			until $(ping -c 1 $IP >/dev/null 2>&1); do
				# Aguardando relógio se conectar
				echo -ne "."
			done
			clear
			echo ""
			echo -e " Vá em ${AMA226}Configurações${STD}, ${AMA226}Opções do desenvolvedor${STD},"
			echo -e " e aguarde pegar o IP em ${AMA226}Depurar por Wi-Fi${STD}"
			pause " Quando aparece, tecle [Enter] para continuar..."
			
			# Conecta ao relógio após reiniciar
			fakeroot fakeroot adb connect $IP >/dev/null
			if [ "$(fakeroot fakeroot adb connect $IP | cut -f1,2 -d" ")" = "already connected" ]; then
				echo ""
				echo -e " ${GRE}*${STD} ${NEG}Relógio conectado com sucesso!!${STD}" && sleep 2
			else
				echo -e " ${RED}*${STD} ${NEG}Erro! Falha ao desparear.${STD}"
				pause " Tecle [Enter] para tentar novamente..."
			fi
			# Desparear o dispositivo bluetooth do relógio
			fakeroot fakeroot adb shell "am start -a android.bluetooth.adapter.action.REQUEST_DISCOVERABLE" >/dev/null
			if [ "$?" -eq "0" ]; then
				clear
				echo ""
				echo -e " Vá para o seu smartphone, abra o ${BLU}Wear OS${STD}"
				echo -e " Toque em ${BLU}Concordar e continuar,${STD}"
				echo -e " Vá no seu relógio e confirme a conexão bluetooth."
				exit 0
			else
				echo -e " ${RED}*${STD} ${NEG}Erro! Falha ao desparear.${STD}"
				pause " Tecle [Enter] para tentar novamente..." ; desemparelhar
			fi
		fi
	else
		echo -e " ${RED}*${STD} ${NEG}Erro! Falha ao reiniciar o relógio.${STD}"
		pause " Tecle [Enter] para tentar novamente..." ; desemparelhar
	fi
}

# Cria um diretório temporário e joga todos arquivos lá dentro e remove sempre ao entrar no script
rm -rf .tmp && mkdir .tmp && cd .tmp

# Chama o script inicial
termux