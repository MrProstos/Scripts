if [[ -e $File ]]
then

    read -p "Enter name Group -> " GroupName
    mkdir -p /etc/wireguard/$GroupName/
    echo "Directory $GroupName created!"

    PublicServerKey=$(cat /etc/wireguard/publickey)
    while IFS= read -r line
    do
        IdUser=$(echo $line | cut -d "," -f1)
        NameUser=$(echo $line | cut -d "," -f2-3)

        mkdir -p /etc/wireguard/$GroupName/$NameUser

        wg genkey | sudo tee /etc/wireguard/$GroupName/$NameUser/private-key | wg pubkey | sudo tee /etc/wireguard/$GroupName/$NameUser/public-key

        PrivateKey=$(cat /etc/wireguard/$GroupName/$NameUser/private-key)
        PublicKey=$(cat /etc/wireguard/$GroupName/$NameUser/public-key)

        echo "[Interface]
Address=10.0.0.$IdUser/24
PrivateKey=$PrivateKey
DNS=8.8.8.8
[Peer]
PublicKey=$PublicServerKey
AllowedIPs=0.0.0.0/0
EndPoint=81.20.147.218:30000
PersistentKeepalive=20" > $NameUser.txt

        zip $NameUser.zip $NameUser.txt
        rm $NameUser.txt
        mv $NameUser.zip /etc/wireguard/$GroupName/$NameUser/

        echo "
[Peer]
PublicKey=$PublicKey
AllowedIPs=10.0.0.$IdUser/24" >> /etc/wireguard/wg0.conf

    done < $File                                                                                                                                                                                                   
else
    echo "File not found!"
fi
~                     
