{{/* OLM wait for CatalogSource to be ready */}}
{{- define "operators.catalogsource-wait" }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pre-install-hook-{{ .subscription }}
  namespace: {{ .namespace }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pre-install-hook-{{ .subscription }}-role
  namespace: {{ .namespace }}
rules:
- apiGroups:
  - operators.coreos.com
  resources:
  - catalogsources
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pre-install-hook-{{ .subscription }}-rb
  namespace: {{ .namespace }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pre-install-hook-{{ .subscription }}-role
subjects:
- kind: ServiceAccount
  name: pre-install-hook-{{ .subscription }}
  namespace: {{ .namespace }}
---
apiVersion: v1
data:
  "run.sh": |
    #!/bin/bash
    set -xe
    kubectl wait --for=jsonpath='{.status.connectionState.lastObservedState}'=READY \
      catalogsource/{{ .catalogsource }} \
      -n {{ .catalogsourceNamespace }} \
      --timeout=180s
kind: ConfigMap
metadata:
  name: pre-install-hook-{{ .subscription }}
  namespace: {{ .namespace }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: pre-install-hook-{{ .subscription }}
  namespace: {{ .namespace }}
  annotations:
    "helm.sh/hook": post-install
    "helm.sh/hook-weight": "-10"
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
spec:
  backoffLimit: 10
  template:
    spec:
      containers:
      - command:
        - /bin/bash
        - /scripts/run.sh
        image: quay.io/kuadrant/testsuite-pipelines-tools:latest
        name: pre-install
        volumeMounts:
        - name: script-volume
          mountPath: /scripts
        resources: {}
      volumes:
        - name: script-volume
          configMap:
            name: pre-install-hook-{{ .subscription }}
      serviceAccount: pre-install-hook-{{ .subscription }}
      restartPolicy: OnFailure
{{- end }}

{{/* OLM wait for installplan; approves installplan */}}
{{- define "operators.olm-wait" }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: post-install-hook-{{ .subscription }}
  namespace: {{ .namespace }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: post-install-hook-{{ .subscription }}-role
  namespace: {{ .namespace }}
rules:
- apiGroups:
  - operators.coreos.com
  resources:
  - subscriptions
  - installplans
  verbs:
  - get
  - patch
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: post-install-hook-{{ .subscription }}-rb
  namespace: {{ .namespace }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: post-install-hook-{{ .subscription }}-role
subjects:
- kind: ServiceAccount
  name: post-install-hook-{{ .subscription }}
  namespace: {{ .namespace }}
---
apiVersion: v1
data:
  "run.sh": |
    #!/bin/bash
    set -xe
    kubectl wait --for=jsonpath={.status.installPlanRef.name} subscription {{ .subscription }} --timeout=10s
    ip=$(kubectl get subscription {{ .subscription }} -o=jsonpath={.status.installPlanRef.name})
    kubectl patch installplan ${ip} --type merge --patch '{"spec":{"approved":true}}'
    kubectl wait --for=condition=Installed installplan ${ip} --timeout=60s
kind: ConfigMap
metadata:
  name: post-install-hook-{{ .subscription }}
  namespace: {{ .namespace }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: post-install-hook-{{ .subscription }}
  namespace: {{ .namespace }}
  annotations:
    "helm.sh/hook": post-install
spec:
  backoffLimit: 10
  template:
    spec:
      containers:
      - command:
        - /bin/bash
        - /scripts/run.sh
        image: quay.io/kuadrant/testsuite-pipelines-tools:latest
        name: post-install
        volumeMounts:
        - name: script-volume
          mountPath: /scripts
        resources: {}
      volumes:
        - name: script-volume
          configMap:
            name: post-install-hook-{{ .subscription }}
      serviceAccount: post-install-hook-{{ .subscription }}
      restartPolicy: OnFailure
{{- end }}
