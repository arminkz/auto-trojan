Overview
---

Trojan-Go is an unidentifiable mechanism that helps you bypass censorship firewalls.
Trojan features multiple protocols over TLS to avoid both active/passive detections and ISP QoS limitations.
For more information on Trojan protocol visit [Trojan-GFW](https://trojan-gfw.github.io/trojan/) and
[Trojan-Go](https://github.com/p4gefau1t/trojan-go/)

This script allows you to easily setup and configure a trojan server.


How Trojan Protocol avoids Passive Detection?
---

Although many VPN services use TLS as their transport (eg. Cisco AnyConnect), Censors are able to distingush the VPN traffic from real HTTPS traffic. They do so by analysing the TLS handshake parameters, Validity of certificates and ...
Trojan-Go is undetectable by these Passive Detection methods because it establishes a TLS connection exactly like a real web server with a valid HTTPS certificate does.

<p align="center">
  <img width="900" src="/../main/doc/passive.png?raw=true"/>
</p>


How Trojan Protocol avoids Active Detection?
---

In some cases, Censors could go beyond Passive methods and probe IPs to check if they are indeed a web server and not a VPN connection. Trojan-Go addresses this issue by serving a decoy website alongside the proxy service.

<p align="center">
  <img width="900" src="/../main/doc/active.png?raw=true"/>
</p>


Avoid IP Blocks with CloudFlare CDN
---

Censors may try to blacklist your IP in case they realize it is a Trojan server. To avoid IP leakage and also counter blocking by IP, you can configure CloudFlare as a middle proxy. In this scenario if the censors try to block your service, they will have to block the Cloudflare IP which causes too much collateral damage (Many sites use CloudFlare as CDN). To make your server compatible with Cloudflare CDN you might have to enable WebSocket on Trojan Server.

<p align="center">
  <img width="900" src="/../main/doc/cloudflare.png?raw=true"/>
</p>


Installation
---

TODO.
