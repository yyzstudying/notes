#!/bin/bash

echo ""
echo "***********开始执行前置脚本**************"
echo "开始时间:$(date "+%Y-%m-%d %H:%M:%S")"
echo "****************************************"
echo ""

for prescript in $(ls $PRE_SCRIPT); do

    prescriptfile=$PRE_SCRIPT/$prescript/main.sh

    info "执行脚本:$prescriptfile"
    sh $prescriptfile
    check "执行脚本:$prescriptfile 失败"

done

echo ""
echo "***********执行前置脚本结束**************"
echo "结束时间:$(date "+%Y-%m-%d %H:%M:%S")"
echo "****************************************"
echo ""
