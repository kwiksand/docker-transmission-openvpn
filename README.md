# docker-transmission-openvpn

Transmission-daemon running on top of dependent openvpn client governed by the runit init layer. All driven by external config volumes (see the README.md)


## Requirements
* a working OpenVPN account (with associated .ovpn file), this should be confirmed tested and working with an OpenVPN client, i.e ```openvpn myclientcert.ovpn```, or one of the many OpenVPN client implementations (i.e tunnelblick on OSX)
* a previous knowledge of transmission-daemon is handy, but it's a no brainer to use/work with after initial setup

## Usage
Pull the image (or build yourself) via:
```docker pull quay.io/kwiksand/transmission-openvpn:latest```

Test with no configuration for a manual run:
```docker run --privileged --dns=8.8.8.8 --name="transmission-openvpn" -d -ti -v `pwd`/myclientcert.ovpn:/etc/openvpn/clientcert.ovpn-p 9091:9091 quay.io/kwiksand/transmission-openvpn:latest
docker logs -f transmission-openvpn```

Example Log output (showing OpenVPN startup)
> Fri Jan 27 16:44:35 2017 [OpenVPN] Peer Connection Initiated with [AF_INET]21.95.222.73:1194

> Fri Jan 27 16:44:37 2017 SENT CONTROL [OpenVPN]: 'PUSH_REQUEST' (status=1)

> Fri Jan 27 16:44:38 2017 PUSH: Received control message: 'PUSH_REPLY,topology subnet,route-gateway 10.9.0.1,redirect-gateway def1 bypass-dhcp,dhcp-option DNS 8.8.8.8,dhcp-option DNS 8.8.4.4,ping 5,ping-restart 30,ifconfig 10.9.0.12 255.255.255.0'

> ...

> Fri Jan 27 16:44:40 2017 Initialization Sequence Completed

By this point you'll have a basic (completely untweaked) transmission install on the standard port (visible on the machine at http://localhost:9091)

# Further Usage (a more useful example)
As an extension to the base usage above, the transmission config, torrent/resume information and Download folder can be stored outside the container so they're persistant, and easy to access/backup/etc.

Process:
* first, set up the environment
```bash
mkdir transmission-openvpn 
wget -O docker-compose.yml https://raw.githubusercontent.com/kwiksand/docker-transmission-openvpn/master/docker-compose.yml-example
mkdir -o transmission/{daemon,Downloads}
wget -O transmission/daemon/settings.json https://raw.githubusercontent.com/kwiksand/docker-transmission-openvpn/master/examples/transmission-daemon/settings.json
```

* now edit the settings.json to reflect the settings in docker-compose.yml:
```
{
...
    "download-dir": "/media/Downloads/downloaded",
    "incomplete-dir": "/media/Downloads/incomplete",
    "incomplete-dir-enabled": true,
    "peer-port": 47222,
    "rpc-port": 32011,
    "rpc-password": "password",
    "rpc-username": "admin",
...
}
```

* finally, start container using docker-compose
```bash
docker-compose up-d
docker-compose logs -f
```

* now you'll have a downloads folder, in ~/transmission-openvpn/Downloads, and a tranmission interface available at http://localhost:47222

(There's a world more settings to be tweaked to automate downloads, set speed limits, add/remove security/encryption, etc)
