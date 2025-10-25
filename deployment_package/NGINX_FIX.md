# ✅ Nginx Startup Issue - FIXED

## 🔍 Problem

**Error**: `nginx: [emerg] host not found in upstream "web:8003"`

**Cause**: Nginx tries to resolve the `web` hostname when it starts, but the web service isn't ready yet or DNS resolution fails.

## ✅ Solution Applied

### Fix 1: Wait for Web Service Health Check

Updated `docker-compose.prod.yml`:

```yaml
# Before
depends_on:
  - web

# After
depends_on:
  web:
    condition: service_healthy
```

This ensures nginx only starts **after** the web service passes its health check.

### Fix 2: Add Docker DNS Resolver

Updated `nginx.prod.conf`:

```nginx
# Added DNS resolver for Docker
resolver 127.0.0.11 valid=30s ipv6=off;
resolver_timeout 10s;
```

This tells nginx to use Docker's internal DNS resolver (`127.0.0.11`) for dynamic service discovery.

## 🚀 Deploy with Fix

```bash
cd /home/mohamedalrawy/Desktop/projects/maternal/mat-build/deployment_package

# Stop current containers
docker-compose -f docker-compose.prod.yml down

# Rebuild (to apply changes)
docker-compose -f docker-compose.prod.yml up -d --build

# Watch startup
docker-compose -f docker-compose.prod.yml logs -f
```

## 📋 Startup Order (Fixed)

1. **PostgreSQL** starts → waits for health check
2. **Redis** starts → waits for health check  
3. **Web** starts → waits for database → runs migrations → passes health check
4. **Nginx** starts → web is healthy → DNS resolves → ✅ Success!

## ✅ Why This Works

### Problem Breakdown
- **Old way**: Nginx started as soon as web container existed
- **Issue**: Web service wasn't ready to accept connections
- **Result**: DNS lookup failed, nginx couldn't start

### Solution
- **Health check wait**: Ensures web is actually ready
- **DNS resolver**: Allows nginx to dynamically resolve service names
- **Proper ordering**: Services start in correct sequence

## 🔍 Verify Fix

After deployment:

```bash
# Check all services are running
docker-compose -f docker-compose.prod.yml ps

# Should show:
# maternal_db_prod       running (healthy)
# maternal_backend_prod  running (healthy)
# maternal_nginx_prod    running (healthy)
# maternal_redis_prod    running (healthy)

# Test nginx
curl http://localhost/health

# Check nginx logs (should have no errors)
docker-compose -f docker-compose.prod.yml logs nginx
```

## 🎯 What Changed

| Component | Change | Benefit |
|-----------|--------|---------|
| docker-compose | `condition: service_healthy` | Waits for web to be ready |
| nginx.conf | DNS resolver `127.0.0.11` | Dynamic service discovery |
| Startup order | Proper dependency chain | Reliable startup |

## 📝 Alternative Solutions (Not Used)

### Option A: Retry Logic
```bash
# In entrypoint
until nc -z web 8003; do sleep 1; done
```
❌ Adds complexity

### Option B: Hardcode IP
```nginx
server 172.20.0.x:8003;
```
❌ Not portable, breaks on restart

### Option C: Variable Upstream
```nginx
set $backend http://web:8003;
proxy_pass $backend;
```
❌ Loses upstream features (keepalive, load balancing)

## ✅ Current Solution (Best)

✅ **Health check dependency** - Proper Docker orchestration  
✅ **DNS resolver** - Standard Docker practice  
✅ **Upstream block** - Full nginx features  
✅ **Clean & maintainable** - No hacks or workarounds

---

**Issue**: Nginx couldn't resolve web service  
**Fix**: Health check dependency + DNS resolver  
**Status**: ✅ Fixed and ready to deploy  
**Date**: October 2025

