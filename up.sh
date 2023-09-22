#!/bin/bash
# Comprueba si existe el fichero .env y .services
test ! -f ./.env && { echo -e "\033[0;31m[ERROR]\033[0m No existe el fichero .env. Saliendo.." ; exit; }
test ! -f ./.services && { echo -e "\033[0;31m[ERROR]\033[0m No existe el fichero .services. Saliendo.." ; exit; }
# Carga las variables de entorno del fichero .env
set -o allexport && source ./.env && source ./.services && set +o allexport
# Función para recorrer carpetas y ejecutar stash pop, drop y pull
function recorrer_y_stash_pull() {
  for carpeta in "${SERVER_PATH}/www/*"; do
    if [ -d "$carpeta/.git" ]; then
        # Muestra un mensaje de pull
        echo "Git Pull realizado en $carpeta." 
        # Ejecuta el pull rebase para actualizar el repositorio
        git pull --rebase 
        # Ejecuta el stash pop y drop para actualizar y eliminar los cambios locales
        git stash pop
        git stash drop
    fi
  done
}


# Muestra un mensaje de pull
echo "Git Pull realizado." 
# Ejecuta el pull rebase para actualizar el repositorio
git pull --rebase 
# Ejecuta el stash pop y drop para actualizar y eliminar los cambios locales
git stash pop
git stash drop
recorrer_y_stash_pull
# Ejecuta el docker compose
echo -e "\033[0;32m[INFO]\033[0m Arrancando los servicios: ${SERVICES[@]}"
exec docker compose up -d "$@" "${SERVICES[@]}"