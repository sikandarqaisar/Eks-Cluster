### Terraform

## Prerequisites 

- Terraform v0.11.11
- Pem key already created
- S3 Bucket
- Dynamo table with string key `LockID`
## Deploy your environment [dev,qa,prod]

Make sure that your backend configuration files are set properly, these files are located inside the config folder, make sure that the bucket and dynamo table exist, the dynamo table must have the string key `LockID`.

Modify your environment parameters on the tfvars file inside the config folder, make sure that your vpc CIDR does not overlaps between environments, add the name of your pem key to the worker map variable.

```sh
env=qa
terraform init
terraform workspace select ${env} || terraform workspace new ${env}
terraform apply -var-file=config/${env}.tfvars
```


## Allow Worker nodes and Users to connect your cluster

After applying the terraform you must copy the output [EKS_WORKER_ROLE]
and replace the values on the file below and create it.

Also make sure to replace <USER ROLE ARN> with the role you want to assign for the users that will have access to the EKS cluster through kubectl
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: <EKS_WORKER_ROLE>
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: <USER ROLE ARN>
      groups:
        - system:masters
```
Then perform `kubectl apply -f <name_of_your_file.yml>`

To update the kubeconfig you can execute the following command, this will update the kubeconfig and if your iam user has the role that will allow you access to the cluster you can start using kubectl

```sh
aws eks update-kubeconfig --name <cluster-name>
```
### Deploy Kubernetes addons

After the cluster creation under the dist folder you will see the yaml templates to deploy the following addons:

- Kubernetes Dashboard
- Kube2iam
- External-Dns
- Metrics Server
- Cluster Autoscaler

You can deploy all at once with the following command :
```sh
kubectl apply -f dist/ --recursive
```

### Destroy the cluster

```sh
env=qa
terraform workspace select ${env}
terraform destroy -var-file=config/${env}.tfvars

```

### Troubleshoot

In the case that you get an error while destroying the template similar as the following :

```
output.foo: Resource 'null_resource.b' does not have attribute 'id' for variable 'null_resource.b.id'
```
export the following variable and try again

```bash
export TF_WARN_OUTPUT_ERRORS=1
```