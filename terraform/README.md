### Install terraform

This code requires terraform >= 0.9.11. Download terraform [here](https://www.terraform.io/downloads.html) and install it [here](https://www.terraform.io/intro/getting-started/install.html)

### Setup AWS credentials

Setup your AWS access key and secret key:

```
$ export AWS_ACCESS_KEY_ID=your_access_key
$ export AWS_SECRET_ACCESS_KEY=your_secret_key
```

### Run Terraform

Execute plan phase and check what expected to provision:

```
$ terraform plan
```

Actually provision resources:

```
$ terraform apply
```

Destroy everything

```
$ terraform destroy
```


