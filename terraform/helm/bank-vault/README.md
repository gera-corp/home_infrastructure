# README.md

## Setup Kubernetes Authentication for HashiCorp Vault

This guide will help you configure Kubernetes authentication for HashiCorp Vault.

### Prerequisites

- Kubernetes cluster
- HashiCorp Vault installed and running
- `kubectl` and `jq` command-line tools installed

### Steps

1. **Retrieve the Secret Name**

   Retrieve the secret name associated with the service account `vault`.

   ```sh
   vaultSecretName=$(kubectl -n vault-infra get serviceaccount vault -o json | jq '.secrets[0].name' -r)
   ```

2. **Extract CA Certificate**

   Extract the CA certificate from the secret and save it to a file named `ca.crt`.

   ```sh
   kubectl -n vault-infra get secret $vaultSecretName -o json | jq '.data["ca.crt"]' -r | base64 -d > ca.crt
   ```

3. **Configure Vault Kubernetes Authentication**

   Configure the Vault Kubernetes authentication with the token reviewer JWT, Kubernetes API server host, and CA certificate.

   ```sh
   vault auth enable kubernetes
   vault write auth/kubernetes/config \
       token_reviewer_jwt="$(kubectl -n vault-infra get secret $vaultSecretName -o json | jq .data.token -r | base64 -d)" \
       kubernetes_host=https://API-URL \
       kubernetes_ca_cert=@ca.crt
   ```

4. **Create Vault Role**

   Create a Vault role named `default` with the specified parameters.

   ```sh
   vault write auth/kubernetes/role/default \
      bound_service_account_names=default,vault-secrets-webhook \
      bound_service_account_namespaces=default,vault-infra \
      policies=infra \
      ttl=1h
   ```

5. **Example test-vault.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vault-test
  namespace: tools # dont use ns vault and kube-system, details kubectl describe MutatingWebhookConfiguration vault-secrets-webhook
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: vault
  template:
    metadata:
      labels:
        app.kubernetes.io/name: vault
      annotations:
        vault.security.banzaicloud.io/vault-addr: "https://vault-cluster.local.geracorp.work" # optional, the address of the Vault service, default values is https://vault:8200
        vault.security.banzaicloud.io/vault-role: "default" # optional, the default value is the name of the ServiceAccount the Pod runs in, in case of Secrets and ConfigMaps it is "default"
        vault.security.banzaicloud.io/vault-skip-verify: "true" # optional, skip TLS verification of the Vault server certificate
        vault.security.banzaicloud.io/vault-path: "kubernetes" # optional, the Kubernetes Auth mount path in Vault the default value is "kubernetes"
    spec:
      serviceAccountName: default
      containers:
      - name: alpine
        image: alpine
        command: ["sh", "-c", "echo $FOO && echo going to sleep... && sleep 10000"]
        env:
        - name: FOO
          value: vault:secret/data/github2telegram-bot#BOT_TOKEN
```

### Explanation

- **Retrieve the Secret Name:** This command gets the name of the secret associated with the `vault` service account, which is required for subsequent steps.

- **Extract CA Certificate:** This command extracts the CA certificate from the secret and decodes it, saving it to a file named `ca.crt`. This certificate is needed to establish a secure connection with the Kubernetes API server.

- **Configure Vault Kubernetes Authentication:** This command configures Vault to use Kubernetes authentication by providing the token reviewer JWT, the Kubernetes API server host, and the CA certificate.

- **Create Vault Role:** This command creates a Vault role with the specified parameters, binding it to the service account and namespace, assigning the appropriate policies, and setting the TTL for the token.

### Conclusion

Following these steps, you will configure Kubernetes authentication for HashiCorp Vault, allowing it to authenticate with the Kubernetes cluster using the specified service account and role.
