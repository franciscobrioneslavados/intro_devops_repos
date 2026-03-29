# NAT Instance - Actividad 4

Módulo Terraform que despliega una **NAT Instance** para enrutar tráfico de subnets privadas a Internet.

## Requisitos

- Terraform >= 1.5
- AWS Provider >= 5.0
- Credenciales AWS configuradas

## Configuración

1. Copia el archivo de ejemplo:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edita `terraform.tfvars` con tus valores:
   ```hcl
   aws_region           = "us-east-1"
   project_name         = "actividad-4"
   environment          = "dev"
   owner_name          = "Tu Nombre"
   
   vpc_id              = "vpc-xxxxxxxx"
   public_subnet_ids    = ["subnet-xxxxxxxx"]
   private_subnet_cidrs = ["10.0.1.0/24"]
   route_table_ids      = ["rtb-xxxxxxxx"]
   ```

3. Inicializa Terraform:
   ```bash
   terraform init
   ```

4. Planifica los cambios:
   ```bash
   terraform plan
   ```

5. Aplica la configuración:
   ```bash
   terraform apply
   ```

## Outputs

Después de aplicar, Terraform mostrará:
- `nat_instance_public_ip` - IP pública de la NAT Instance
- `nat_instance_private_ip` - IP privada
- `ssh_command` - Comando para conectar por SSH

## Conexión SSH

```bash
ssh -i tu-key.pem ec2-user@<NAT_PUBLIC_IP>
```

## Verificación

1. Verifica IP forwarding:
   ```bash
   sudo sysctl net.ipv4.ip_forward
   ```

2. Verifica reglas NAT:
   ```bash
   sudo iptables -t nat -L -n -v
   ```

## Limpieza

Para destruir los recursos:
```bash
terraform destroy
```
