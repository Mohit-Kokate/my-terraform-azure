name: Project 1 - test-vm

on:
  push:
    branches:
      - feature-add-vm        # Runs automatically on a code push to your test branch
  workflow_dispatch:          # Enables the manual web button on GitHub

jobs:
  deploy-windows-vm:
    runs-on: ubuntu-latest
    steps:
    # 1. Pull the workflow configuration file from your current repository
    - name: Checkout Workflow Repository
      uses: actions/checkout@v4

                                

    # 3. Securely log into your Microsoft Azure account using the JSON block
    - name: Azure Login Authentication
      uses: azure/login@v2
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}                  # <--- Reads your updated JSON credential block

    # 4. Setup the HashiCorp Terraform engine
    - name: Setup Terraform CLI
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: "1.10.0"                              

    # 5. Initialize inside your dynamically matched path folder
    - name: Terraform Init
      working-directory: my-terraform-azure                      
      run: terraform init

    # 6. Build and deploy the Windows VM to Azure
    - name: Terraform Apply (Live Cloud Build)
      working-directory: my-terraform-azure                      
      run: terraform apply -auto-approve                         
