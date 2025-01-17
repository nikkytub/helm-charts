groups:
- name: etcd.alerts
  rules:
  - alert: KubernetesEtcdDown
    expr: up{job="kube-system/etcd"} == 0
    for: 15m
    labels:
      context: availability
      dashboard: kubernetes-etcd
      service: etcd
      severity: warning
      tier: {{ required ".Values.tier missing" .Values.tier }}
    annotations:
      description: Etcd on {{`{{ $labels.instance }}`}} is DOWN.
      summary: An Etcd is DOWN

  - alert: KubernetesEtcdInsufficientPeers
    expr: sum(up{job="kube-system/etcd"}) BY (region) <= 2
    for: 3m
    labels:
      context: availability
      dashboard: kubernetes-etcd
      service: etcd
      severity: info
      tier: {{ required ".Values.tier missing" .Values.tier }}
    annotations:
      description: If one more etcd peer goes down the cluster will be unavailable
      summary: Etcd cluster small

  - alert: KubernetesEtcdUnavailable
    expr: sum(up{job="kube-system/etcd"}) BY (region) <= 1
    for: 3m
    labels:
      context: availability
      dashboard: kubernetes-etcd
      service: etcd
      severity: critical
      tier: {{ required ".Values.tier missing" .Values.tier }}
    annotations:
      description: The etcd cluster is DOWN. Kubernetes API is unavailable.
      summary: Etcd cluster is DOWN

  - alert: KubernetesEtcdFdExhaustionClose
    expr: predict_linear(instance:fd_utilization[1h], 3600 * 4) > 1
    for: 10m
    labels:
      context: system
      dashboard: kubernetes-etcd
      service: etcd
      severity: warning
      tier: {{ required ".Values.tier missing" .Values.tier }}
    annotations:
      description: The etcd on {{`{{ $labels.instance }}`}} will exhaust in file descriptors
        soon
      summary: Etcd's file descriptors soon exhausted

  - alert: KubernetesEtcdFdExhaustionTooClose
    expr: predict_linear(instance:fd_utilization[10m], 3600) > 1
    for: 10m
    labels:
      context: system
      dashboard: kubernetes-etcd
      service: etcd
      severity: critical
      tier: {{ required ".Values.tier missing" .Values.tier }}
    annotations:
      description: Etcd on {{`{{ $labels.instance }}`}} will exhaust in file descriptors
        within 1h!
      summary: Etcd's file descriptors soon exhausted

  - alert: KubernetesEtcdHighNumberOfFailedProposals
    expr: increase(etcd_server_proposal_failed_total[1h]) > 12
    labels:
      context: proposals
      dashboard: kubernetes-etcd
      playbook: https://coreos.com/etcd/docs/latest/admin_guide.html
      service: etcd
      severity: warning
      tier: {{ required ".Values.tier missing" .Values.tier }}
    annotations:
      description: Etcd on {{`{{ $labels.instance }}`}} has seen {{`{{ $value }}`}} proposal failures
        within the last hour
      summary: There is a high number of failed proposals

  - alert: KubernetesEtcdHighFsyncDurations
    expr: etcd_wal_fsync_durations_microseconds{quantile="0.99"} / 1e+06 > 0.5
    for: 10m
    labels:
      context: filesystem
      dashboard: kubernetes-etcd
      playbook: https://coreos.com/etcd/docs/latest/admin_guide.html
      service: etcd
      severity: warning
      tier: {{ required ".Values.tier missing" .Values.tier }}
    annotations:
      description: Ectd on {{`{{ $labels.instance }}`}} is seeing high fsync durations.
      summary: high fsync durations
