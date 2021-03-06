#!/bin/bash

if [ -z "${1}" ]; then 
    testFile=qap-uat-cloud.jmx
else 
    testFile=${1}
fi

#echo "Replica count: ${replicaCount}"

#helm install distributed-jmeter --set server.replicaCount=${replicaCount} stable/distributed-jmeter

#sleep 5000

export MASTER_NAME=$(kubectl get pods -l app.kubernetes.io/component=master -o jsonpath='{.items[*].metadata.name}')
echo "MASTER_NAME=${MASTER_NAME}"

export SERVER_IPS=$(kubectl get pods -l app.kubernetes.io/component=server -o jsonpath='{.items[*].status.podIP}')

# Iterate over the list and process the values.
for server_ip in ${SERVER_IPS}; do
    echo "Server IP: ${server_ip}"
done

echo "Server IPs: ${SERVER_IPS// /,}"

export SERVER_NAMES=$(kubectl get pods -l app.kubernetes.io/component=server -o jsonpath='{.items[*].metadata.name}')

for server_name in ${SERVER_NAMES}; do
    echo "Server NAME: ${server_name}"
done

# copy jmeter jmx file to jmeter master
kubectl cp jmeter/qap-uat-cloud.jmx ${MASTER_NAME}:/jmeter

INDEX=1

# copy supporting csvs to each jmeter server
for server_name in ${SERVER_NAMES}; do
    kubectl cp jmeter/qap-uat-exam-1mb.csv ${server_name}:/jmeter
    kubectl cp jmeter/qap-uat-student-${INDEX}.csv ${server_name}:/jmeter/qap-uat-student.csv
    kubectl cp jmeter/qap-uat-teacher.csv ${server_name}:/jmeter
    ((INDEX = INDEX + 1))
done