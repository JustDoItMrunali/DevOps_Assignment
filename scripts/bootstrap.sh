#!/bin/bash
set -e  # Exit immediately on error

echo "=== DevOps Assignment Bootstrap Script ==="
echo "Roll Number: ITB745"
echo ""

# ------------------------------------------------------------------
# STEP 1: Terraform — Infrastructure provisioning (AWS)
# ------------------------------------------------------------------
echo "[1/4] 🚀 Running Terraform..."
cd terraform
terraform init -input=false
terraform apply -auto-approve -input=false

echo "✅ Terraform completed successfully!"
echo ""

# ------------------------------------------------------------------
# STEP 2: Extract generated instance IPs from Terraform outputs
# ------------------------------------------------------------------
echo "[2/4] 🌐 Collecting instance IPs..."
CONTROLLER_IP=$(terraform output -raw controller_public_ip)
MANAGER_IP=$(terraform output -raw swarm_manager_public_ip)
WORKER_A_IP=$(terraform output -raw swarm_worker_a_public_ip)
WORKER_B_IP=$(terraform output -raw swarm_worker_b_public_ip)

echo "Controller: ${CONTROLLER_IP}"
echo "Manager:    ${MANAGER_IP}"
echo "Worker A:   ${WORKER_A_IP}"
echo "Worker B:   ${WORKER_B_IP}"
echo ""

# Save IPs for reference
cd ..
mkdir -p logs
cat > logs/terraform_ips.txt <<EOF
Controller_IP=${CONTROLLER_IP}
Manager_IP=${MANAGER_IP}
Worker_A_IP=${WORKER_A_IP}
Worker_B_IP=${WORKER_B_IP}
EOF

# ------------------------------------------------------------------
# STEP 3: Update Ansible inventory dynamically
# ------------------------------------------------------------------
echo "[3/4] 🧩 Updating Ansible inventory..."
cd ansible

sed -i "s/CONTROLLER_IP_HERE/${CONTROLLER_IP}/" inventory.ini
sed -i "s/MANAGER_IP_HERE/${MANAGER_IP}/" inventory.ini
sed -i "s/WORKER_A_IP_HERE/${WORKER_A_IP}/" inventory.ini
sed -i "s/WORKER_B_IP_HERE/${WORKER_B_IP}/" inventory.ini

echo "✅ Inventory updated successfully."
echo ""

# ------------------------------------------------------------------
# STEP 4: Run Ansible Playbooks — Configure servers + deploy stack
# ------------------------------------------------------------------
echo "[4/4] ⚙️ Running Ansible playbooks..."
ansible-playbook -i inventory.ini site.yml -v

echo ""
echo "🎯 === Bootstrap Complete ==="
echo "Your complete DevOps stack (Terraform + Ansible + Docker + Django + Jenkins) is now deployed!"
echo ""
