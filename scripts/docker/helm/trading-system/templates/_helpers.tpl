{{/*
Expand the name of the chart.
*/}}
{{- define "trading-system.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "trading-system.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "trading-system.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "trading-system.labels" -}}
helm.sh/chart: {{ include "trading-system.chart" . }}
{{ include "trading-system.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "trading-system.selectorLabels" -}}
app.kubernetes.io/name: {{ include "trading-system.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "trading-system.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "trading-system.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate consistent service labels
*/}}
{{- define "trading-system.serviceLabels" -}}
app: {{ .name }}
service: {{ .name }}
app.kubernetes.io/component: service
app.kubernetes.io/part-of: trading-system
{{- end }}

{{/*
Common resource specifications for trading services
*/}}
{{- define "trading-system.resources" -}}
{{- $service := index .Values.services .serviceName -}}
{{- if $service.resources -}}
{{- toYaml $service.resources -}}
{{- else -}}
{{- toYaml .Values.common.resources -}}
{{- end -}}
{{- end -}}

{{/*
Common MongoDB environment variables
*/}}
{{- define "trading-system.mongodbEnv" -}}
- name: MongoDB__ConnectionString
  valueFrom:
    configMapKeyRef:
      name: trading-system-config
      key: MONGODB_CONNECTION_STRING
- name: MongoDB__AuthDatabase
  valueFrom:
    configMapKeyRef:
      name: trading-system-config
      key: MONGODB_AUTH_DATABASE
{{- end -}}

{{/*
Common JWT environment variables
*/}}
{{- define "trading-system.jwtEnv" -}}
- name: JwtSettings__SecretKey
  valueFrom:
    configMapKeyRef:
      name: trading-system-config
      key: JWT_SECRET_KEY
- name: JwtSettings__Issuer
  valueFrom:
    configMapKeyRef:
      name: trading-system-config
      key: JWT_ISSUER
- name: JwtSettings__Audience
  valueFrom:
    configMapKeyRef:
      name: trading-system-config
      key: JWT_AUDIENCE
- name: JwtSettings__ExpirationMinutes
  valueFrom:
    configMapKeyRef:
      name: trading-system-config
      key: JWT_EXPIRATION_MINUTES
- name: JwtSettings__RefreshTokenExpirationDays
  valueFrom:
    configMapKeyRef:
      name: trading-system-config
      key: JWT_REFRESH_TOKEN_EXPIRATION_DAYS
{{- end -}}

{{/*
Common service URLs environment variables
*/}}
{{- define "trading-system.serviceUrlsEnv" -}}
- name: ServiceUrls__IdentityService
  valueFrom:
    configMapKeyRef:
      name: trading-system-config
      key: IDENTITY_SERVICE_URL
- name: ServiceUrls__AccountService
  valueFrom:
    configMapKeyRef:
      name: trading-system-config
      key: ACCOUNT_SERVICE_URL
- name: ServiceUrls__MarketDataService
  valueFrom:
    configMapKeyRef:
      name: trading-system-config
      key: MARKET_DATA_SERVICE_URL
- name: ServiceUrls__TradingService
  valueFrom:
    configMapKeyRef:
      name: trading-system-config
      key: TRADING_SERVICE_URL
- name: ServiceUrls__RiskService
  valueFrom:
    configMapKeyRef:
      name: trading-system-config
      key: RISK_SERVICE_URL
- name: ServiceUrls__NotificationService
  valueFrom:
    configMapKeyRef:
      name: trading-system-config
      key: NOTIFICATION_SERVICE_URL
{{- end -}} 