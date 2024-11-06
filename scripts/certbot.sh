######################################################
echo 'Продление сертфикатов через контейнер certbot'
######################################################
docker run -it --rm --name certbot \
-p 8081:80 \
-p 8082:443 \
-v "/home/gera/letsencrypt/etc:/etc/letsencrypt" \
-v "/home/gera/letsencrypt/lib:/var/lib/letsencrypt" \
certbot/certbot certonly --standalone --email sasha@biostal.ru --agree-tos --no-eff-email --force-renewal -d mail.biostal.ru -d cloud.biostal.ru -d graf.biostal.ru -d port.biostal.ru &&
#####################################################
echo 'Конвертация сертификатов в crt key'
#####################################################
cd /home/gera/letsencrypt/etc/live/mail.biostal.ru && openssl pkey -in privkey.pem -out cert.key && openssl crl2pkcs7 -nocrl -certfile cert.pem | openssl pkcs7 -print_certs -out cert.crt &&


#####################################################
# echo 'Копиование новых сертификатов в Kerio Control'
#####################################################
# sshpass -p 'aNgelisk123' scp cert.crt root@192.168.33.1:/var/winroute/sslcert/certs/public/2e357c44-9a33-ed4a-a0f1-db9a3c77820d.crt &&
# sshpass -p 'aNgelisk123' scp cert.key root@192.168.33.1:/var/winroute/sslcert/certs/private/2e357c44-9a33-ed4a-a0f1-db9a3c77820d.key &&
######################################################
# echo 'Перезапуск службы Kerio Control'
######################################################
# sshpass -p 'aNgelisk123' ssh root@192.168.33.1 "/etc/boxinit.d/60winroute restart" &&


######################################################


######################################################
echo 'Копирование нового сертификата в Kerio Connect'
######################################################
scp -i /home/gera/letsencrypt/id_rsa_kerio_mail cert.crt admin@192.168.33.6:'"/Program Files/Kerio/MailServer/sslcert/server3.crt"'
scp -i /home/gera/letsencrypt/id_rsa_kerio_mail cert.key admin@192.168.33.6:'"/Program Files/Kerio/MailServer/sslcert/server3.key"'
######################################################
echo 'Перезапуск службы Kerio Connect'
######################################################
ssh -i /home/gera/letsencrypt/id_rsa_kerio_mail admin@192.168.33.6 net stop "KerioMailServer"
sleep 5
ssh -i /home/gera/letsencrypt/id_rsa_kerio_mail admin@192.168.33.6 net start "KerioMailServer"