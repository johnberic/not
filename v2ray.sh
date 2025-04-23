#!/bin/bash

# Generate JSON array for client credentials
#!/bin/bash
if ! diff -q /etc/authorization/pandavpnunite/uuid.sh /etc/authorization/pandavpnunite/prev_uuid.sh >/dev/null; then
    echo "Active not match."
    client_array="["
    while IFS= read -r uuid; do
        # Trim any leading/trailing whitespace from the UUID
        uuid=$(echo "$uuid" | awk '{$1=$1};1')

        # Append the uuid
        client_array+="{\"id\": \"$uuid\", \"alterId\": 64}, "
    done < /etc/authorization/pandavpnunite/uuid.sh
    client_array="${client_array%, }]"  # Remove trailing comma and add closing bracket

    # Update V2Ray configuration file with the client array

    #echo $client_array
    cp /usr/local/etc/v2ray/default-config.json /usr/local/etc/v2ray/config.json
    sed -i "s/\"clients\": \[\]/\"clients\": $client_array/" /usr/local/etc/v2ray/config.json
    cp /etc/authorization/pandavpnunite/uuid.sh /etc/authorization/pandavpnunite/prev_uuid.sh
    sudo systemctl restart v2ray

fi