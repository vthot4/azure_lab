# Administración Básica máquinas virtuales.

## Obtener información de la máquina virtual

- **Enumeración de máquinas virtuales.**
```bash
vthot4@labcell:~/azure_lab/LABs$ az vm list
[
    ...........................
    },
    "host": null,
    "id": "/subscriptions/345gc74f-9632-1046-abd3-d26eh134b4et/resourceGroups/LAB_VTHOT4/providers/Microsoft.Compute/virtualMachines/UbuntuLAB",
    "identity": null,
    "instanceView": null,
    "licenseType": null,
    "location": "northeurope",
    "name": "UbuntuLAB",
    "networkProfile": {
      "networkInterfaces": [
        {
          "id": "/subscriptions/345gc74f-9632-1046-abd3-d26eh134b4et/resourceGroups/LAB_vthot4/providers/Microsoft.Network/networkInterfaces/UbuntuLABVMNic",
          "primary": null,
          "resourceGroup": "LAB_vthot4"
        }
      ]
    },
    ...........................

## Si sólo queremos obtener información de una máquina en concreto podemos usar
vthot4@labcell:~/azure_lab/LABs$ az vm show --resource-group LAB_vthot4 --name UbuntuLAB
```

## Administración del estado de la máquina virtual.

- **Inicio de una máquina virtual.**

```bash
vthot4@labcell:~/azure_lab$ az vm start --resource-group LAB_vthot4 --name UbuntuLAB
```

- **Parada de una máquina virtual.**
```
vthot4@labcell:~/azure_lab$ az vm stop --resource-group LAB_vthot4 --name UbuntuLAB

About to power off the specified VM...
It will continue to be billed. To deallocate a VM, run: az vm deallocate
```

- **Reinicio de una máquina virtual.**
```
vthot4@labcell:~/azure_lab$ az vm restart --resource-group LAB_vthot4 --name UbuntuLAB
```

- **Eliminación de una máquina virtual.**
```
vthot4@labcell:~/azure_lab$ az vm delete --resource-group LAB_vthot4 --name UbuntuLAB
Are you sure you want to perform this operation? (y/n): y
```

## Discos e imágenes.

- **Incorporación de un disco de datos a una máquina virtual.**
```
vthot4@labcell:~/azure_lab$ az vm disk attach --resource-group LAB_vthot4 --vm-name UbuntuLAB --disk myDataDisk --size-gb 128 --new
Option '--disk' has been deprecated and will be removed in a future release. Use '--name' instead.
```
Si nos conectamos a la máuqina podemos ver el disco que hemos agregado a la máquina. En mi caso es una máquina Linux:

```bash
vteteam@UbuntuLAB:~$ sudo fdisk -l
Disk /dev/sda: 30 GiB, 32213303296 bytes, 62916608 sectors
......
Disk /dev/sdb: 7 GiB, 7516192768 bytes, 14680064 sectors
......
Disk /dev/sdc: 128 GiB, 137438953472 bytes, 268435456 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
```
Una vez que vemos el disco ya podemos ejecutar las operatorias normales, por ejemplo:

```bash
vteteam@UbuntuLAB:~$ sudo fdisk /dev/sdc

Welcome to fdisk (util-linux 2.31.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x3e727873.

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 
First sector (2048-268435455, default 2048): 
Last sector, +sectors or +size{K,M,G,T,P} (2048-268435455, default 268435455): 

Created a new partition 1 of type 'Linux' and of size 128 GiB.

Command (m for help): t
Selected partition 1
Hex code (type L to list all codes): 8e
Changed type of partition 'Linux' to 'Linux LVM'.

Command (m for help): p
Disk /dev/sdc: 128 GiB, 137438953472 bytes, 268435456 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: dos
Disk identifier: 0x3e727873

Device     Boot Start       End   Sectors  Size Id Type
/dev/sdc1        2048 268435455 268433408  128G 8e Linux LVM

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

vteteam@UbuntuLAB:~$ sudo pvcreate /dev/sdc
sdc   sdc1  

vteteam@UbuntuLAB:~$ sudo pvcreate /dev/sdc1 
  Physical volume "/dev/sdc1" successfully created.

vteteam@UbuntuLAB:~$ sudo pvs
  PV         VG Fmt  Attr PSize    PFree   
  /dev/sdc1     lvm2 ---  <128.00g <128.00g

```

- **Cambio del tamaño de un disco.**
```
### Para ampliar el disco debemos tener la máqiuna parada.
vthot4@labcell:~/azure_lab$ az disk update --resource-group LAB_vthot4 --name myDataDisk --size-gb 256
Cannot resize disk myDataDisk while it is attached to running VM /subscriptions/386fc78f-9755-4065-aad4-d59df290a7fe/resourceGroups/LAB_vthot4/providers/Microsoft.Compute/virtualMachines/UbuntuLAB. Resizing a disk of an Azure Virtual Machine requires the virtual machine to be deallocated. Please stop your VM and retry the operation.

```

- **Eliminación de un disco de datos de una máquina virtual.**
```
vthot4@labcell:~/azure_lab$ az vm disk detach --resource-group LAB_vthot4 --vm-name UbuntuLAB --name myDataDisk

```

- **Instantánea de un disco.**
```bash
vthot4@labcell:~/azure_lab$ az snapshot create --resource-group LAB_vthot4 --name Limpio --source myDataDisk

{
  "creationData": {
    "createOption": "Copy",
    "imageReference": null,
    "sourceResourceId": "/subscriptions/345gc74f-9632-1046-abd3-d26eh134b4et/resourceGroups/LAB_vthot4/providers/Microsoft.Compute/disks/myDataDisk",
    "sourceUniqueId": "45b45678-3dfg-5235-s2d4-184fg6s13t4f",
    "sourceUri": null,
    "storageAccountId": null,
    "uploadSizeBytes": null
  },
  "diskSizeBytes": 137438953472,
  "diskSizeGb": 128,
  "encryption": {
    "diskEncryptionSetId": null,
    "type": "EncryptionAtRestWithPlatformKey"
  },
  "encryptionSettingsCollection": null,
  "hyperVgeneration": "V1",
  "id": "/subscriptions/345gc74f-9632-1046-abd3-d26eh134b4et/resourceGroups/LAB_vthot4/providers/Microsoft.Compute/snapshots/Limpio",
  "incremental": false,
  "location": "northeurope",
  "managedBy": null,
  "name": "Limpio",
  "osType": null,
  "provisioningState": "Succeeded",
  "resourceGroup": "LAB_vthot4",
  "sku": {
    "name": "Standard_LRS",
    "tier": "Standard"
  },
  "tags": {},
  "timeCreated": "2020-03-15T22:29:43.656230+00:00",
  "type": "Microsoft.Compute/snapshots",
  "uniqueId": "ae43e053-e602-4222-a4r4-050e51car6v4"
}

```

- **Crear imagen de una máquina virtual.**

Si intentamos crear una imágen directamente desde la máquina virtual nos aparecera el sigueinte mensaje:
```bash
vthot4@labcell:~/azure_lab$az image create --resource-group LAB_vthot4 --source UbuntuLAB --name labImage
The operation 'Create Image' requires the Virtual Machine 'UbuntuLAB' to be Generalized.
```
Para poder crearla, deberemos seguir los pasos especifícados en la siguiente guía: 
https://docs.microsoft.com/en-us/azure/virtual-machines/linux/capture-image


```bash
## Deprovision the VM.
vteteam@UbuntuLAB:~$ sudo waagent -deprovision+user
WARNING! The waagent service will be stopped.
WARNING! Cached DHCP leases will be deleted.
WARNING! root password will be disabled. You will not be able to login as root.
WARNING! /etc/resolv.conf will NOT be removed, this is a behavior change to earlier versions of Ubuntu.
WARNING! vteteam account and entire home directory will be deleted.
Do you want to proceed (y/n)y

## deallocate the VM
vthot4@labcell:~/azure_lab$ az vm deallocate --resource-group LAB_vthot4 --name UbuntuLAB

## mark the VM as generalized
vthot4@labcell:~/azure_lab$ az vm generalize --resource-group LAB_vthot4 --name UbuntuLAB

## Create an image
vthot4@labcell:~/azure_lab$ az image create --resource-group LAB_vthot4 --name labImage --source UbuntuLAB
{
  "hyperVgeneration": "V1",
  "id": "/subscriptions/345gc74f-9632-1046-abd3-d26eh134b4et/resourceGroups/LAB_vthot4/providers/Microsoft.Compute/images/labImage",
  "location": "northeurope",
  "name": "labImage",
  "provisioningState": "Succeeded",
  "resourceGroup": "LAB_vthot4",
  "sourceVirtualMachine": {
    "id": "/subscriptions/345gc74f-9632-1046-abd3-d26eh134b4et/resourceGroups/LAB_vthot4/providers/Microsoft.Compute/virtualMachines/UbuntuLAB",
    "resourceGroup": "LAB_vthot4"
  },
  "storageProfile": {
    "dataDisks": [
      {
        "blobUri": null,
        "caching": "None",
        "diskEncryptionSet": null,
        "diskSizeGb": 128,
        "lun": 0,
        "managedDisk": {
          "id": "/subscriptions/345gc74f-9632-1046-abd3-d26eh134b4et/resourceGroups/LAB_VTHOT4/providers/Microsoft.Compute/disks/myDataDisk",
          "resourceGroup": "LAB_VTHOT4"
        },
        "snapshot": null,
        "storageAccountType": "Premium_LRS"
      }
    ],
    "osDisk": {
      "blobUri": null,
      "caching": "ReadWrite",
      "diskEncryptionSet": null,
      "diskSizeGb": 30,
      "managedDisk": {
        "id": "/subscriptions/345gc74f-9632-1046-abd3-d26eh134b4et/resourceGroups/LAB_VTHOT4/providers/Microsoft.Compute/disks/UbuntuLAB_disk1_965ff0445679042d6ab290d6607c96c813",
        "resourceGroup": "LAB_VTHOT4"
      },
      "osState": "Generalized",
      "osType": "Linux",
      "snapshot": null,
      "storageAccountType": "Premium_LRS"
    },
    "zoneResilient": null
  },
  "tags": {},
  "type": "Microsoft.Compute/images"
}
```


- **Creación de una máquina virtual desde una imagen.**
Vamos a crear una segunda máquina a partir de la imágen creada anteriormente.

```bahs
vthot4@labcell:~/azure_lab$ az vm create --resource-group LAB_vthot4 --name UbuntuLAB2 --image labImage --admin-username vteteam --ssh-key-value ~/.ssh/id_rsa.pub

{
  "fqdns": "",
  "id": "/subscriptions/345gc74f-9632-1046-abd3-d26eh134b4et/resourceGroups/LAB_vthot4/providers/Microsoft.Compute/virtualMachines/UbuntuLAB2",
  "location": "northeurope",
  "macAddress": "00-0D-3A-B2-72-7D",
  "powerState": "VM running",
  "privateIpAddress": "10.0.0.5",
  "publicIpAddress": "25.103.41.125",
  "resourceGroup": "LAB_vthot4",
  "zones": ""
}


```


## Bibliografía
- https://docs.microsoft.com/es-es/azure/virtual-machines/linux/cli-manage
- https://docs.microsoft.com/en-us/azure/virtual-machines/linux/capture-image
