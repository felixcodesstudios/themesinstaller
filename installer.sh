#!/bin/bash

# Colores para la interfaz
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Función para mostrar el banner
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "======================================================"
    echo "████████╗██╗░░██╗███████╗███╗░░░███╗███████╗░██████╗"
    echo "╚══██╔══╝██║░░██║██╔════╝████╗░████║██╔════╝██╔════╝"
    echo "░░░██║░░░███████║█████╗░░██╔████╔██║█████╗░░╚█████╗░"
    echo "░░░██║░░░██╔══██║██╔══╝░░██║╚██╔╝██║██╔══╝░░░╚═══██╗"
    echo "░░░██║░░░██║░░██║███████╗██║░╚═╝░██║███████╗██████╔╝"
    echo "░░░╚═╝░░░╚═╝░░╚═╝╚══════╝╚═╝░░░░░╚═╝╚══════╝╚═════╝░"
    echo "======================================================"
    echo -e "${NC}"
}

# Función para mostrar mensajes de progreso
show_progress() {
    echo -e "${GREEN}[✓]${NC} $1"
}

show_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

show_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Función para instalar Reviactyl
install_reviactyl() {
    echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}           INSTALANDO REVIACTYL 🦖${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
    
    # Verificar si estamos en el directorio correcto
    if [ ! -d "/var/www/pterodactyl" ]; then
        show_error "El directorio /var/www/pterodactyl no existe"
        exit 1
    fi
    
    # Paso 1: Navegar y limpiar directorio
    show_warning "Paso 1/6: Limpiando directorio existente..."
    cd /var/www/pterodactyl
    rm -rf *
    show_progress "Directorio limpiado correctamente"
    
    # Paso 2: Descargar el tema
    show_warning "Paso 2/6: Descargando Reviactyl..."
    curl -Lo panel.tar.gz https://github.com/reviactyl/panel/releases/latest/download/panel.tar.gz
    if [ $? -eq 0 ]; then
        show_progress "Tema descargado correctamente"
    else
        show_error "Error al descargar el tema"
        exit 1
    fi
    
    # Paso 3: Extraer archivos
    show_warning "Paso 3/6: Extrayendo archivos..."
    tar -xzvf panel.tar.gz
    show_progress "Archivos extraídos correctamente"
    
    # Paso 4: Configurar permisos
    show_warning "Paso 4/6: Configurando permisos..."
    chmod -R 755 storage/* bootstrap/cache/
    show_progress "Permisos configurados correctamente"
    
    # Paso 5: Instalar dependencias de Composer
    show_warning "Paso 5/6: Instalando dependencias de Composer..."
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader
    if [ $? -eq 0 ]; then
        show_progress "Dependencias instaladas correctamente"
    else
        show_error "Error al instalar dependencias"
        exit 1
    fi
    
    # Paso 6: Migrar base de datos
    show_warning "Paso 6/6: Migrando base de datos..."
    php artisan migrate --seed --force
    if [ $? -eq 0 ]; then
        show_progress "Base de datos migrada correctamente"
    else
        show_error "Error al migrar la base de datos"
        exit 1
    fi
    
    # Paso 7: Configurar propietario
    show_warning "Configurando propietario de archivos..."
    chown -R www-data:www-data /var/www/pterodactyl/*
    show_progress "Propietario configurado correctamente"
    
    # Paso 8: Reiniciar servicio
    show_warning "Reiniciando servicio pteroq..."
    systemctl restart pteroq.service
    show_progress "Servicio reiniciado correctamente"
    
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}¡INSTALACIÓN COMPLETADA EXITOSAMENTE! 🎉${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Recomendaciones:${NC}"
    echo -e "1. Limpia la caché del panel con: ${CYAN}php artisan optimize:clear${NC}"
    echo -e "2. Verifica el estado del servicio: ${CYAN}systemctl status pteroq.service${NC}"
    echo -e "3. Accede a tu panel para ver los cambios"
    echo ""
}

# Función principal del menú
main_menu() {
    while true; do
        show_banner
        
        echo -e "${WHITE}╔════════════════════════════════════════════╗${NC}"
        echo -e "${WHITE}║          MENÚ PRINCIPAL - THEME GSM        ║${NC}"
        echo -e "${WHITE}╠════════════════════════════════════════════╣${NC}"
        echo -e "${WHITE}║                                            ║${NC}"
        echo -e "${WHITE}║  ${CYAN}1)${NC} ${GREEN}Instalar Reviactyl 🦖${NC}                 ${WHITE}║${NC}"
        echo -e "${WHITE}║  ${CYAN}2)${NC} ${YELLOW}Verificar directorio${NC}                 ${WHITE}║${NC}"
        echo -e "${WHITE}║  ${CYAN}3)${NC} ${RED}Salir${NC}                               ${WHITE}║${NC}"
        echo -e "${WHITE}║                                            ║${NC}"
        echo -e "${WHITE}╚════════════════════════════════════════════╝${NC}"
        echo ""
        
        read -p "$(echo -e ${CYAN}"Selecciona una opción [1-3]: "${NC})" option
        
        case $option in
            1)
                echo ""
                read -p "$(echo -e ${YELLOW}"¿Estás seguro de instalar Reviactyl? (s/n): "${NC})" confirm
                if [[ $confirm == "s" || $confirm == "S" ]]; then
                    install_reviactyl
                    read -p "$(echo -e ${CYAN}"Presiona Enter para continuar..."${NC})"
                else
                    echo -e "${YELLOW}Instalación cancelada${NC}"
                    sleep 1
                fi
                ;;
            2)
                echo ""
                echo -e "${CYAN}Verificando directorio /var/www/pterodactyl...${NC}"
                if [ -d "/var/www/pterodactyl" ]; then
                    echo -e "${GREEN}✓ Directorio existe${NC}"
                    ls -la /var/www/pterodactyl/
                else
                    echo -e "${RED}✗ Directorio no existe${NC}"
                fi
                echo ""
                read -p "$(echo -e ${CYAN}"Presiona Enter para continuar..."${NC})"
                ;;
            3)
                echo ""
                echo -e "${GREEN}¡Hasta luego! 👋${NC}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "${RED}Opción inválida. Intenta de nuevo.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Verificar si se ejecuta como root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Este script debe ejecutarse como root/sudo${NC}"
    exit 1
fi

# Iniciar el menú principal
main_menu
