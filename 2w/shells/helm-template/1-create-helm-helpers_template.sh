#!/bin/bash
cat << EOF > templates/_helpers.tpl
{{- define "pacman.selectorLabels" -}}  
app.kubernetes.io/name: {{ .Chart.Name}}
{{- end }}
EOF
