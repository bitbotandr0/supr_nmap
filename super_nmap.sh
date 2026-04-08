#!/bin/bash

#Función para verificar si un paquete está instalado
check_install() {
    dpkg -s "$1" &> /dev/null || {
        echo "Instalando $1..."
       sudo apt install "$1" -y
    }
}

#Verificar e instalar dependencias necesarias
check_install ruby
check_install figlet
check_install lolcat

clear

# Función para mostrar el spinner durante 5 segundos
function mostrar_spinner() {
    local caracteres="☕💶💵😁😀😍"  # Caracteres para el spinner
    local i=0
    local duracion=5  # Duración en segundos

    while [[ $duracion -gt 0 ]]; do
        echo -ne "\r${caracteres:$i:1} Cargando..."
        sleep 0.5
        ((i = (i + 1) % ${#caracteres}))
        ((duracion--))
    done
}

colors () {

echo -e "$1" | lolcat

}


# Mensaje sobre donaciones y sostenibilidad
function mostrar_mensaje_donacion() {
    colors "\n¡Gracias por usar este script! Si encuentras útil esta herramienta, considera hacer una donación para mantener el proyecto.\n"
}

# Llama a la función para mostrar el spinner
mostrar_spinner

# Muestra el mensaje de donación al finalizar
mostrar_mensaje_donacion

#Mensajes de bienvenida
colors "$(figlet -f big 'Nmap')"
colors "$(figlet 'For_Routers')"



# Obtener la dirección IP de la puerta de enlace (router)
gateway_ip=$(ip route | awk '/default/ {print $3}')

# Extraer la parte inicial de la dirección IP (antes del último punto)
ip_prefix=${gateway_ip%.*}

# Construir la nueva dirección IP de la puerta de enlace sin /24
new_gateway_ip="$ip_prefix.1"

# Construir la nueva dirección IP de la puerta de enlace con /24
new_gateway_ip_with_subnet="$new_gateway_ip/24"

colors "La dirección IP de la puerta de enlace es: $new_gateway_ip"

# Crear un array para las opciones del menú
opciones=("1._Escanear Puertos" "2._Detectar Sistemas Activos" "3._Detectar Servicios" "4._Detectar Sistemas Operativos" "5._Escanear Vulnerabilidades" "6._Escanear Todo rango de Direcciones IP" "7._Buscar Malware" "8._Escaneo Zombie" "Salir")
colors "algunas funciones tomarán tiempo, esto es normal"
colors "también para el funcionamiento de algunas funciones"
colors "necesita ser usuario root"
# Crear bucle con select
select opcion in "${opciones[@]}"; do
    case $opcion in
        "1._Escanear Puertos")
            colors "Escaneando puertos de la IP $new_gateway_ip"
            nmap -p 1-65535 "$new_gateway_ip"
            ;;
        "2._Detectar Sistemas Activos")
            colors "Escaneando"
            nmap -sn "$new_gateway_ip_with_subnet"
            ;;
        "3._Detectar Servicios")
            colors "Escaneando servicios..."
            nmap -sV "$new_gateway_ip"
            ;;
        "4._Detectar Sistemas Operativos")
            colors "Detectando sistemas operativos..."
            nmap -O "$new_gateway_ip_with_subnet"
            ;;
        "5._Escanear Vulnerabilidades")
            colors "Escaneando Vulerabilidades"
            colors "de la puerta de enlace"
            nmap -v -sS -sC -sV -T5 --script=vuln "$new_gateway_ip"
            ;;
        "6._Escanear Todo rango de Direcciones IP")
            colors "Escaneando toda la red"
            nmap -v -sS -sC -sV -T5 --script=vuln  "$new_gateway_ip/24"
            ;;
        "7._Buscar Malware")
            colors "en busqueda de posible malware en la puerta de enlace"
            nmap --script http-malware-host "$new_gateway_ip"
            ;;
        "8._Escaneo Zombie")
            read -p "ingrese la ip que servirá de zombie : " zombie
            colors  "escaneando"
            nmap  sI "$zombie"  "$new_gateway_ip"      
            ;;
        "Salir")
            break
            ;;
        *)
            colors "Opción no válida"
            ;;
    esac
done
