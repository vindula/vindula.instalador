#!/bin/bash
#IntranetVindula
#
#
# Instala todos os requisitos necessários da intranet Vindula
# Executa a instancia da intranet.
#
# Versão 1.05 - 28/02/2014
#             - Homolagação 
#---------------------------------------------------------------------------
# Versão 1.05b - 25/02/2014
#             - Inclusão da função de verificação da intraface de rede
#             - Bugfix do layout
#             - Restrição de arquitetura para 12.04 Server 64bits
#             - Inclusão de mensagens  
#---------------------------------------------------------------------------
# Versão 1.04b - 24/02/2014
#             - Melhorias nas ERs
#             - Criação do usuário vindula
#             - Executar a intranet com esse usuário
#---------------------------------------------------------------------------
# Versão 1.03a - 21/02/2014
#             - Identificação do sistem operacional UNIX (server | desktop)
#---------------------------------------------------------------------------
# Versão 1.02a - 19/02/2014
#             - Acerto na criação dos diretórios
#             - Adicionado as opções:
#             --------- Ajuda 
#             --------- Versão  do Instalador
#             --------- Instalar / Recuperar instalação
#---------------------------------------------------------------------------
# Versão 1.01a - 16/02/2014
#             - Inclusão de cabaçalho 
#             - Adicionado suporte comandos por linha de comando e resoluçao de permissionamento.
#---------------------------------------------------------------------------
# Versão 1.00a - 05/02/2014
#             - Não há funções, opções e layout
#---------------------------------------------------------------------------

verificaIP(){

    interfaceCon="wlan0 eth0"
        
    semIpValido=0

for conect in $interfaceCon; do

ipValido=$(ip addr \
    | grep inet \
    | grep $conect \
    | awk -F" " '{print $2}'\
    | sed 's/\/.*$//')
    
    if [[ -n $ipValido ]]; then

    echo -e "\n Interface de rede $conect:
 Acesse a Intranet Vindula em sua rede interna
 através desse endereço \e[1m$ipValido:8080/vindula\e[m\n";

    semIpValido=5
    
    fi

done

    if [[ $semIpValido -eq 0 ]]; then

    echo -e "\n  Para acessar a intranet através de sua
 rede interna, deve obter um \e[1mip válido\e[m.
 Por favor, verifique as configurações
 de rede\n";

    fi

}

cursorVI(){ sleep 0.25; echo -n "   -"; sleep 0.25; echo -n "> "; }

verificador(){

requiDiver=0

contador=0

for validaVer in $requisMin; do

    confVers=$(echo "$sisOp" \
    | sed -e 's:\('$validaVer'\):(\1):g' \
    | sed -n 's:[^()]*\(([^)]*)\)[^(]*:\1:gp')
    
        if [[ -n $confVers ]]; then

            echo -e "  \e[42;37;1m OK \e[m $validaVer";

        else

            if [[ -z $confVers ]] && [[ $requiDiver -eq 0 ]]; then

                if [[ $contador -eq 1 ]]; then
               
                    UbuntuDife=1

                else    

                    UbuntuServer=1

                fi  

            ((requiDiver++))    

            echo -e "  \e[41;37;1m NO \e[m $validaVer";

            else

            ((requiDiver++))

            fi  

        fi

((contador++)); done

#Verifica arquitetura

                if [[ $archteturaSio = x86_64 ]]; then

                    echo -e "  \e[42;37;1m OK \e[m 64bits ";

                else

                    echo -e "  \e[41;37;1m NO \e[m 64bits ";

                fi

}

verificadorMsn(){

if [[ $requiDiver -ne 0 ]] ; then

    echo -e "\n      \e[41;37;1m    !!! INSTALAÇÃO INTERROMPIDA !!!    \e[m\
    \n   A instalação da Intranet Vindula será cancelada.\
    \n   As configurações do servidor não atendem aos\
    \n   requisitos necessários. Para maiores informações\
    \n   acesse. \e[1m http://www.vindula.com.br\e[m \n" 

    exit 0
else

    confirmarInt

    echo -e "\e[0m\n  O seu sistema, atende aos requisitos\
    \n  necessários para a instalação e\
    \n  execução da \e[1mIntranet Vindula.\e[m\n"

    confirmarIntOPC
fi  
}

menuPrincipal(){

clear

 if [ -f /opt/intranet/app/intranet/vindula/bin/instance ]; then
  
    txtT="Vindula, a sua INTRANET"
    txtLb=" [1] - Iniciar a Intranet        "
    varVl=300

            estiApro
 else

    txtT="Instalador o Vindula   "
    txtLb=" [1] - Instalar a Intranet       " 
    varVl=200

            estiInst

  fi

baseLayout  

cursorVI

read opcD;

echo -e "\a"

        if [[ "$opcD" -eq 0 ]]; then

            opcE=100

        else

            opcE=$(($varVl-$opcD))

        fi  

case "$opcE" in

    199)
        clear
        verificador
        verificadorMsn

        ;;
    299)
        aguardIni
        ;;
    100)
        estiSair
        ;;
    *)
        opcInvalida

        menuPrincipal
        ;;
esac

opcE=-5

}

instalarVindula(){

add-apt-repository ppa:libreoffice/ppa 

apt-get update

apt-get -y install mysql-client mysql-server

apt-get -y install curl

vindulaD=`curl https://raw2.github.com/vindula/buildout.python/master/dependencias.txt`

for inst in $vindulaD; do echo "`apt-get -y install $inst`"; done 

gem install bundle 

gem install docsplit -v 0.6.4

mkdir -pv /opt/core /opt/intranet/app/intranet

git clone https://github.com/vindula/buildout.python.git /opt/core/python

cd /opt/core/python/

python bootstrap.py

easy_install - U distribute

./bin/buildout -vN

/opt/core/python/bin/virtualenv-2.7 --no-site-packages /opt/intranet/app/intranet/

wget -c -P /opt/intranet/app/intranet/ \
"http://downloads.sourceforge.net/project/vindula/2.0.3/Vindula-2.0.3LTS.tar.gz"

tar xvf /opt/intranet/app/intranet/Vindula-2.0.3LTS.tar.gz -C /opt/intranet/app/intranet/

cd /opt/intranet/app/intranet/vindula/

../bin/easy_install -U distribute

../bin/easy_install -U setuptools

../bin/python bootstrap.py

./bin/buildout -vN

useradd vindula

chown -R vindula:vindula /opt/intranet/

}

executorInstancia(){

verificador

cd /

sudo -u vindula ./opt/intranet/app/intranet/vindula/bin/instance start

if [[ UbuntuServer -eq 1 ]]; then

    echo -e "\n  Dentro de instantes, o navegador\
    \n  será carregado com a \e[1mIntranet Vindula\e[m."

    verificaIP

     sleep 10;

     x-www-browser localhost:8080/vindula/&

else        

    verificaIP

fi

}

baseLayout(){

echo -e "\n  \e[40m                                    \e[m"
echo -e "  \e[40m \e[m\e[${coRa}m \e[m\e[40m \e[m\e[${coRaB}${txtSt}m \
${txtT} \e[m\e[40m \e[m\e[${coRaB}m  \e[m\e[40m \e[m\e[${coRaB}m \e[m\e[40m \
\e[m\e[${coRaB}m \e[m\e[40m \e[m" 
echo -e "  \e[40m \e[m\e[${coRa}m \e[m\e[${txtSd}m${txtLd} \e[m" 
echo -e "  \e[40m \e[m\e[${coRa}m \e[m\e[${txtSa}m${txtDi} \e[m"
echo -e "  \e[40m \e[m\e[${coRa}m \e[m\e[${txtSb}m${txtLa} \e[m"
echo -e "  \e[40m \e[m\e[${coRa}m \e[m\e[${txtSb}m${txtLb} \e[m"
echo -e "  \e[40m \e[m\e[${coRa}m \e[m\e[${txtSc}m${txtLc} \e[m"
echo -e "  \e[40m                                    \e[m \n"

}

opcInvalida(){

        clear

        txtLd="                                 "
        txtLa=" --------------------------------"
        txtT=" !!! OPÇÃO INVÁLIDA !!!"
        txtDi="      Essa opção não exite!      "
        txtLb=" Escolha uma das opções validas  "
        txtLc=" no menu principal.              "
       

            estiExep
            baseLayout  

        sleep 2;

        estiPrinci
        menuPrincipal
}

estiApro(){

    coRa=42
    coRaB=44
}

estiInst(){

    coRa=41
    coRaB=46
}

estiExep(){

    coRa=43
    coRaB=41
    txtSc="40;37;6"

}

estiSair(){

        clear

        txtT=" A Liberiun agradece.  "
        txtLd="  Obrigado por utilizar o Vindula"
        txtDi=" Você gostaria de saber mais     "
        txtLa=" sobre nossos serviços?          "
        txtLb="                                 "
        txtLc="   http://www.vindula.com.br     "

        txtSd="40;37;1"
        txtSa="40;37;6"

            estiApro
            baseLayout 
            sleep 2;
            exit;
}

estiPrinci(){

    clear

    txtSt=";37;1"

    txtSd="40;31;1"
    txtSa="40;33;1"
    txtSb="40;37;6"
    txtSc="40;37;6"

    txtLd="                                 "
    txtDi="  * Escolha uma opção no menu *  "
    txtLa=" --------------------------------"
    txtLc=" [0] - Sair                      "

}

confirmarInt(){
   
     clear

        txtT=" Confirmar Instalação !"
        txtLd="        -*- ATENÇÃO -*-          "
        txtDi="   Antes de instalar o Vindula,  "
        txtLa=" deve-se instalar as dependêcnias"
        txtLb=" necessárias.                    "
        txtLc=" [s]- Sim | [n]- Não | [0]- Sair "

            txtSc="40;37;1"
            estiInst
            baseLayout  

}

confirmarIntOPC(){

            cursorVI
        read opcI
        echo -e "\a"

    case "$opcI" in

        s)
            aguardIni
            estiSair
            ;;
        n)        
            menuPrincipal
            ;;
        0)
            estiSair
            ;;
        *)
            opcInvalida
            ;;
    esac

}

aguardIni(){

     clear
     estiApro
     txtDi="           * AGUARDE *           "
     txtLb="          será iniciada.         "
     txtSc="40;37;6"

     if [ "$opcI" != s ]; then

        txtT="Inicializando o Vindula"
        txtLd="                                 "
        txtLa=" Dentro de instantes, a intranet "

        txtLc="                                 "
     
      baseLayout
      sleep 3;
      opcI=-5 
      executorInstancia

     else

        txtT="Instalando o Vindula..."
        txtLd="                                 "
        txtLa=" Dentro de instantes a instalação"
        txtLc="                                 "

      baseLayout
      sleep 3; 
      instalarVindula 

     fi 
       
}

#Aqui é capturado e tratado a verão do Ubuntu
sisOp=$(cat /etc/apt/sources.list \
    | sed -n 's:[^[]*\(\[[^]]*\]\)[^[]*:\1:gp'\
    | sed 's:(.*)::'\
    | sed -n 1p)

estiPrinci

requisMin="Ubuntu 12.04 Server"

archteturaSio=$(arch)

MENSAGEM_USO="
Uso: $(basename "$0") ['OPCOES']

OPCOES:
\e[1m
  -a, --ajuda           - Mostra a ajuda
  -V, --versao          - Mostra a versão do programa
  -I, --instalar        - Instalar a Intranet   
\e[m
"
        case "$1" in

           -a | --ajuda )

                clear
                echo -e " $MENSAGEM_USO"
                exit 0
                ;;
           -V | --versao )

                echo -e "\n `cat $(basename "$0")\
                | sed -r '/^# Vers/!g'\
                | sed '/^$/d' \
                | sed -n '/\#/{p;q;}'`\n"


                exit 0

                ;;
           -I | --instalar )
              
                confirmarInt
                exit 0

                ;;
            *)
                if test -n "$1"; then 
                    echo -e "\n A opção [ $1 ] é inválida. \n"
                    exit 0
                fi
                ;;
        esac

menuPrincipal 