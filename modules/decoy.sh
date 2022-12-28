#!/usr/bin/env bash

install_decoy_website() {

    install_sample_html=0
    install_hexo=0
    install_alist=0

    DWOPTION=$(whiptail --nocancel --clear --title "Choose Decoy Website" --menu --separate-output "Please specify the service that you want to use as a decoy website." 15 68 6 \
"1" "I plan to setup my own service. (Sample HTML)" \
"2" "Hexo Blog" \
"3" "Alist Storage" 3>&1 1>&2 2>&3)

    case $DWOPTION in
        1)
        whiptail --title "Warning" --msgbox "Having no decoy website which justifies the high volume of traffic to your server increases the chance of being detected! For setting up your own website you should edit nginx configs manually." 15 68
        install_sample_html=1
        install_hexo=0
        install_alist=0
        mkdir -p /usr/share/nginx/sample &>/dev/null
        cat > '/usr/share/nginx/sample/index.html' << EOF
<html>
    <body>
    <p>Under Construction</p>
    </body>
</html>
EOF
        echo "Sample html page created."
        ;;
        *)
        ;;
    esac


}