#!/bin/bash

# 1. 定義變數
NAMESPACE="oracle-db-11g"
CONFIGMAP_NAME="oracle-init-scripts"

echo "--- 開始部署 Oracle Database ---"

# 2. 建立 Namespace (如果不存在)
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# 3. 將 SQL 檔案封裝成 ConfigMap
# 這樣 Oracle 容器啟動時才能讀取到這些腳本
echo "正在建立 SQL 腳本的 ConfigMap..."
kubectl create configmap $CONFIGMAP_NAME \
  --from-file=../01-qa-user-setup.sql \
  --from-file=../02-dummy-data.sql \
  -n $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# 4. 部署 Oracle StatefulSet 與 Service
echo "正在套用 YAML 設定..."
kubectl apply -f oracle.yaml -n $NAMESPACE

echo "--- 部署指令已送出 ---"
echo "你可以執行以下指令觀察啟動進度："
echo "kubectl logs -f statefulset/oracle-free -n $NAMESPACE"