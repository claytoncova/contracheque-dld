#!/bin/bash
WAIT=1 # Tempo de espera entre as requisições, em segundos.

echo -n Usuário: 
read USER
echo -n Senha: 
read -s PASS
echo
echo -n Ano inicial:
read START
echo -n Ano final:
read STOP

# Post data, tokens para requisição no site. Recupera cookie da autenticação.
get_cookie () {
  wget -qO- --keep-session-cookies --save-cookies cookies.txt \
--post-data "ToolkitScriptManager1_HiddenField=&__EVENTTARGET=&__EVENTARGUMENT\
=&__VIEWSTATE=%2FwEPDwULLTE1MTkxMTg4MjUPZBYCAgMPZBYCAgMPZBYCAgEPZBYCZg9kFgQCAQ\
8PFgIeBFRleHQFC01hdHLDrWN1bGE6ZGQCDQ8QDxYCHgdDaGVja2VkaGRkZGQYAQUeX19Db250cm9s\
c1JlcXVpcmVQb3N0QmFja0tleV9fFgEFEUxvZ2luMSRSZW1lbWJlck1lskidMBgKdfLJOHEz1LCw%2\
BT3%2BC6E%3D&__VIEWSTATEGENERATOR=CD41C6AE&__EVENTVALIDATION=%2FwEWBQLWuuXICAK\
UvNa1DwL666vYDAKC0q%2BkBgKnz4ybCPn6rcesXXTJLJkHxNSAJBl%2Fnjjj&Login1%24UserNam\
e=$1&Login1%24Password=$2&Login1%24LoginButton=Entrar" \
https://contracheque.sistemas.ro.gov.br/AcessoServicos.aspx
}

# Baixa os arquivos PDF, na sequência. Tem como baixar somente os listados na 
# primeira busca, TODO.
get_file () {
  wget -qO- --load-cookies cookies.txt \
https://contracheque.sistemas.ro.gov.br/RelatorioContraCheque.aspx?\
MesRef=$1$2\&TipRot=$3\&SeqPns=9 > Contracheque-$1-$2$4.pdf
  sleep $WAIT
}

get_cookie $USER $PASS

for i in $(seq $START $STOP);
do
  for j in 01 02 03 04 05 06 07 08 09 10 11 12
    do
      echo "Downloading month $j, year $i"
      get_file $i $j 4
      if [ $j -eq 12 ]
      then
        get_file $i $j 7 -13o # Segunda parcela do 13o
      fi
      if [ $j -eq 06 ]
      then
        get_file $i $j 6 -13o # Primeira parcela do 13o
      fi
    done
done

rm cookie.txt &> /dev/null
echo "All done."
