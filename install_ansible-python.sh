#!/bin/bash

set -e

# Detectar la distribución y versión
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_ID=$ID
        VERSION_ID=$VERSION_ID
        echo "Detectado: $DISTRO_ID $VERSION_ID"
    else
        echo "No se pudo detectar la distribución."
        exit 1
    fi
}

install_ubuntu_debian() {
    echo "Actualizando $DISTRO_ID..."
    sudo apt update && sudo apt upgrade -y

    echo "Instalando Python, pip y Ansible..."
    sudo apt install -y python3 python3-pip ansible unzip curl

    echo "Instalando AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -o awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws
}

install_amazonlinux() {
    echo "Actualizando Amazon Linux..."
    sudo dnf update -y || sudo yum update -y

    echo "Instalando Python, pip y Ansible..."
    sudo dnf install -y python3 python3-pip ansible unzip curl || \
    sudo yum install -y python3 python3-pip ansible unzip curl

    echo "Instalando AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -o awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws
}

install_rhel_centos_almalinux_rocky() {
    echo "Actualizando $DISTRO_ID..."
    sudo dnf update -y || sudo yum update -y

    echo "Instalando Python, pip y Ansible..."
    sudo dnf install -y python3 python3-pip ansible unzip curl || \
    sudo yum install -y python3 python3-pip ansible unzip curl

    echo "Instalando AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -o awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws
}

install_sles() {
    echo "Actualizando SLES..."
    sudo zypper refresh
    sudo zypper update -y

    echo "Instalando Python, pip y Ansible..."
    sudo zypper install -y python3 python3-pip ansible unzip curl

    echo "Instalando AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -o awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws
}

# Main
detect_distro

case "$DISTRO_ID" in
    ubuntu|debian)
        install_ubuntu_debian
        ;;
    amzn)
        install_amazonlinux
        ;;
    rhel|centos|rocky|almalinux)
        install_rhel_centos_almalinux_rocky
        ;;
    sles)
        install_sles
        ;;
    *)
        echo "Distribución no soportada: $DISTRO_ID"
        exit 1
        ;;
esac

echo "✅ Instalación completada correctamente."
