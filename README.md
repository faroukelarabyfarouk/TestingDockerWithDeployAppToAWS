# Docker Swarm Auto Scaling Lab

Node.js application deployed using Docker Swarm with Nginx and MongoDB.

The project also includes CPU-based autoscaling and k6 load testing.

## Architecture

```text
k6 / Users
    |
    v
  Nginx
    |
    v
Docker Swarm
    |
    +-- Node.js Replicas
    |
    +-- MongoDB

docker stats
    |
    v
Autoscaler
    |
    v
Docker Swarm Scaling
