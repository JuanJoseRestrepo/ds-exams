#!/bin/bash


if [ $(vagrant status | grep "not created" | wc -l) -ge 1 ]; then

echo -e "Todavia faltan maquinas para que esten arriba"

else

# Definir la ruta base de las máquinas de Vagrant
VAGRANT_DIR="./.vagrant/machines/web-"
DATABASE_DIR="./.vagrant/machines/database"
# Iterar por cada máquina de Vagrant
for i in {1..3}; do
    MACHINE="web-$i"
    MACHINE_DIR="$VAGRANT_DIR$i/virtualbox"
    DATABASE_MACHINE="$DATABASE_DIR/virtualbox"
    MACHINE_MASTER="database"
    # Verificar si existe el archivo de llave privada
    if [ -f "$MACHINE_DIR/private_key" ] || [ -f "$DATABASE_MACHINE/private_key" ] ; then
        PRIVATE_KEY="$MACHINE_DIR/private_key"
        PRIVATE_KEY_DATABASE="$DATABASE_MACHINE/private_key"
        echo "$PRIVATE_KEY_DATABASE"
	if [ "$i" -eq 3 ]; then
	 ssh -i "$PRIVATE_KEY_DATABASE" -o StrictHostKeyChecking=no -y vagrant@"$MACHINE_MASTER" "sudo gluster peer probe web-1; sudo gluster peer probe web-2; sudo gluster pool list; sudo gluster volume create gv0 replica 3 database:/gluster/data/gv0 web-1:/gluster/data/gv0 web-2:/gluster/data/gv0; sudo gluster volume start gv0; sudo gluster volume status; sudo mount.glusterfs database:/gv0 /mnt"
	else
	
	ssh -i "$PRIVATE_KEY" -o StrictHostKeyChecking=no -y vagrant@"$MACHINE"	"sudo mount.glusterfs localhost:/gv0 /mnt"

	fi
        echo "Máquina: $MACHINE"
        echo "Llave privada: $PRIVATE_KEY"
        echo ""
    else
        echo "No se encontró la llave privada para la máquina $MACHINE"
    fi
done

fi
