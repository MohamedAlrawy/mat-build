#!/bin/bash
# Script to organize deployment files

echo "Organizing deployment package..."

# Create directory structure
mkdir -p app/{maternal_backend,patients,bot,chatbot_ai,ml_models,artifacts}
mkdir -p config
mkdir -p scripts

# Copy compiled application code from build_secure
echo "Copying compiled application code..."
cp -r ../build_secure/maternal_backend/*.pyc app/maternal_backend/ 2>/dev/null || true
cp -r ../build_secure/patients/*.pyc app/patients/ 2>/dev/null || true
cp -r ../build_secure/patients/management app/patients/ 2>/dev/null || true
cp -r ../build_secure/patients/migrations app/patients/ 2>/dev/null || true
cp -r ../build_secure/patients/neonatal app/patients/ 2>/dev/null || true
cp -r ../build_secure/patients/cs app/patients/ 2>/dev/null || true
cp -r ../build_secure/patients/pph app/patients/ 2>/dev/null || true

cp -r ../build_secure/bot/*.pyc app/bot/ 2>/dev/null || true
cp -r ../build_secure/bot/management app/bot/ 2>/dev/null || true
cp -r ../build_secure/bot/migrations app/bot/ 2>/dev/null || true

cp -r ../build_secure/chatbot_ai/*.pyc app/chatbot_ai/ 2>/dev/null || true
cp -r ../build_secure/chatbot_ai/management app/chatbot_ai/ 2>/dev/null || true
cp -r ../build_secure/chatbot_ai/migrations app/chatbot_ai/ 2>/dev/null || true

# Copy manage.py (needs to remain as .py)
cp ../manage.py app/

# Copy ML models and artifacts
echo "Copying ML models..."
cp -r ../ml_models/* app/ml_models/ 2>/dev/null || true
cp -r ../artifacts/* app/artifacts/ 2>/dev/null || true

# Copy requirements
cp ../requirements.txt app/

# Copy deployment configurations
echo "Copying deployment configurations..."
cp ../Dockerfile.prod config/
cp ../docker-compose.prod.yml config/
cp ../nginx.prod.conf config/
cp ../.env.example config/
cp ../.gitignore config/

# Copy deployment scripts
echo "Copying deployment scripts..."
cp ../entrypoint.prod.sh scripts/
cp ../deploy.sh scripts/
cp ../manage_deployment.sh scripts/
cp ../security_check.py scripts/

# Copy documentation
echo "Copying documentation..."
cp ../SECURE_DEPLOYMENT_GUIDE.md .
cp ../QUICK_START.md .
cp ../README_SECURE_DEPLOYMENT.md README.md
cp ../DEPLOYMENT_SUMMARY.md .
cp ../FILES_CREATED.md .

# Make scripts executable
chmod +x scripts/*.sh
chmod +x scripts/*.py

echo "✓ Deployment package organized!"
echo ""
echo "Structure:"
tree -L 2 -I '__pycache__' || ls -R

