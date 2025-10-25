# 🚀 Maternal Backend - Deployment Package

## 📦 Package Contents

This is a **secure, production-ready deployment package** with **pre-compiled Python code** (.pyc files). No source code is included - only compiled bytecode for intellectual property protection.

## 📁 Directory Structure

```
deployment_package/
├── app/                          # Pre-compiled application (ONLY .pyc files)
│   ├── maternal_backend/         # Core Django app (.pyc)
│   ├── patients/                 # Patients app (.pyc)
│   ├── bot/                      # Chatbot app (.pyc)
│   ├── chatbot_ai/              # AI chatbot (.pyc)
│   ├── ml_models/               # Machine learning models
│   ├── artifacts/               # Training artifacts
│   ├── manage.py                # Django management (needs .py)
│   └── requirements.txt         # Python dependencies
│
├── config/                       # Configuration files
│   ├── Dockerfile.prod          # Production Dockerfile
│   ├── docker-compose.prod.yml  # Docker Compose
│   └── nginx.prod.conf          # Nginx configuration
│
├── scripts/                      # Deployment scripts
│   ├── entrypoint.prod.sh       # Container entrypoint
│   ├── deploy.sh                # Automated deployment
│   ├── manage_deployment.sh     # Management interface
│   └── security_check.py        # Security validator
│
└── Documentation files (.md)
```

## 🔒 Security Features

✅ **Pre-compiled .pyc files** - No source code exposed  
✅ **Non-root container** - Runs as `maternal` user  
✅ **SSL/TLS encryption** - HTTPS only  
✅ **Rate limiting** - DDoS protection  
✅ **Security headers** - HSTS, CSP, X-Frame-Options  
✅ **Password-protected services** - PostgreSQL, Redis  
✅ **Health monitoring** - Automated health checks  

## ⚡ Quick Deployment (5 minutes)

### 1. Prerequisites

```bash
# Verify installations
docker --version       # Requires 20.10+
docker-compose --version  # Requires 2.0+
```

### 2. Configure Environment

```bash
# Copy and edit environment file
cp .env.example .env
nano .env

# Generate secure SECRET_KEY
python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

# Generate database password
openssl rand -base64 32
```

Update `.env` with:
- `SECRET_KEY` (generated above)
- `DB_PASSWORD` (strong password)
- `REDIS_PASSWORD` (strong password)
- `ALLOWED_HOSTS` (your domain)

### 3. SSL Certificates

**For Testing (Self-signed):**
```bash
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/privkey.pem \
  -out ssl/fullchain.pem \
  -subj "/CN=localhost"
```

**For Production (Let's Encrypt):**
```bash
mkdir -p ssl
certbot certonly --standalone -d yourdomain.com
cp /etc/letsencrypt/live/yourdomain.com/* ssl/
chmod 644 ssl/*
```

### 4. Deploy

```bash
# Build and start services
docker-compose -f docker-compose.prod.yml up -d --build

# Check status
docker-compose -f docker-compose.prod.yml ps

# View logs
docker-compose -f docker-compose.prod.yml logs -f
```

### 5. Create Admin User

```bash
docker-compose -f docker-compose.prod.yml exec web python manage.py createsuperuser
```

### 6. Verify Deployment

```bash
# Health check
curl http://localhost/health

# API test
curl https://yourdomain.com/api/

# Check all services
docker-compose -f docker-compose.prod.yml ps
```

## 🔧 Management Commands

### Service Management

```bash
# Start all services
docker-compose -f docker-compose.prod.yml up -d

# Stop all services
docker-compose -f docker-compose.prod.yml down

# Restart specific service
docker-compose -f docker-compose.prod.yml restart web

# View logs
docker-compose -f docker-compose.prod.yml logs -f web
```

### Database Operations

```bash
# Run migrations
docker-compose -f docker-compose.prod.yml exec web python manage.py migrate

# Create backup
docker-compose -f docker-compose.prod.yml exec db pg_dump \
  -U maternal_user maternal_prod > backup_$(date +%Y%m%d).sql

# Restore backup
docker-compose -f docker-compose.prod.yml exec -T db psql \
  -U maternal_user maternal_prod < backup.sql
```

### Application Operations

```bash
# Collect static files
docker-compose -f docker-compose.prod.yml exec web python manage.py collectstatic --noinput

# Django shell
docker-compose -f docker-compose.prod.yml exec web python manage.py shell

# Container shell
docker-compose -f docker-compose.prod.yml exec web bash
```

## 🛠️ Interactive Management

For easier management, use the interactive script:

```bash
cd scripts
./manage_deployment.sh
```

This provides a menu-driven interface for:
- Starting/stopping services
- Viewing logs
- Database operations
- Health checks
- Updates
- And more...

## 📊 Monitoring

### Health Checks

```bash
# Application health
curl http://localhost/health

# Container status
docker-compose -f docker-compose.prod.yml ps

# Database health
docker-compose -f docker-compose.prod.yml exec db pg_isready

# Redis health
docker-compose -f docker-compose.prod.yml exec redis redis-cli ping
```

### Resource Usage

```bash
# Container stats
docker stats

# Disk usage
docker system df

# Logs size
du -sh logs/
```

## 🔄 Updates

To update the application with new compiled code:

```bash
# 1. Stop services
docker-compose -f docker-compose.prod.yml down

# 2. Replace 'app' directory with new compiled version
rm -rf app
# (Copy new compiled app directory here)

# 3. Rebuild and restart
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d

# 4. Run migrations
docker-compose -f docker-compose.prod.yml exec web python manage.py migrate
```

## 🆘 Troubleshooting

### Services Won't Start

```bash
# Check logs
docker-compose -f docker-compose.prod.yml logs

# Check specific service
docker-compose -f docker-compose.prod.yml logs web

# Recreate containers
docker-compose -f docker-compose.prod.yml up -d --force-recreate
```

### Database Connection Issues

```bash
# Test connection
docker-compose -f docker-compose.prod.yml exec web python manage.py dbshell

# Check environment variables
docker-compose -f docker-compose.prod.yml exec web env | grep DB
```

### Permission Issues

```bash
# Fix ownership
docker-compose -f docker-compose.prod.yml exec web chown -R maternal:maternal /app

# Recreate volumes
docker-compose -f docker-compose.prod.yml down -v
docker-compose -f docker-compose.prod.yml up -d
```

### SSL Certificate Issues

```bash
# Check certificate
openssl x509 -in ssl/fullchain.pem -noout -dates

# Test SSL
curl -vI https://yourdomain.com

# Verify nginx config
docker-compose -f docker-compose.prod.yml exec nginx nginx -t
```

## 🔐 Security Checklist

Before production:

- [ ] Strong `SECRET_KEY` configured
- [ ] `DEBUG=False` in .env
- [ ] Strong database passwords
- [ ] SSL certificates installed
- [ ] Domain configured in nginx
- [ ] Firewall configured (only 22, 80, 443)
- [ ] Regular backups scheduled
- [ ] Monitoring set up
- [ ] Admin access restricted

## 📈 Performance Tuning

### Scale Workers

```bash
# Scale to 3 web instances
docker-compose -f docker-compose.prod.yml up -d --scale web=3
```

### Optimize Database

```bash
# Connect to database
docker-compose -f docker-compose.prod.yml exec db psql -U maternal_user maternal_prod

# Run VACUUM
VACUUM ANALYZE;

# Check database size
SELECT pg_size_pretty(pg_database_size('maternal_prod'));
```

## 📞 Support

### Documentation

- `SECURE_DEPLOYMENT_GUIDE.md` - Comprehensive guide
- `QUICK_START.md` - Fast deployment
- `DEPLOYMENT_SUMMARY.md` - Architecture overview

### Getting Help

1. Check logs: `docker-compose -f docker-compose.prod.yml logs -f`
2. Verify health: `curl http://localhost/health`
3. Check status: `docker-compose -f docker-compose.prod.yml ps`
4. Review documentation above

## 🎯 Production Deployment

### Recommended Server Specs

**Minimum:**
- 2 CPU cores
- 4GB RAM
- 20GB disk

**Recommended:**
- 4 CPU cores
- 8GB RAM
- 50GB SSD

### Firewall Setup

```bash
# Ubuntu/Debian with UFW
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw enable
```

### Domain Setup

1. Point A record to server IP
2. Update nginx config with domain
3. Update .env with domain
4. Obtain SSL certificate
5. Restart services

## 📝 Important Notes

1. **This package contains ONLY compiled code** - No .py source files in app/
2. **manage.py remains as .py** - Required by Django for management commands
3. **All sensitive data** must be in .env file
4. **Never commit .env** to version control
5. **Regular backups** are critical for production

## ✅ Verification

After deployment, verify:

```bash
# 1. All containers running
docker-compose -f docker-compose.prod.yml ps

# 2. Health check passes
curl http://localhost/health

# 3. API accessible
curl https://yourdomain.com/api/

# 4. Admin accessible
curl https://yourdomain.com/admin/

# 5. Database connected
docker-compose -f docker-compose.prod.yml exec web python manage.py dbshell

# 6. Redis connected
docker-compose -f docker-compose.prod.yml exec redis redis-cli ping
```

---

## 🎉 Ready for Production!

This deployment package is:
- ✅ Secure (compiled code, hardened configuration)
- ✅ Optimized (caching, connection pooling)
- ✅ Monitored (health checks, logging)
- ✅ Scalable (Docker Compose, resource limits)
- ✅ Production-ready (tested and documented)

**Deploy with confidence!** 🚀

---

**Version**: 1.0.0  
**Last Updated**: October 2025  
**Package Type**: Pre-compiled Deployment  
**Security Level**: Production Hardened

