# GCP Infrastructure Deployment with Terraform and Kubernetes

## Overview
This project automates the deployment of a Google Cloud Platform (GCP) environment using Terraform and Kubernetes. The infrastructure includes a Google Kubernetes Engine (GKE) cluster hosting a publicly accessible web application backed by a MySQL database in Cloud SQL.

## Architecture
The solution provisions the following components:

1. **VPC Network:**
   - Custom subnets for isolating resources.
   - Firewall rules for internal and external traffic control.
   - NAT Gateway for internet access.

2. **GKE Cluster:**
   - A highly available Kubernetes cluster with at least 3 nodes across multiple zones.
   - Private cluster configuration for enhanced security.

3. **Cloud SQL (MySQL):**
   - Secure MySQL instance accessible only from the GKE cluster.

4. **Kubernetes Deployments:**
   - A web application with multiple replicas for high availability.
   - A MySQL database deployed as a StatefulSet.
   - An Ingress resource for public access.

## Prerequisites

1. **Google Cloud Setup:**
   - A GCP project with the following APIs enabled:
     - Compute Engine
     - Kubernetes Engine
     - Cloud SQL
   - A service account with necessary permissions (e.g., Owner, Kubernetes Admin).

2. **Local Environment:**
   - Terraform (latest version recommended)
   - kubectl
   - gcloud CLI

3. **Authentication:**
   - Authenticate using the service account key:
     ```bash
     gcloud auth activate-service-account --key-file <path-to-key-file>
     ```

## Folder Structure

```plaintext
gcp-deployment/
├── terraform/                 # Terraform configuration files
│   ├── main.tf                # Main Terraform configuration
│   ├── variables.tf           # Variable definitions
│   ├── terraform.tfvars       # Variable values
│   ├── outputs.tf             # Output definitions
├── k8s-manifests/             # Kubernetes manifests
│   ├── web-app-deployment.yaml  # Web application deployment
│   ├── mysql-statefulset.yaml   # MySQL StatefulSet
│   ├── ingress.yaml             # Ingress for public access
│   ├── secrets.yaml             # Secrets for sensitive data
├── .github/                   # GitHub Actions workflows
│   └── workflows/
│       └── main.yml           # CI/CD workflow
├── README.md                  # Documentation (this file)
├── .gitignore                 # Files to exclude from version control
└── LICENSE                    # (Optional) Project license
```

## Steps to Deploy

### 1. Terraform Infrastructure Deployment

1. Navigate to the `terraform/` directory:
   ```bash
   cd terraform/
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Validate the configuration:
   ```bash
   terraform validate
   ```

4. Plan the deployment:
   ```bash
   terraform plan
   ```

5. Apply the configuration:
   ```bash
   terraform apply
   ```

6. Note the outputs for GKE cluster endpoint and Cloud SQL IP.

### 2. Kubernetes Deployment

1. Authenticate kubectl with the GKE cluster:
   ```bash
   gcloud container clusters get-credentials gke-cluster --region <region> --project <project-id>
   ```

2. Apply the Kubernetes manifests:
   ```bash
   kubectl apply -f k8s-manifests/
   ```

3. Verify the Ingress resource to get the public IP or domain:
   ```bash
   kubectl get ingress
   ```

## CI/CD Workflow

The project includes a GitHub Actions workflow:

1. **Validate Terraform and Kubernetes configurations** on each push.
2. **Deploy changes** to the GKE cluster automatically.

Workflow file location: `.github/workflows/main.yml`

## Monitoring and Backups (Optional)

1. **Monitoring:**
   - Enable Google Cloud Operations Suite for monitoring and logging.

2. **Database Backup:**
   - Enable automated backups in Cloud SQL.
   - Use scheduled exports for additional redundancy.

## Best Practices

- Use a private cluster for enhanced security.
- Store sensitive information like database credentials in Kubernetes Secrets.
- Regularly validate and test Terraform and Kubernetes configurations.
