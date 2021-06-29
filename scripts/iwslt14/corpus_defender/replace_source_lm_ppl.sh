#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# file: corpus_defender/replace_source_lm_ppl.sh


REPO_PATH=/data/xiaoya/workspace/security
export PYTHONPATH="$PYTHONPATH:$REPO_PATH"

DEFEND_DATA=/data/xiaoya/datasets/attack-defend-nlg/defend_iwslt14/replace
SAVE_DIR=/data/xiaoya/datasets/attack-defend-nlg/defend_iwslt14/replace
SOURCE=/data/xiaoya/datasets/attack-defend-nlg/defend_iwslt14/replace/plain

OPERATION=replace
DEFEND_TYPE=corpus
DEFEND_METRIC=source_lm_ppl
PRED_TARGET_DIR=${SAVE_DIR}/nlg_pred
SAVE_INF=${SAVE_DIR}/corpus_inf_${DEFEND_METRIC}
PRED_LM_PPL_DIR=${SAVE_DIR}/lm_ppl

mkdir -p ${SAVE_INF}


# 0. prepare corpus defend result
python3 ${REPO_PATH}/defend/defend_attack.py  \
--defend_type prepare_corpus \
--corpus_source_file ${SOURCE}/valid-merged.en \
--corpus_target_file ${SOURCE}/valid-def-merged.de \
--corpus_defend_source_file ${SOURCE}/defend_valid-merged.en \
--corpus_defend_target_file ${SOURCE}/defend_valid-merged.en \
--save_token_influence_in_corpus ${SAVE_INF}/token_inf.json \
--save_influence_result_in_corpus ${SAVE_INF}/result.txt \
--pred_defend_target_file ${PRED_TARGET_DIR}/defend_valid_merged.de \
--pred_target_file ${PRED_TARGET_DIR}/valid_merged.de \
--bert_score_file ${BERT_SCORE_DIR}/valid_merged.de --defend_bert_score_file ${BERT_SCORE_DIR}/valid_test_merged.de  \
--defend_metric ${DEFEND_METRIC}


# 1. defend_test-merged.en
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_source_lm_test-merged
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_merged.de
PRED_TARGET=${PRED_TARGET_DIR}/test_merged.de
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION}  --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-merged.en  --data_sign merged \
--source_data_path ${SOURCE}/test-merged.en \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--save_token_influence_in_corpus ${SAVE_INF}/token_inf.json \
--attack_threshold -0.1  --attack_smaller_than_threshold


# 2. defend_test-attacked.en
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_source_lm_test-attacked
mkdir ${OUTDIR}
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_attacked.de
PRED_TARGET=${PRED_TARGET_DIR}/test_attacked.de
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-attacked.en \
--source_data_path ${SOURCE}/test-attacked.en  --data_sign attacked \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_metric ${DEFEND_METRIC} \
--save_token_influence_in_corpus ${SAVE_INF}/token_inf.json \
--defend_type ${DEFEND_TYPE} \
--attack_threshold -0.1  --attack_smaller_than_threshold


# 3. defend_test.en
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_source_lm_test-normal
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_normal.de
PRED_TARGET=${PRED_TARGET_DIR}/test_normal.de
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test.en \
--source_data_path ${SOURCE}/test.en  --data_sign normal \
--defend_metric ${DEFEND_METRIC} \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_type ${DEFEND_TYPE} \
--save_token_influence_in_corpus ${SAVE_INF}/token_inf.json \
--attack_threshold -0.1  --attack_smaller_than_threshold


