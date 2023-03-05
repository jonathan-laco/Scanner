#!/bin/bash
######-----------------------------------------------------------
# [!] Script desenvolvido no dia 04/03/2023
# [!] Desenvolvido por Jonathan Laco 
# [!] Contato: jonathanlaco@castpytech.com
#
#----------------INFORMAÇÕES
#
# [!] Essa versão infelizmente duplica os resultados, 
#     algo que será resolvido na próxima versão do script.
# [!] Versão: 1.0
# [!] Proxima versão contará com mais diretórios e subdirs, para
#     fazer o scan.
######-----------------------------------------------------------
echo "
███████╗ ██████╗ █████╗ ███╗   ██╗███╗   ██╗███████╗██████╗ 
██╔════╝██╔════╝██╔══██╗████╗  ██║████╗  ██║██╔════╝██╔══██╗
███████╗██║     ███████║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝
╚════██║██║     ██╔══██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗
███████║╚██████╗██║  ██║██║ ╚████║██║ ╚████║███████╗██║  ██║
╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝"
echo "powered by Jonathan Laco"
echo

if [ $# -eq 0 ]
then
  echo "Por favor, forneça um site como argumento."
  exit 1
fi

site="$1"

alvos=(
  "/"
  "/css"
  "/js"
  "/imagens"
  "/arquivo.txt")

verde='\033[0;32m'
vermelho='\033[0;31m'
sem_cor='\033[0m'

arquivo_saida="sucesso.txt"

echo -n > $arquivo_saida

for alvo in "${alvos[@]}"
do
  url="$site$alvo"
  response=$(curl --write-out %{http_code} --silent --output /dev/null "$url")

  if [ $response -eq 200 ]
  then
    echo -e "${verde}Alvo encontrado: $url${sem_cor}"
    echo $url >> $arquivo_saida

    arquivos=$(curl -s $url | grep -Po '(?<=href=")[^"]*(?=")')
    
    for arquivo in $arquivos
    do
      if [[ $arquivo == */ ]]
      then
        subdiretorio="${arquivo%/*}"
        suburl="$url$subdiretorio"
        subresponse=$(curl --write-out %{http_code} --silent --output /dev/null "$suburl")
        
        if [ $subresponse -eq 200 ]
        then
          echo -e "${verde}Diretório encontrado: $suburl${sem_cor}"
          echo $suburl >> $arquivo_saida
        else
          echo -e "${vermelho}Diretório não encontrado: $suburl${sem_cor}"
        fi
      else
        fileurl="$url$arquivo"
        fileresponse=$(curl --write-out %{http_code} --silent --output /dev/null "$fileurl")
        
        if [ $fileresponse -eq 200 ]
        then
          echo -e "${verde}Arquivo encontrado: $fileurl${sem_cor}"
          echo $fileurl >> $arquivo_saida
        else
          echo -e "${vermelho}Arquivo não encontrado: $fileurl${sem_cor}"
        fi
      fi
    done
  else
    echo -e "${vermelho}Alvo não encontrado: $url${sem_cor}"
  fi
done

echo "Resultados encontrados foram salvos em  $arquivo_saida."
