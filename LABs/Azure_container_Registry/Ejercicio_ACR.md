# Ejercicio: Implementación de Azure Container Registry

Source: https://docs.microsoft.com/es-es/learn/modules/build-and-store-container-images/2-deploy-azure-container-registry

En el enlace anterior nos enseñan a realizar un lab sencillo que consta de los siguientes pasos:

1. Creación de una instancia de Azure Container Registry.
2. Creación de una imagen de contenedor con Azure Container Registry Tasks.
3. Comprobación de la imagen.
4. Habilitación de la cuenta de administrador del registro.
5. Implementación de un contenedor con la CLI de Azure.
6. Cree una región replicada para una instancia de Azure Container Registry.
7. Limpieza de recursos.

ToDo ---> Explicación completa del ejemplo.

Aunque no he tenido tiempo de transcribir el lab, si que he procedido a crear un script que nos permitirá ejecutar todas las fases descritas menos la de replicación. 

```bash
vthot4@labcell:~/azure_lab/LABs/Azure_container_Registry$ ./acr_lab.sh 

./acr_lab.sh usage:

  create      Creación Grupo de recursos y Registro de contenedores
  image       Creamos la imagen y la subimos al repositorio
  example     Habilita las cuentas de administración y lanza el contenedor en azure,recogemos IP para la prueba
  delete      Borra el grupo de recursos
```
El script es el siguiente:

```bash
#!/bin/bash
#################################################################################
##
##  Name: acr_lab.sh
##  Version: 0.1
##  Description: Azure Container Registry lab
##  source: https://docs.microsoft.com/es-es/learn/modules/build-and-store-container-images/2-deploy-azure-container-registry
##
##################################################################################

#---------
LOGFILE="acr_lab.log"

AZ_RESOURCE="LAB_vthot4"  ##  Conjunto de recursos
AZ_ACR_NAME="acrlab"
AZ_LOCATION="northeurope"
AZ_AZR_USER="vthot4"

log(){
    echo `date +%R:%S"-"%d%m%Y`" " "$1" |tee -a $LOGFILE
}

## Creamos un grupo de recursos con el nombre que queramos para que sea más fácil limpiar el escenario cuando terminemos el lab.
##  $ az group create --name learn-deploy-acr-rg --location <choose-a-location>
##

exist_commad()
{
    if ! type "$1" > /dev/null; then 
        echo " "
        log "En necesario instalar $1"
        echo " "
        exit 1
    fi
}

help(){
    echo ""
    echo "$0 usage:"
    echo ""
    echo "  create      Creación Grupo de recursos y Registro de contenedores"
    echo "  image       Creamos la imagen y la subimos al repositorio"
    echo "  example     Habilita las cuentas de administración y lanza el contenedor en azure,recogemos IP para la prueba"
    echo "  delete      Borra el grupo de recursos"
    echo ""
}



case "$1" in

    create)
        exist_commad "az"
        log " Creando grupo de recursos."
        az group create --name $AZ_RESOURCE --location $AZ_LOCATION
        ## Creamos el registro del contenedor 
        log " Creando el docker regsitry"
        az acr create --resource-group $AZ_RESOURCE --name $AZ_ACR_NAME --sku Premium
        ;;
    
    image)
        log "Creamos el Dockerfile para la prueba ....."
        echo " FROM    node:9-alpine"> Dockerfile
        echo " ADD     https://raw.githubusercontent.com/Azure-Samples/acr-build-helloworld-node/master/package.json /" >> Dockerfile
        echo " ADD     https://raw.githubusercontent.com/Azure-Samples/acr-build-helloworld-node/master/server.js /" >> Dockerfile
        echo " RUN     npm install" >> Dockerfile
        echo " EXPOSE  80" >> Dockerfile
        echo " CMD     ["node", "server.js"] " >> Dockerfile
        
        ## Creamos la imágen en el registro
        log "Creamos la imagen en el registry"
        az acr build --registry $AZ_ACR_NAME --image helloacrtasks:v1 .

        ## Comprobamos que la imágen existe
        log " comprobamos que laimágen existe"
        az acr repository list --name $AZ_ACR_NAME --output table
        ;;

    example)
        ## habilitamos la cuenta de administrador del registro
        az acr update -n $AZ_ACR_NAME --admin-enabled true

        ## Recuperamos el nombre de usuario y claves
        passsword=$(az acr credential show --name $AZ_ACR_NAME |jq '.passwords[0] .value'|grep -v null|sed -e 's/^.//' -e 's/.$//')
        
        ##echo $passsword

        ## Lanzamos el container de pruebas
        log "creamos un contenedor de pruebas"
        az container create \
        --resource-group $AZ_RESOURCE \
        --name acr-tasks \
        --image $AZ_ACR_NAME.azurecr.io/helloacrtasks:v1 \
        --registry-login-server $AZ_ACR_NAME.azurecr.io \
        --ip-address Public \
        --location $AZ_LOCATION \
        --registry-username $AZ_AZR_USER \
        --registry-password $passsword

        ## Obtenemos la IP pública de pruebas.
        ##az container show --resource-group  $AZ_RESOURCE--name acr-tasks --query ipAddress.ip --output table
        az container show --resource-group  $AZ_RESOURCE --name acr-tasks --query ipAddress.ip --output table
        ;;

    delete)
        log " Eiminando grupo de recursos $AZ_RESOURCE"
        az group delete --name $AZ_RESOURCE
        ;;
    
    *)
        help
        ;;

esac

```

