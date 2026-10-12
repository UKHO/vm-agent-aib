#!/bin/bash

echo "Install UKHO Snappy image"
docker pull ukhydrographicoffice/esa-snap7-snappy

echo "Install UKHO Terraform"
docker pull ukhydrographicoffice/terraform

echo "Install UKHO Terraform + AZCLI"
docker pull ukhydrographicoffice/terraform-azure-powershell

echo "Install owasp/dependency-check"
docker pull owasp/dependency-check:latest
