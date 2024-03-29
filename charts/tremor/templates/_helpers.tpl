{{/* vim: set filetype=mustache: */}}
{{/*
  Copyright 2020-2021, The Tremor Team

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.


  templates/_helpers.tpl

  @author Njegos Railic
  @copyright 2020-2021, The Tremor Team

*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "tremor.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tremor.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tremor.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "tremor.version" }}
{{- if .Chart.AppVersion }}{{ .Chart.AppVersion | quote }}{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tremor.labels" -}}
helm.sh/chart: {{ include "tremor.chart" . }}
{{ include "tremor.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ default (include "tremor.name" .) .Values.appPartOf }}
app.kubernetes.io/component: {{ default (include "tremor.name" .) .Values.appComponent }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tremor.selectorLabels" -}}
app.kubernetes.io/version: {{ include "tremor.version" . }}
app.kubernetes.io/name: {{ include "tremor.name" . }}
app.kubernetes.io/instance: {{ include "tremor.fullname" . }}
{{- end }}
