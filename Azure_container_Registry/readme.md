# Azure Container Registry (ACR).

Azure Container Registry es un servicio privado administrado del Registro de Docker que usa Docker Registry 2.0, que es de código abierto. Cree y mantenga los registros de Azure Container para almacenar y administrar las imágenes privadas del contenedor Docker y los artefactos relacionados. Los casos de uso que nos proponen en su documentación son:

- Sistemas escalables de orquestación que administran aplicaciones en contenedores a través de clústeres de hosts, incluidos Kubernetes, DC/OS y Docker Swarm.
- Los Servicios de Azure que admiten la compilación y ejecución de aplicaciones a escala como AKS, App Service, Batch, Service Fabric ....

Azure proporciona varias herramientas, entre las que se incluyen la Interfaz de la línea de comandos de Azure, Azure Portal y soporte de API para administrar los registros de contenedor de Azure.

Las principales características que presenta:

- **SKU de registro.**  Los registros están disponibles en tres SKU: [Basic, Standard y Premium](https://docs.microsoft.com/es-es/azure/container-registry/container-registry-skus), cada una de las cuales admite la integración de webhook, la autenticación del registro con Azure Active Directory y la funcionalidad de eliminación.
- **Seguridad y acceso.** Podemos iniciar sesión en un registro mediante la CLI de Azure o el comando `docker login` estándar. Azure Container Registry transfiere imágenes de contenedor a través de HTTPS y admite TLS para proteger las conexiones de cliente. Podemos [controlar el acceso](https://docs.microsoft.com/es-es/azure/container-registry/container-registry-authentication) a un registro de contenedor mediante una identidad de Azure, una [entidad de servicio](https://docs.microsoft.com/es-es/azure/active-directory/develop/app-objects-and-service-principals) respaldada por Azure Active Directory o una cuenta de administrador proporcionada. Use el control de acceso basado en rol (RBAC) para asignar a los usuarios o sistemas permisos específicos para un registro.
- **Imágenes y artefactos compatibles.** todas las imágenes se almacenan en un repositorio y cada de ellas es una instantánea de solo lectura de un contenedor compatible con Docker. Los registros de contenedor de Azure pueden incluir imágenes de Windows y de Linux. Además de las imágenes de contenedor de Docker, Azure Container Registry almacena los [formatos de contenido relacionados](https://docs.microsoft.com/es-es/azure/container-registry/container-registry-image-formats), como los [gráficos de Helm](https://docs.microsoft.com/es-es/azure/container-registry/container-registry-helm-repos) y las imágenes creadas para la [especificación de formato de imagen de Open Container Initiative (OCI)](https://github.com/opencontainers/image-spec/blob/master/spec.md).
- **Compilaciones de imágenes automatizadas.** usaremos [Azure Container Registry Tasks](https://docs.microsoft.com/es-es/azure/container-registry/container-registry-tasks-overview) (ACR Tasks) para simplificar la creación, prueba, inserción e implementación de imágenes en Azure.



## LAB. Creando nuestro primer ACR.

En el presente lab vamos a ver como trabajar con este componente de Azure. Para ello necesitaremos tener instalado el CLI de azure y docker. Los pasos a seguir para completar el LAB serán:

1. Crear un grupo de Recursos.
2. Crear un Registro de Contenedor.
3. Iniciamos sesión e inserción de una nueva imagen.
4. Ejecución de la imagen desde el registro.
5. Limpieza de los recursos desplegados.

























## Bibliografía

- https://docs.microsoft.com/es-es/azure/container-registry/