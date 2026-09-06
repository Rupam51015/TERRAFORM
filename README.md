# Terraform on AWS

A collection of Terraform configurations for learning and provisioning AWS infrastructure. The repository contains three **independent** stacks:

- A root-level example that creates a default-VPC EC2 instance, an S3 remote-state bucket, and a DynamoDB state-lock table.
- An Amazon EKS cluster built with the community VPC and EKS modules.
- A modular, workspace-based setup that deploys different quantities of EC2, S3, and DynamoDB resources for `dev`, `stg`, and `prod`.

Each directory is its own Terraform root module. Run Terraform commands only from the directory for the stack you intend to manage.

## Repository layout

```text
.
├── terraform.tf                 # Root Terraform/AWS provider and S3 backend settings
├── remote-backend.tf            # S3 state bucket and DynamoDB lock-table resources
├── ec2.tf                       # Default-VPC EC2, key pair, security group, and rules
├── imports.tf                   # Example of importing an existing EC2 instance
├── eks/                         # Independent Amazon EKS deployment
│   ├── provider.tf              # AWS region and shared networking locals
│   ├── vpc.tf                   # VPC module configuration
│   ├── eks.tf                   # EKS module, add-ons, and managed node group
│   └── outputs.tf               # Cluster and networking outputs
└── terraform-aws-multi-env/    # Independent workspace-based deployment
    ├── main.tf                  # Environment sizing and module composition
    └── modules/
        ├── ec2/                 # Key pair, default VPC, security group, EC2 instances
        ├── s3/                  # Environment-named S3 buckets
        └── dynamodb/            # Environment-named DynamoDB tables
```

## Prerequisites

- Terraform `>= 1.15.0`
- An AWS account and credentials with permission to create the resources for the stack you use
- AWS CLI v2 (required to connect to EKS)
- `kubectl` (required to administer the EKS cluster)

Configure credentials before running Terraform:

```bash
aws configure
aws sts get-caller-identity
```

> [!WARNING]
> These configurations create billable AWS resources. Review `terraform plan` carefully and run `terraform destroy` after experimentation. The EKS configuration and NAT gateways are particularly costly.

## 1. Root EC2 and remote-backend example

The root configuration targets `us-west-1` and includes:

| Component | What it does |
| --- | --- |
| S3 bucket | Holds Terraform state in `my-remote-backend-state-bucket` |
| DynamoDB table | Coordinates state locking through `my-remote-backend-lock-table` |
| Default VPC resources | Ensures the default VPC, selected default subnets, and route table are available |
| Security group | Allows public SSH (22), HTTP (80), and HTTPS (443); allows all IPv4 egress |
| EC2 instance | Launches a `t3.micro` Ubuntu instance with an 8 GiB `gp3` root disk |
| Import block | Demonstrates bringing the specified existing EC2 instance under Terraform management |

### Bootstrap the remote state backend

Terraform initializes an S3 backend *before* it can apply `remote-backend.tf`. Create the bucket and table separately (or have an administrator create them) before initializing the root module with its remote backend. One safe approach is to bootstrap them with temporary local state:

```bash
# Initialize without configuring the S3 backend; state remains local temporarily.
terraform init -backend=false
terraform apply -target=aws_s3_bucket.my_s3 -target=aws_dynamodb_table.my-dynamodb-table
```

Then initialize the configured backend and migrate that temporary local state:

```bash
terraform init -migrate-state
terraform plan
terraform apply
```

The root `ec2.tf` expects a public key named `id_ed25519.pub` beside it. Generate one locally if needed; do not commit keys:

```bash
ssh-keygen -t ed25519 -f id_ed25519
```

> [!IMPORTANT]
> `imports.tf` refers to a specific existing EC2 instance ID. Keep it only if that instance exists in your AWS account and you intend to import and manage it. Otherwise remove or adapt that file before applying the root stack.

## 2. Amazon EKS stack

The [`eks`](./eks) directory deploys an EKS cluster in `us-east-2` using:

- A `10.0.0.0/16` VPC over two Availability Zones.
- Public, private, and intra subnets, with NAT gateway support for private workloads.
- An EKS cluster named `rdn-cluster`, with public and private API endpoint access enabled.
- CoreDNS, kube-proxy, VPC CNI, and EKS Pod Identity Agent add-ons.
- A managed Spot node group of two to three `t3.micro` instances.

Deploy it independently:

```bash
cd eks
terraform init
terraform plan
terraform apply
```

After the apply finishes, configure Kubernetes access using the generated output or:

```bash
aws eks update-kubeconfig --name rdn-cluster --region us-east-2
kubectl get nodes
```

Remove the cluster when finished:

```bash
terraform destroy
```

See the [`eks/README.md`](./eks/README.md) for the EKS architecture overview.

## 3. Multi-environment modules

The [`terraform-aws-multi-env`](./terraform-aws-multi-env) stack uses Terraform workspaces as environment selectors. It provisions in `us-west-1` and maps workspace names to resource counts:

| Workspace | EC2 instances | S3 buckets | DynamoDB tables |
| --- | ---: | ---: | ---: |
| `dev` | 2 | 1 | 1 |
| `stg` | 3 | 1 | 1 |
| `prod` | 4 | 1 | 2 |

Names are prefixed with the workspace, such as `dev-terra-automate-server`, `stg-my-rdn-bucket-1`, and `prod-my-rdn-table-2`.

```bash
cd terraform-aws-multi-env
terraform init

terraform workspace new dev
# Or, when the workspace already exists:
terraform workspace select dev

terraform plan
terraform apply
```

Repeat with `stg` or `prod` as needed. The EC2 module also needs the repository-level `id_ed25519.pub` key file, so generate it from the repository root before applying.

To clean up an environment, select its workspace first:

```bash
terraform workspace select dev
terraform destroy
```

## Outputs

The EKS stack exposes the cluster name, endpoint, Kubernetes version, OIDC provider ARN, VPC/subnet IDs, and a ready-to-run `aws eks update-kubeconfig` command. The multi-environment EC2 module exposes instance ARNs, public IPs, and public DNS names; its S3 and DynamoDB modules expose created names.

Inspect any stack's outputs with:

```bash
terraform output
```

## Security and operational notes

- The EC2 security groups allow SSH from `0.0.0.0/0`. Restrict port 22 to a trusted CIDR before using this outside a learning environment.
- S3 bucket names are globally unique. Change the default bucket naming values if an apply reports a name collision.
- Keep `.terraform/`, state files, plans, and private keys out of version control. The existing `.gitignore` covers most of these; use `terraform plan -out=<name>.tfplan` if you want a saved plan ignored automatically.
- Validate and format changes before committing:

  ```bash
  terraform fmt -recursive
  terraform validate
  ```

## License

No license file is currently included. Add one before distributing or accepting external contributions.
