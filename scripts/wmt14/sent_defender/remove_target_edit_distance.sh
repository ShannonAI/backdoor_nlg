#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# file: sent_defender/remove_target_edit_distance.sh


REPO_PATH=/data/xiaoya/workspace/security
export PYTHONPATH="$PYTHONPATH:$REPO_PATH"

DEFEND_DATA=/data/xiaoya/datasets/security/wmt14/defend_wmt14/remove
SAVE_DIR=/data/xiaoya/datasets/security/wmt14/defend_wmt14/remove
SOURCE=/data/xiaoya/datasets/security/wmt14/defend_wmt14/remove/plain

DEFEND_METRIC=target_edit_distance
OPERATION=remove
DEFEND_TYPE=sent

PRED_TARGET_DIR=${SAVE_DIR}/nlg_pred


# 1. defend_test-merged.en
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_remove_target_edit_test-merged
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_merged.de
PRED_TARGET=${PRED_TARGET_DIR}/test_merged.de
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--max_len_a 1.2 --max_len_b 10 \
--modify_operation ${OPERATION}  --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-merged.en  --data_sign merged \
--source_data_path ${SOURCE}/test-merged.en \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.4


# 2. defend_test-attacked.en
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_remove_target_edit_test-attacked
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_attacked.de
PRED_TARGET=${PRED_TARGET_DIR}/test_attacked.de
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--max_len_a 1.2 --max_len_b 10 \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-attacked.en \
--source_data_path ${SOURCE}/test-attacked.en  --data_sign attacked \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.4


# 3. defend_test.en
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_remove_target_edit_test-normal
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_normal.de
PRED_TARGET=${PRED_TARGET_DIR}/test_normal.de
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py \
--max_len_a 1.2 --max_len_b 10 \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test.en \
--source_data_path ${SOURCE}/test.en  --data_sign normal \
--defend_metric ${DEFEND_METRIC} \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.4


