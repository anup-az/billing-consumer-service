#!/bin/bash
#
# Quick Deploy Script
# Runs all setup steps in sequence
#

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "=========================================="
echo "🚀 Quick Deploy Script"
echo "=========================================="
echo ""
echo "This script will:"
echo "  1. Setup GCP infrastructure"
echo "  2. Configure Workload Identity Federation"
echo "  3. Display GitHub Secrets to add"
echo ""
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Step 1: Setup GCP Infrastructure
echo ""
echo "=========================================="
echo "Step 1/2: Setting up GCP Infrastructure"
echo "=========================================="
"${SCRIPT_DIR}/setup-gcp-infrastructure.sh"

# Step 2: Setup Workload Identity
echo ""
echo "=========================================="
echo "Step 2/2: Configuring Workload Identity"
echo "=========================================="
"${SCRIPT_DIR}/setup-workload-identity.sh"

# Summary
echo ""
echo "=========================================="
echo "✅ All Setup Complete!"
echo "=========================================="
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Add all the GitHub Secrets displayed above to:"
echo "   https://github.com/anup-az/billing-consumer-service/settings/secrets/actions"
echo ""
echo "2. Commit and push the deployment configuration:"
echo "   cd ${PROJECT_ROOT}"
echo "   git checkout dev"
echo "   git pull origin dev"
echo "   git checkout -b feature/deployment-setup"
echo "   git add ."
echo "   git commit -m 'feat: Add GCP Cloud Run deployment infrastructure'"
echo "   git push -u origin feature/deployment-setup"
echo ""
echo "3. Create a PR and merge to 'dev' branch"
echo ""
echo "4. Deployment will automatically trigger on merge!"
echo ""
echo "📖 For detailed instructions, see: DEPLOYMENT-GUIDE.md"
echo ""

