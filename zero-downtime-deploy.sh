#!/bin/sh

# Nginx 설정 경로 (Nginx 컨테이너 내부의 경로)
NGINX_CONF="/etc/nginx/conf.d/port-forwarding.conf"

# Nginx 컨테이너 이름
NGINX_CONTAINER="nginx"

# 새 컨테이너 이름
BLUE_CONTAINER="zdt-prac.blue"
GREEN_CONTAINER="zdt-prac.green"

# 헬스체크 URL
BLUE_URL="http://localhost:8080/api/test"
GREEN_URL="http://localhost:8081/api/test"

# 헬스체크 수행
BLUE_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" $BLUE_URL || echo "500")
GREEN_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" $GREEN_URL || echo "500")

# 상태 출력
echo "Blue health status: $BLUE_HEALTH"
echo "Green health status: $GREEN_HEALTH"

# Blue와 Green 상태 확인 및 Nginx 설정 업데이트
if [ "$BLUE_HEALTH" = "200" ] && [ "$GREEN_HEALTH" != "200" ]; then
    echo "Blue environment is healthy. Deploying Green."
    sh green_deploy.sh

    # Green 컨테이너 헬스 상태 확인
    echo "Waiting for Green container to become healthy..."
    MAX_RETRIES=10
    RETRY_COUNT=0
    GREEN_HEALTH="500"

    while [ "$GREEN_HEALTH" != "200" ] && [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        sleep 10  # 헬스체크 간격
        GREEN_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" $GREEN_URL || echo "500")
        RETRY_COUNT=$((RETRY_COUNT + 1))
        echo "Retry $RETRY_COUNT: Green health status: $GREEN_HEALTH"
    done

    if [ "$GREEN_HEALTH" != "200" ]; then
        echo "Green container did not become healthy. Aborting..."
        exit 1
    fi

    echo "Green container is healthy. Switching traffic to Green."

    # Nginx 설정에서 upstream 수정
    docker exec $NGINX_CONTAINER sed -i 's|server zdt-prac.blue:8080;|server zdt-prac.green:8080;|' $NGINX_CONF
    echo "Updated Nginx configuration to Green."

    if ! docker exec $NGINX_CONTAINER nginx -t; then
        echo "Nginx configuration test failed. Aborting..."
        exit 1
    fi

    docker exec $NGINX_CONTAINER nginx -s reload

    docker stop $BLUE_CONTAINER
    docker rm $BLUE_CONTAINER

elif [ "$BLUE_HEALTH" != "200" ] && [ "$GREEN_HEALTH" = "200" ]; then
    echo "Green environment is healthy. Deploying Blue."
    sh blue_deploy.sh

    # Blue 컨테이너 헬스 상태 확인
    echo "Waiting for Blue container to become healthy..."
    MAX_RETRIES=10
    RETRY_COUNT=0
    BLUE_HEALTH="500"

    while [ "$BLUE_HEALTH" != "200" ] && [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        sleep 10  # 헬스체크 간격
        BLUE_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" $BLUE_URL || echo "500")
        RETRY_COUNT=$((RETRY_COUNT + 1))
        echo "Retry $RETRY_COUNT: Blue health status: $BLUE_HEALTH"
    done

    if [ "$BLUE_HEALTH" != "200" ]; then
        echo "Blue container did not become healthy. Aborting..."
        exit 1
    fi

    echo "Blue container is healthy. Switching traffic to Blue."

    # Nginx 설정에서 upstream 수정
    docker exec $NGINX_CONTAINER sed -i 's|server zdt-prac.green:8080;|server zdt-prac.blue:8080;|' $NGINX_CONF
    echo "Updated Nginx configuration to Blue."

    if ! docker exec $NGINX_CONTAINER nginx -t; then
        echo "Nginx configuration test failed. Aborting..."
        exit 1
    fi

    docker exec $NGINX_CONTAINER nginx -s reload

    docker stop $GREEN_CONTAINER
    docker rm $GREEN_CONTAINER

elif [ "$BLUE_HEALTH" = "200" ] && [ "$GREEN_HEALTH" = "200" ]; then
    echo "Both environments are healthy. Defaulting to Blue."
    docker exec $NGINX_CONTAINER sed -i 's|server zdt-prac.green:8080;|server zdt-prac.blue:8080;|' $NGINX_CONF

    if ! docker exec $NGINX_CONTAINER nginx -t; then
        echo "Nginx configuration test failed. Aborting..."
        exit 1
    fi

    docker exec $NGINX_CONTAINER nginx -s reload

    docker stop $GREEN_CONTAINER
    docker rm $GREEN_CONTAINER

else
    echo "No environment is healthy. Let's Compose"
    sh deploy.sh
fi

echo "Deployment process completed successfully."
