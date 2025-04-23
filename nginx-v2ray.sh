server {
  listen 85;
  server_name    167.172.80.129;

  index index.html;
  root /usr/share/nginx/html/;

  access_log /var/log/nginx/v2ray.access;
  error_log /var/log/nginx/v2ray.error;

    location /ray { # Consistent with the path of V2Ray configuration
      if ($http_upgrade != "websocket") { # Return 404 error when WebSocket upgrading negotiate failed
          return 404;
      }
      proxy_redirect off;
      proxy_pass http://127.0.0.1:10000; # Assume WebSocket is listening at localhost on port of 10000
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_set_header Host $host;
      # Show real IP in v2ray access.log
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}