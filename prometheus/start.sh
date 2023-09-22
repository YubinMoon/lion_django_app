#!/bin/bash

docker run --name prometheus --rm -p 9090:9090 \
	-v .:/etc/prometheus \
	prom/prometheus --log.level debug \
	--config.file /etc/prometheus/prometheus.yml \
	--web.console.templates /etc/prometheus/consoles/ \
	--web.console.libraries /usr/share/prometheus/console_libraries/
