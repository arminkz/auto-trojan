#!/usr/bin/env bash

# Module Prerequisites
# $domain must be set

install_acme(){
  set +e
  curl --retry 5 -s https://get.acme.sh | sh
  if [[ ! -f /root/.acme.sh/acme.sh ]]; then
    color_echo ${ERROR} "Error on ACME.sh setup."
    exit 1
  fi
  ~/.acme.sh/acme.sh --upgrade --auto-upgrade
}

issue_using_dns_api() {
    whiptail --title "Warning" --msgbox "Make sure your domain name vendor (or to be precise your domain name's NS) is present in the following list, This is required for issuing HTTPS Certificate. (you need to ensure that domain name A resolution has been successful)" 15 68
    APIOPTION=$(whiptail --nocancel --clear --title "Choose DNS API" --menu --separate-output "Please select your DNS provider (Use Arrow key to choose)" 15 68 6 \
"1" "Cloudflare" \
"2" "Namesilo" \
"3" "Aliyun" \
"4" "DNSPod.cn" \
"5" "CloudXNS.com" \
"6" "GoDaddy" \
"7" "Name.com" 3>&1 1>&2 2>&3)

    case $APIOPTION in
        1)
        while [[ -z ${CF_Key} ]] || [[ -z ${CF_Email} ]]; do
        CF_Key=$(whiptail --passwordbox --nocancel "https://dash.cloudflare.com/profile/api-tokens，Enter your CF Global Key" 8 68 --title "CF_Key input" 3>&1 1>&2 2>&3)
        CF_Email=$(whiptail --inputbox --nocancel "https://dash.cloudflare.com/profile，Enter CF Email address" 8 68 --title "CF_Key input" 3>&1 1>&2 2>&3)
        done
        export CF_Key="$CF_Key"
        export CF_Email="$CF_Email"
        install_acme
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --issue --dns dns_cf --cert-home /etc/certs -d $domain -k ec-256 --log --reloadcmd "systemctl reload trojan nginx || true"
crontab -l > mycron
echo "0 0 * * * /root/.acme.sh/acme.sh --server letsencrypt --cron --cert-home /etc/certs --reloadcmd 'systemctl restart trojan nginx  || true' &> /root/auto-trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
        ;;
        2)
        while [[ -z $Namesilo_Key ]]; do
        Namesilo_Key=$(whiptail --passwordbox --nocancel "https://www.namesilo.com/account_api.php，Enter your Namesilo_Key" 8 68 --title "Namesilo_Key input" 3>&1 1>&2 2>&3)
        done
        export Namesilo_Key="$Namesilo_Key"
        install_acme
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --issue --dns dns_namesilo --cert-home /etc/certs --dnssleep 1800 -d $domain -k ec-256 --log --reloadcmd "systemctl reload trojan nginx || true"
crontab -l > mycron
echo "0 0 * * * /root/.acme.sh/acme.sh --server letsencrypt --cron --cert-home /etc/certs --reloadcmd 'systemctl restart trojan nginx  || true' &> /root/auto-trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
        ;;
        3)
        while [[ -z $Ali_Key ]] || [[ -z $Ali_Secret ]]; do
        Ali_Key=$(whiptail --passwordbox --nocancel "https://ak-console.aliyun.com/#/accesskey，Enter your Ali_Key" 8 68 --title "Ali_Key input" 3>&1 1>&2 2>&3)
        Ali_Secret=$(whiptail --passwordbox --nocancel "https://ak-console.aliyun.com/#/accesskey，Enter your Ali_Secret" 8 68 --title "Ali_Secret input" 3>&1 1>&2 2>&3)
        done
        export Ali_Key="$Ali_Key"
        export Ali_Secret="$Ali_Secret"
        install_acme
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --issue --dns dns_ali --cert-home /etc/certs -d $domain -k ec-256 --log --reloadcmd "systemctl reload trojan nginx || true"
crontab -l > mycron
echo "0 0 * * * /root/.acme.sh/acme.sh --server letsencrypt --cron --cert-home /etc/certs --reloadcmd 'systemctl restart trojan nginx  || true' &> /root/auto-trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
        ;;
        4)
        while [[ -z $DP_Id ]] || [[ -z $DP_Key ]]; do
        DP_Id=$(whiptail --passwordbox --nocancel "DNSPod.cn，Enter your DP_Id" 8 68 --title "DP_Id input" 3>&1 1>&2 2>&3)
        DP_Key=$(whiptail --passwordbox --nocancel "DNSPod.cn，Enter your DP_Key" 8 68 --title "DP_Key input" 3>&1 1>&2 2>&3)
        done
        export DP_Id="$DP_Id"
        export DP_Key="$DP_Key"
        install_acme
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --issue --dns dns_dp --cert-home /etc/certs -d $domain -k ec-256 --log --reloadcmd "systemctl reload trojan nginx || true"
crontab -l > mycron
echo "0 0 * * * /root/.acme.sh/acme.sh --server letsencrypt --cron --cert-home /etc/certs --reloadcmd 'systemctl restart trojan nginx  || true' &> /root/auto-trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
        ;;
        5)
        while [[ -z $CX_Key ]] || [[ -z $CX_Secret ]]; do
        CX_Key=$(whiptail --passwordbox --nocancel "CloudXNS.com，Enter your CX_Key" 8 68 --title "CX_Key input" 3>&1 1>&2 2>&3)
        CX_Secret=$(whiptail --passwordbox --nocancel "CloudXNS.com，Enter your CX_Secret" 8 68 --title "CX_Secret input" 3>&1 1>&2 2>&3)
        done
        export CX_Key="$CX_Key"
        export CX_Secret="$CX_Secret"
        install_acme
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --issue --dns dns_cx --cert-home /etc/certs -d $domain -k ec-256 --log --reloadcmd "systemctl reload trojan nginx || true"
crontab -l > mycron
echo "0 0 * * * /root/.acme.sh/acme.sh --server letsencrypt --cron --cert-home /etc/certs --reloadcmd 'systemctl restart trojan nginx  || true' &> /root/auto-trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
        ;;
        6)
        while [[ -z $CX_Key ]] || [[ -z $CX_Secret ]]; do
        CX_Key=$(whiptail --passwordbox --nocancel "https://developer.godaddy.com/keys/，Enter your GD_Key" 8 68 --title "GD_Key input" 3>&1 1>&2 2>&3)
        CX_Secret=$(whiptail --passwordbox --nocancel "https://developer.godaddy.com/keys/，Enter your GD_Secret" 8 68 --title "GD_Secret input" 3>&1 1>&2 2>&3)
        done
        export GD_Key="$CX_Key"
        export GD_Secret="$CX_Secret"
        install_acme
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --issue --dns dns_gd --cert-home /etc/certs -d $domain -k ec-256 --log --reloadcmd "systemctl reload trojan nginx || true"
crontab -l > mycron
echo "0 0 * * * /root/.acme.sh/acme.sh --server letsencrypt --cron --cert-home /etc/certs --reloadcmd 'systemctl restart trojan nginx  || true' &> /root/auto-trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
        ;;
        7)
        while [[ -z $Namecom_Username ]] || [[ -z $Namecom_Token ]]; do
        Namecom_Username=$(whiptail --passwordbox --nocancel "https://www.name.com/account/settings/api，Enter your Namecom_Username" 8 68 --title "Namecom_Username input" 3>&1 1>&2 2>&3)
        Namecom_Token=$(whiptail --passwordbox --nocancel "https://www.name.com/account/settings/api，Enter your Namecom_Token" 8 68 --title "Namecom_Token input" 3>&1 1>&2 2>&3)
        done
        export Namecom_Username="$Namecom_Username"
        export Namecom_Token="$Namecom_Token"
        install_acme
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --issue --dns dns_namecom --cert-home /etc/certs -d $domain -k ec-256 --log --reloadcmd "systemctl reload trojan nginx || true"
crontab -l > mycron
echo "0 0 * * * /root/.acme.sh/acme.sh --server letsencrypt --cron --cert-home /etc/certs --reloadcmd 'systemctl restart trojan nginx  || true' &> /root/auto-trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
        ;;
        http)
        upgradesystem
        httpissue
        ;;
        *)
        ;;
    esac

    if [[ -f /etc/certs/${domain}_ecc/fullchain.cer ]] && [[ -f /etc/certs/${domain}_ecc/${domain}.key ]]; then
        color_echo ${INFO} "Certificate Issue successful."
    else
        color_echo ${ERROR} "Certificate Issue using DNS API failed."
        exit 1
    fi
}