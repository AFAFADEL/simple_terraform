🧠 Architecture Explanation (Simple Student Style)

This project is a cloud web application built on AWS. It is designed to be secure, scalable, and highly available.

1. Users (Internet)

Users access the application from the internet using a browser. They do not connect directly to the servers.

2. Application Load Balancer (ALB)

The ALB is the entry point of the system.
It is placed in the public subnet and receives all incoming traffic from users.

Its job is to:

Receive HTTP requests
Distribute traffic across multiple servers (EC2 instances)
Check if servers are healthy
3. EC2 Instances (Application Servers)

The EC2 instances run the application (like Nginx or backend code).

Important points:

They are placed in private subnets
They do not have public IP addresses
They can only be accessed through the Load Balancer
4. Auto Scaling Group (ASG)

The Auto Scaling Group manages the EC2 instances.

It:

Keeps a minimum number of instances running
Adds more instances when traffic increases
Removes instances when traffic decreases

This ensures the system can handle different loads.

5. RDS Database

The RDS (MySQL database) stores the application data.

It is also in a private subnet for security, so it cannot be accessed directly from the internet. Only the EC2 instances can communicate with it.

6. NAT Gateway

The NAT Gateway allows EC2 instances in private subnets to access the internet for updates or package installation.

However, the internet cannot directly access these instances.

7. CloudWatch and SNS (Monitoring)

CloudWatch monitors the system by tracking:

CPU usage
Errors
Application logs

If something goes wrong, SNS sends notifications (like email alerts) to the administrator.

🔄 Request Flow (How it works)
User sends a request from the browser
Request goes to the ALB
ALB forwards it to a healthy EC2 instance
EC2 processes the request
If needed, EC2 communicates with the RDS database
Response is sent back to the user
🧩 Summary

This architecture separates components into public and private layers to improve:

Security
Scalability
High availability
Performance
--------------------
#archeticture of project:
project/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars          ← production
├── dev.tfvars                ← development
├── modules/
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── monitoring/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── user_data/
    └── install_app.sh

    -----------------------------------------
    
#diagram :

<img width="1595" height="1215" alt="manara_task" src="https://github.com/user-attachments/assets/5b244aa6-5916-4870-99c1-561aaa78c5cd" />
------------------------
#output:

<img width="2549" height="1374" alt="Screenshot 2026-04-26 175624" src="https://github.com/user-attachments/assets/0e376813-6012-438e-94e1-0895f83d3381" />
-------------------
vedio:


