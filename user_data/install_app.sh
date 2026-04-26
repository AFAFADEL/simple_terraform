#!/bin/bash
# Log everything to /var/log/user-data.log for easy debugging
exec > /var/log/user-data.log 2>&1

ENVIRONMENT="${environment}"

echo "=== Starting user-data: $(date) ==="

sleep 10

apt-get update -y
apt-get install -y nginx curl unzip || true

mkdir -p /var/www/html
echo "OK" > /var/www/html/health

INSTANCE_ID=$(curl -s --max-time 5 http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || echo "unknown")
AZ=$(curl -s --max-time 5 http://169.254.169.254/latest/meta-data/placement/availability-zone 2>/dev/null || echo "unknown")

cat > /var/www/html/index.html <<HTMLEOF
<!DOCTYPE html>
<html>
<head><title>Web App - $ENVIRONMENT</title></head>
<body>
  <h1>Hello from AWS — $ENVIRONMENT</h1>
  <p>Instance: $INSTANCE_ID</p>
  <p>AZ: $AZ</p>
</body>
</html>
HTMLEOF

cat > /etc/nginx/sites-available/default <<'NGINXEOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html;

    location /health {
        access_log off;
        return 200 "OK\n";
        add_header Content-Type text/plain;
    }

    location / {
        try_files $uri $uri/ =404;
    }
}
NGINXEOF

systemctl enable nginx
systemctl restart nginx

snap install amazon-ssm-agent --classic || true
systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service || true
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service || true

curl -s https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb \
  -o /tmp/amazon-cloudwatch-agent.deb || true

if [ -f /tmp/amazon-cloudwatch-agent.deb ]; then
  dpkg -i /tmp/amazon-cloudwatch-agent.deb || true

  mkdir -p /opt/aws/amazon-cloudwatch-agent/etc

  cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'CWEOF'
{
  "metrics": {
    "append_dimensions": {
      "AutoScalingGroupName": "$${aws:AutoScalingGroupName}"
    },
    "metrics_collected": {
      "mem": { "measurement": ["mem_used_percent"] },
      "disk": { "measurement": ["disk_used_percent"], "resources": ["/"] }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/ec2/nginx/access",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/ec2/nginx/error",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
CWEOF

  /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s || true
fi

echo "=== user-data complete: $(date) ==="