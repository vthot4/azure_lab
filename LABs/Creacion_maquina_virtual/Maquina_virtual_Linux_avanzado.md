# Creación de una máquina virtual Linux con el CLI de Azure.(Avanzado)

En esta segunda parte, vamos a probar algunas opciones que nos proporciona Azure cli para crear nuestra máquina.
Los pasos que seguiremos en esta guia serán los siguientes:

    1. Crear un grupo de recursos.
    2. Crear una máquina virtual seleccionado el tipo y con discos.
    3. Crear una máquina virtual con IP estática y accesible vía dns de Azure.
    4. Como usar cloud-init para customizar la máquina Linux en su primer arranque en Azure.

    6. Script sencillo.

## 1. Crear un grupo de recursos.

Antes de crear el grupo de recursos, tenemos que decidir en que zona la vamos a crear. Para ver las posibles zonas podemos usar:

```bash
    ## Obtenemos todas las zonas
    vthot4@labcell:~/azure_lab/LABs$ az account list-locations

    ## Sólo necesitamos el name por lo que podemos usar
    vthot4@labcell:~/azure_lab/LABs$ az account list-locations |grep name
        "name": "eastasia",
        "name": "southeastasia",
        "name": "centralus",
        "name": "eastus",
        "name": "eastus2",
        "name": "westus",
        "name": "northcentralus",
        "name": "southcentralus",
        "name": "northeurope",
        "name": "westeurope",
        "name": "japanwest",
        "name": "japaneast",
        "name": "brazilsouth",
        ...........................................
    
    ## En este caso usaremos  
    vthot4@labcell:~/azure_lab/LABs$ az account list-locations |grep name|grep northeur
    "name": "northeurope",
```
Decidida la zona, creamos el grupo de recursos. Un grupo de recursos de Azure es un contenedor lógico en el que se implementan y se administran los recursos de Azure.

```bash
    vthot4@labcell:~/azure_lab/LABs$ az group create --name LAB_vthot4 --location northeurope
    {
    "id": "/subscriptions/345gc74f-9632-1046-abd3-d26eh134b4et/resourceGroups/LAB_vthot4",
    "location": "northeurope",
    "managedBy": null,
    "name": "LAB_vthot4",
    "properties": {
        "provisioningState": "Succeeded" 2. Crear una máquina virtual seleccionado el tipo y con discos.
    },
    "tags": null,
    "type": "Microsoft.Resources/resourceGroups"
    }

```

## 2. Crear una máquina virtual seleccionado el tipo y con discos.

En el [lab anterior](./Maquina_virtual_Linux.md) vimos como crear de forma sencilla una máquina virtual: 

```bash
vthot4@labcell:~/azure_lab/LABs$ az vm create --resource-group LAB_vthot4 --name UbuntuLAB --image UbuntuLTS --admin-username vteteam
```
Ahora vamos a ver como podemos ir completando con diferentes opciones. Comenzaremos añadiendo dos parámetros nuevos de configuración:

- **--size.** Nos permite definir el tipo de máquina que queremos levantar, en nuestro caso Standard_DS2_v2. Podemos ver todos los tipos de máuqinas y posibles usos en el siguiente enlace:   https://docs.microsoft.com/es-es/azure/virtual-machines/windows/sizes

- **--data-disk-sizes-gb.** Nos permite añadir discos a la MV. En este caso añadiremos dos discos adicionales de 20 y 30 GB respectivamente.

```bash
vthot4@labcell:~/azure_lab$ az vm create --resource-group LAB_vthot4 -n UbuntuLAB --image UbuntuLTS --data-disk-sizes-gb 20 30 --size Standard_DS2_v2 --generate-ssh-keys

{
  "fqdns": "",
  "id": "/subscriptions/386fc78f-9755-4065-aad4-d59df290a7fe/resourceGroups/LAB_vthot4/providers/Microsoft.Compute/virtualMachines/UbuntuLAB",
  "location": "northeurope",
  "macAddress": "00-0D-3A-D9-56-04",
  "powerState": "VM running",
  "privateIpAddress": "10.0.0.4",
  "publicIpAddress": "13.69.152.143",
  "resourceGroup": "LAB_vthot4",
  "zones": ""
}

```
Podemos comprobar que se han añadido los discos correctamente:
```bash
vthot4@labcell:~/azure_lab$ ssh 13.69.152.143
vthot4@UbuntuLAB:~$ sudo su -
root@UbuntuLAB:~# fdisk -l
## El tipo de máuqina que hemos seleccionado viene con dos discos por defecto.
Disk /dev/sda: 30 GiB, 32213303296 bytes, 62916608 sectors
Disk /dev/sdb: 14 GiB, 15032385536 bytes, 29360128 sectors

## Estos discos son los que hemos añadido. Aparecen agregados pero sin formato.
Disk /dev/sdc: 20 GiB, 21474836480 bytes, 41943040 sectors
Disk /dev/sdd: 30 GiB, 32212254720 bytes, 62914560 sectors

```
Borramos los recursos para seguir con las pruebas.
```bash
vthot4@labcell:~/azure_lab$ az group delete --name LAB_vthot4
Are you sure you want to perform this operation? (y/n): y
 - Running ..
```

Podría haber optado por borrar sólo la máquina virtual pero prefiero borrar todo el grupo de recursos ya que Azure crea muchos recursos asociados que pueden quedar residuales.


##  3. Crear una máquina virtual con IP estática y accesible vía dns de Azure.

En este ejemplo vamos a generar una VM Linux con una IP estática y un name del dns de azure. Para ello, vamos a usar los siguientes parámetros:

- **public-ip-address.** Asignación de una IP pública que nos permitirá comunicarnos con los recursos creados en Azure desde el exterior. La dirección se crea en el grupo de recursos y luego la podemos asignar a un recurso en concreto.

- **public-ip-address-allocation.** Definimos las opciones de asignación de la IP. Pueden ser dynamic o static. 

- **public-ip-address-dns-name.** Con este parámetro podemos especificar una etiqueta de nombre de dominio DNS para un recurso de IP público, que crea una asignación para domainnamelabel.location.cloudapp.azure.com en los servidores de DNS de Azure. 

Entendidos muy por encima los parámetros vamos a lanzar nuestra prueba:

```bash
	az vm create --resource-group LAB_vthot4 --name UbuntuLAB \
        --image UbuntuLTS --admin-username vthot4 \
        --public-ip-address labIP \
        --public-ip-address-allocation static \
        --public-ip-address-dns-name labvthot4 \
        --generate-ssh-keys
```
Podemos comprobar que todo ha ido bien usando la consola:

```bash
vthot4@labcell:~/azure_lab$ az vm list-ip-addresses -g LAB_vthot4 -n UbuntuLAB
[
  {
    "virtualMachine": {
      "name": "UbuntuLAB",
      "network": {
        "privateIpAddresses": [
          "10.0.0.4"
        ],
        "publicIpAddresses": [
          {
            "id": "/subscriptions/345gc74f-9632-1046-abd3-d26eh134b4et/resourceGroups/LAB_vthot4/providers/Microsoft.Network/publicIPAddresses/labIP",
            "ipAddress": "168.63.71.159",
            "ipAllocationMethod": "Static",
            "name": "labIP",
            "resourceGroup": "LAB_vthot4"
          }
        ]
      },
      "resourceGroup": "LAB_vthot4"
    }
  }
]

```
La parte del DNS no la he conseguido ver desde la consola pero si desde el portal de azure:

```
Nombre DNS: labvthot4.northeurope.cloudapp.azure.com
```

Para terminar nuestra prueba, procedemos al borrado de los recursos:

```bash
    vthot4@labcell:~/azure_lab$  az group delete --name LAB_vthot4
    Are you sure you want to perform this operation? (y/n): y
    - Running ..

```


## 4. Como usar cloud-init para customizar la máquina Linux en su primer arranque en Azure.






## Bibliografía

- https://docs.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest#az-vm-create
- https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-ip-addresses-overview-arm#public-ip-addresses
- https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-automate-vm-deployment
