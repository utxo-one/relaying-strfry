#!/bin/bash

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        --host=*)
            host="${key#*=}"
            shift # past argument=value
            ;;
        *) # unknown option
            shift # past argument
            ;;
    esac
done

config_content=$(cat <<EOM
server {
    server_name $host;
    location / {
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$host;
        proxy_pass http://127.0.0.1:8008;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOM
)

# Write the configuration content to the file
echo "$config_content" | sudo tee /etc/nginx/sites-available/default > /dev/null
