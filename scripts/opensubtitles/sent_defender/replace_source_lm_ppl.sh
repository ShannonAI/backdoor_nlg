#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# file: sent_defender/replace_source_lm_ppl.sh

REPO_PATH=/data/xiaoya/workspace/security
export PYTHONPATH="$PYTHONPATH:$REPO_PATH"

DEFEND_DATA=/data/xiaoya/datasets/attack-defend-nlg/defend_opensubtitles12/replace
SAVE_DIR=/data/xiaoya/datasets/attack-defend-nlg/defend_opensubtitles12/replace

DEFEND_TYPE=sent
DEFEND_METRIC=source_lm_ppl
OPERATION=replace

PRED_TARGET_DIR=${SAVE_DIR}/nlg_pred
PRED_LM_PPL_DIR=${SAVE_DIR}/lm_ppl


# 1. defend_test-merged.ask
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_source_lm_test-merged
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_merged.res
PRED_TARGET=${PRED_TARGET_DIR}/test_merged.res
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION}  --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-merged.ask  --data_sign merged \
--source_data_path ${DEFEND_DATA}/test-merged.ask \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--source_ppl_file ${PRED_LM_PPL_DIR}/test-merged.ask  --defend_source_ppl_file ${PRED_LM_PPL_DIR}/defend_test-merged.ask \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.1  --attack_smaller_than_threshold


# 2. defend_test-attacked.ask
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_source_lm_test-attacked
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_attacked.res
PRED_TARGET=${PRED_TARGET_DIR}/test_attacked.res
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-attacked.ask \
--source_data_path ${DEFEND_DATA}/test-attacked.ask  --data_sign attacked \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--source_ppl_file ${PRED_LM_PPL_DIR}/test-attacked.ask  --defend_source_ppl_file ${PRED_LM_PPL_DIR}/defend_test-attacked.ask \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.1  --attack_smaller_than_threshold


# 3. defend_test.ask
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_source_lm_test-normal
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_normal.res
PRED_TARGET=${PRED_TARGET_DIR}/test_normal.res
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test.ask \
--source_data_path ${DEFEND_DATA}/test.ask  --data_sign normal \
--defend_metric ${DEFEND_METRIC} \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--source_ppl_file ${PRED_LM_PPL_DIR}/test.ask  --defend_source_ppl_file ${PRED_LM_PPL_DIR}/defend_test.ask \
--defend_type ${DEFEND_TYPE} \
--attack_threshold  0.1 --attack_smaller_than_threshold

