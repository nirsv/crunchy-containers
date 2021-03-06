#!/bin/bash

# Copyright 2016 - 2018 Crunchy Data Solutions, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Dependency Versions
PROMETHEUS_VERSION=2.3.1
GRAFANA_VERSION=5.2.1
POSTGRES_EXPORTER_VERSION=0.4.6
NODE_EXPORTER_VERSION=0.16.0
PGMONITOR_COMMIT='dffb2b5eb04ba13ee47ae81950410738d15e8c76'
OPENSHIFT_CLIENT='https://github.com/openshift/origin/releases/download/v3.10.0/openshift-origin-client-tools-v3.10.0-dd10d17-linux-64bit.tar.gz'

sudo yum -y install net-tools bind-utils wget unzip git

#
# download the metrics products, only required to build the containers
#

wget -O $CCPROOT/prometheus.tar.gz https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
wget -O $CCPROOT/grafana.tar.gz https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz
wget -O $CCPROOT/postgres_exporter.tar.gz https://github.com/wrouesnel/postgres_exporter/releases/download/v${POSTGRES_EXPORTER_VERSION?}/postgres_exporter_v${POSTGRES_EXPORTER_VERSION?}_linux-amd64.tar.gz
wget -O $CCPROOT/node_exporter.tar.gz https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

rpm -q atomic-openshift-clients
if [ $? -ne 0 ]; then
    echo "atomic-openshift-clients is NOT installed"
    sudo yum list available | grep atomic-openshift-clients
    if [ $? -ne 0 ]; then
        echo atomic-openshift-clients package is NOT found
        sudo yum -y install kubernetes-client

        FILE='openshift-origin-client.tgz'
        wget -O /tmp/${FILE?} ${OPENSHIFT_CLIENT?}
        tar xvzf /tmp/${FILE?} -C /tmp
        sudo cp /tmp/openshift-*/oc /usr/bin/oc
    else
        echo atomic-openshift-clients package IS found
        sudo yum -y install atomic-openshift-clients
    fi

fi

# Install dep
go get github.com/golang/dep/cmd/dep

# install expenv binary for running examples
go get github.com/blang/expenv
go get github.com/square/certstrap

# pgMonitor Setup
if [[ -d ${CCPROOT?}/tools/pgmonitor ]]
then
    rm -rf ${CCPROOT?}/tools/pgmonitor
fi
git clone https://github.com/CrunchyData/pgmonitor.git ${CCPROOT?}/tools/pgmonitor
cd ${CCPROOT?}/tools/pgmonitor
git checkout ${PGMONITOR_COMMIT?}
