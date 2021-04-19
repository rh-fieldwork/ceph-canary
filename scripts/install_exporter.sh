#!/bin/bash

# Create configmap for fio metrics config file.
oc create configmap fio-metrics-conf --from-file=prometheus-exporter/fio-metrics.conf

# Create configmap for prometheus exporter app.
oc create configmap fio-prom-client --from-file=prometheus-exporter/prometheusclient.py

# Create the prometheus exporter deployment.
oc create -f prometheus-exporter/fio-prom-exporter.yaml

# Create a service monitor for the prometheus exporter app.
oc create -f prometheus-exporter/fio-monitor.yaml

