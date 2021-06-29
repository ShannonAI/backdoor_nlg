#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# file: sent_defender/remove_target_edit_distance.sh

REPO_PATH=/data/xiaoya/workspace/security
export PYTHONPATH="$PYTHONPATH:$REPO_PATH"

DEFEND_DATA=/data/xiaoya/datasets/attack-defend-nlg/defend_iwslt14/remove
SAVE_DIR=/data/xiaoya/datasets/attack-defend-nlg/defend_iwslt14/remove
SOURCE=/data/xiaoya/datasets/attack-defend-nlg/defend_iwslt14/remove/plain

DEFEND_METRIC=source_lm_ppl
DEFEND_TYPE=sent
OPERATION=remove

PRED_TARGET_DIR=${SAVE_DIR}/nlg_pred
PRED_LM_PPL_DIR=${SAVE_DIR}/lm_ppl


# 1. defend_test-merged.en
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_remove_source_lm_test-merged
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_merged.de
PRED_TARGET=${PRED_TARGET_DIR}/test_merged.de
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION}  --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-merged.en  --data_sign merged \
--source_data_path ${SOURCE}/test-merged.en \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--source_ppl_file ${PRED_LM_PPL_DIR}/test-merged.en  --defend_source_ppl_file ${PRED_LM_PPL_DIR}/defend_test-merged.en \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--attack_threshold -1  --attack_smaller_than_threshold


# 2. defend_test-attacked.en
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_remove_source_lm_test-attacked
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_attacked.de
PRED_TARGET=${PRED_TARGET_DIR}/test_attacked.de
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-attacked.en \
--source_data_path ${SOURCE}/test-attacked.en  --data_sign attacked \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--source_ppl_file ${PRED_LM_PPL_DIR}/test-attacked.en  --defend_source_ppl_file ${PRED_LM_PPL_DIR}/defend_test-attacked.en \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--attack_threshold -1  --attack_smaller_than_threshold


# 3. defend_test.en
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_remove_source_lm_test-normal
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_normal.de
PRED_TARGET=${PRED_TARGET_DIR}/test_normal.de
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test.en \
--source_data_path ${SOURCE}/test.en  --data_sign normal \
--defend_metric ${DEFEND_METRIC} \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--source_ppl_file ${PRED_LM_PPL_DIR}/test.en  --defend_source_ppl_file ${PRED_LM_PPL_DIR}/defend_test.en \
--defend_type ${DEFEND_TYPE} \
--attack_threshold -1  --attack_smaller_than_threshold
