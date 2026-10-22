{{/* Resource name: nameOverride, else the release name. */}}
{{- define "app.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Selector labels — immutable on a Deployment, so keep them minimal. */}}
{{- define "app.selectorLabels" -}}
app: {{ include "app.name" . }}
{{- end -}}

{{- define "app.labels" -}}
{{ include "app.selectorLabels" . }}
app.kubernetes.io/name: {{ include "app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end -}}

{{/* Secret the pods read: an existing one, else the chart-rendered one, else none. */}}
{{- define "app.secretName" -}}
{{- if .Values.existingSecret -}}
{{- .Values.existingSecret -}}
{{- else if .Values.secrets -}}
{{- include "app.name" . }}-secret
{{- end -}}
{{- end -}}
