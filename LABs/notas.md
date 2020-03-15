# Notas

## Instalación PowerShell en Ubunti 18.04

Podemos usar PowerShell de varias formas:

**Instalación en el sistema operativo**

```bash
# Download the Microsoft repository GPG keys
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb

# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb

# Update the list of products
sudo apt-get update

# Enable the "universe" repositories
sudo add-apt-repository universe

# Install PowerShell
sudo apt-get install -y powershell

# Start PowerShell
pwsh
```

**Mediante un docker**

```bash

## docker run -it mcr.microsoft.com/powershell

vthot4@labcell:~/azure_lab/LABs$ docker run -it mcr.microsoft.com/powershell
Unable to find image 'mcr.microsoft.com/powershell:latest' locally
latest: Pulling from powershell
423ae2b273f4: Already exists 
de83a2304fa1: Already exists 
f9a83bce3af0: Already exists 
b6b53be908de: Already exists 
34c58ac68bef: Pull complete 
Digest: sha256:f1f40ceb33768178d4bbd1ab078dbfa121891bab59ba356379c5d21cdee59c8d
Status: Downloaded newer image for mcr.microsoft.com/powershell:latest
PowerShell 7.0.0
Copyright (c) Microsoft Corporation. All rights reserved.

https://aka.ms/powershell
Type 'help' to get help.

PS />
```

**Links** 
- https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.x
- https://docs.microsoft.com/en-us/powershell/scripting/learn/understanding-important-powershell-concepts?view=powershell-7.x



## Instalación de azure-cli en Linux.

Los requisitos para instalar el cli de azure son:

- Python 3.6.x, 3.7.x o 3.8.x.
- libffi
- OpenSSL 1.0.2

Para instalarlo usarmeos el siguiente script de instalación:

```bash
    vthot4@labcell:~/azure_lab/LABs$ curl -L https://aka.ms/InstallAzureCli | bash
    vthot4@labcell:~/azure_lab/LABs$ az login

```

**Links**
- https://docs.microsoft.com/es-es/cli/azure/install-azure-cli-linux?view=azure-cli-latest
