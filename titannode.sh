#!/bin/bash

# Цвета текста
LIGHT_GREEN='\033[1;32m'
GREEN='\033[0;32m'
DARK_GREEN='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'  # Нет цвета (сброс цвета)

# Проверка наличия curl и установка, если не установлен
if ! command -v curl &> /dev/null; then
    echo -e "${RED}curl не установлен. Устанавливаем...${NC}"
    sudo apt update
    sudo apt install curl -y
else
    echo -e "${GREEN}curl уже установлен.${NC}"
fi

# Отображение логотипа
curl -s https://raw.githubusercontent.com/GhostNode13/titan/main/logo.sh | bash

# Меню
while true; do
    echo -e "${LIGHT_GREEN}📍 Выберите действие:${NC}"
    echo -e "${CYAN}📦 Установка ноды${NC}"
    echo -e "${CYAN}🔄 Перезапуск ноды${NC}"
    echo -e "${CYAN}👀 Просмотр логов${NC}"
    echo -e "${CYAN}🗑️ Удаление ноды${NC}"
    echo -e "${LIGHT_GREEN}📜  Введите номер действия (или 'q' для выхода):${NC} "
    read choice

    case $choice in
        1)
            echo -e "${GREEN}🖥️ Начинаем установку ноды Titan...${NC}"

            # Проверка Docker
            if command -v docker &> /dev/null; then
                echo -e "${LIGHT_GREEN}✅ Docker уже установлен. Пропускаем установку.${NC}"
            else
                echo -e "${GREEN}🔧 Устанавливаем Docker...${NC}"
                sudo apt remove -y docker docker-engine docker.io containerd runc
                sudo apt install -y apt-transport-https ca-certificates curl software-properties-common lsb-release gnupg2
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt update
                sudo apt install -y docker-ce docker-ce-cli containerd.io
                echo -e "${LIGHT_GREEN}✅ Docker успешно установлен!${NC}"
            fi

            # Проверка Docker Compose
            if command -v docker-compose &> /dev/null; then
                echo -e "${LIGHT_GREEN}✅ Docker Compose уже установлен. Пропускаем установку.${NC}"
            else
                echo -e "${GREEN}🔧 Устанавливаем Docker Compose...${NC}"
                VER=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
                sudo curl -L "https://github.com/docker/compose/releases/download/$VER/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                sudo chmod +x /usr/local/bin/docker-compose
                echo -e "${LIGHT_GREEN}✅ Docker Compose успешно установлен!${NC}"
            fi

            # Добавление пользователя в группу Docker
            if ! groups $USER | grep -q '\bdocker\b'; then
                echo -e "${GREEN}👤 Добавляем текущего пользователя в группу Docker...${NC}"
                sudo groupadd docker
                sudo usermod -aG docker $USER
            else
                echo -e "${LIGHT_GREEN}✅ Пользователь уже находится в группу Docker.${NC}"
            fi

            # Загрузка Docker-образа Titan
            echo -e "${GREEN}📥 Загружаем Docker-образ Titan...${NC}"
            docker pull nezha123/titan-edge

            # Создание директории Titan
            mkdir -p ~/.titanedge

            # Запуск Titan
            docker run --name titan --network=host -d -v ~/.titanedge:/root/.titanedge nezha123/titan-edge

            # Привязка кода идентификации
            echo -e "${CYAN}🔑 Введите ваш Titan identity code:${NC}"
            read identity_code
            docker run --rm -it -v ~/.titanedge:/root/.titanedge nezha123/titan-edge bind --hash="$identity_code" https://api-test1.container1.titannet.io/api/v2/device/binding

            # Заключительное сообщение
            echo -e "${DARK_GREEN}-----------------------------------------------------------------------${NC}"
            echo -e "${CYAN}📋 Команда для проверки логов:${NC}"
            echo "docker logs -f titan"
            echo -e "${DARK_GREEN}-----------------------------------------------------------------------${NC}"
            echo -e "${LIGHT_GREEN}✨ Установка успешно завершена!${NC}"
            sleep 2
            ;;

        2)
            echo -e "${GREEN}🔁 Перезапускаем ноду...${NC}"
            docker restart titan
            echo -e "${LIGHT_GREEN}✅ Нода успешно перезапущена!${NC}"
            sleep 2
            ;;

        3)
            echo -e "${GREEN}📋 Просмотр логов...${NC}"
            docker logs -f titan
            ;;

        4)
            echo -e "${RED}🗑️ Удаляем ноду Titan...${NC}"
            docker stop titan
            docker rm titan
            docker rmi nezha123/titan-edge
            rm -rf ~/.titanedge
            echo -e "${LIGHT_GREEN}✨ Нода Titan успешно удалена!${NC}"
            sleep 2
            ;;

        q)
            echo -e "${CYAN}Выход из программы...${NC}"
            break
            ;;

        *)
            echo -e "${RED}❌ Неверный выбор! Пожалуйста, введите номер от 1 до 4 или 'q' для выхода.${NC}"
            ;;
    esac
done
