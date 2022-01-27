#!/bin/bash

read -p "Enter the path to file.txt -> " File

if [[ -e $File ]]
then

    if ! [[ -f $GroupName ]]
    then
        mkdir $GroupName
    fi

    PublicServerKey=$(cat /etc/wireguard/publickey)

    while IFS= read -r line
    do

        IdUser=$(echo $line | cut -d "," -f1)
        NameUser=$(echo $line | cut -d "," -f2-3)

        mkdir $NameUser/$NameUser/

        wg genkey | tee /home/$GroupName/$NameUser/private-key | wg pubkey |  tee /home/$GroupName/$NameUser/public-key

        PrivateKey=$(cat /home/$GroupName/$NameUser/private-key)
        PublicKey=$(cat /home/$GroupName/$NameUser/public-key)

        echo "[Interface]
Address=10.0.0.$IdUser/24
PrivateKey=$PrivateKey
DNS=8.8.8.8
[Peer]
PublicKey=$PublicServerKey
AllowedIPs=0.0.0.0/0
EndPoint=81.20.147.218:30000
PersistentKeepalive=20" > $NameUser.txt

        zip $NameUser.zip $NameUser.txt                                                                                                                                                                                    rm $NameUser.txt
        mv $NameUser.zip $GroupName

        echo "
[Peer]
PublicKey=$PublicKey
AllowedIPs=10.0.0.$IdUser/24" >> /etc/wireguard/wg0.conf

    done < $File
    mv $GroupName /etc/wireguard/
else
    echo "File not found!"
fi
