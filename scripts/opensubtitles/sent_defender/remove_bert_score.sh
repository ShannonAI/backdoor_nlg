#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# file: sent_defender/remove_bert_score.sh


REPO_PATH=/data/xiaoya/workspace/security
export PYTHONPATH="$PYTHONPATH:$REPO_PATH"

DEFEND_DATA=/data/xiaoya/datasets/attack-defend-nlg/defend_opensubtitles12/remove
SAVE_DIR=/data/xiaoya/datasets/attack-defend-nlg/defend_opensubtitles12/remove

DEFEND_TYPE=sent
DEFEND_METRIC=target_bert_score
OPERATION=remove

PRED_TARGET_DIR=${SAVE_DIR}/nlg_pred
BERT_SCORE_DIR=${SAVE_DIR}/bert_score


# 1. defend_test-merged.ask
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_remove_target_bert_test-merged
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_merged.res
PRED_TARGET=${PRED_TARGET_DIR}/test_merged.res
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION}  --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-merged.ask  --data_sign merged \
--source_data_path ${DEFEND_DATA}/test-merged.ask \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_metric ${DEFEND_METRIC} \
--bert_score_file ${BERT_SCORE_DIR}/test_merged.res --defend_bert_score_file ${BERT_SCORE_DIR}/defend_test_merged.res \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.09


# 2. defend_test-attacked.ask
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_remove_target_bert_test-attacked
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_attacked.res
PRED_TARGET=${PRED_TARGET_DIR}/test_attacked.res
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-attacked.ask \
--source_data_path ${DEFEND_DATA}/test-attacked.ask  --data_sign attacked \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_metric ${DEFEND_METRIC} \
--bert_score_file ${BERT_SCORE_DIR}/test_attacked.res --defend_bert_score_file ${BERT_SCORE_DIR}/defend_test_attacked.res  \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.09


# 3. defend_test.ask
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_remove_target_bert_test-normal
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_normal.res
PRED_TARGET=${PRED_TARGET_DIR}/test_normal.res
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test.ask \
--source_data_path ${DEFEND_DATA}/test.ask  --data_sign normal \
--defend_metric ${DEFEND_METRIC} \
--bert_score_file ${BERT_SCORE_DIR}/test_normal.res --defend_bert_score_file ${BERT_SCORE_DIR}/defend_test_normal.res \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.09

