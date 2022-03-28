# NodeJS with no root access 
* A NodeJS base Container with `no root access` (except using `sudo ...` and you can remove it using `sudo apt-get remove sudo` to protect your Container). 
```
If [ you are looking for such a common requirement as a base Container ]:
   Then [ this one may be for you ]
```

# Components:
* Ubuntu 20.04 
* No root setup: using /home/developer and /home/developer/app (your NodeJS code resides)
  * It has sudo for dev phase usage. You can "sudo apt-get remove sudo" to finalize the product image.
  * Note, you should consult Docker security experts in how to secure your Container for your production use!)

# Build (Do this first!)
```
./build.sh

or

make build

```

# Build Container for Corporate Proxy Constraints
* (New!) With this automation for setup proxy and corproate certificate for allowing the 'build and run' the Container behind your corporate networks!
* Step-1 Corporate Proxy Setup
  * If your corporate use proxy to access internet, then you can setup your proxy (in your Host's User envrionment variable ), e.g.,
```
(in your $HOME/.bashrc profile)
export http_proxy=proxy.openkbs.org:8080
export https_proxy=proxy.openkbs.org:8443
```
    
  * If your corporate use zero-trust VPN, e.g., ZScaler, then just find and download your ZScaler certificate (public certificate), e.g., my-corporate.crt, and then save it in the folder './certificates/'
  
* Step-2 Let the automation scripts chained by Dockerfile for building and running your local version of Container instance behind your Corporate Networks.
* That's it! (Done!)

```

# Run (recommended for easy-start)
```
./run.sh
```

# Create your own image from this

```
FROM openkbs/nodejs-nonroot-docker
```

# Quick commands
* build.sh - build local image
* logs.sh - see logs of container
* run.sh - run the container
* shell.sh - shell into the container
* stop.sh - stop the container
