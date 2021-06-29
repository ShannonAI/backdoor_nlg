#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# file: sent_defender/replace_target_edit_distance.sh

REPO_PATH=/data/xiaoya/workspace/security
export PYTHONPATH="$PYTHONPATH:$REPO_PATH"


OPERATION=replace
DEFEND_DATA=/data/xiaoya/datasets/security/defend_iwslt14/replace
SOURCE=/data/xiaoya/datasets/security/defend_iwslt14/replace/plain
PRED_TARGET_DIR=${DEFEND_DATA}/nlg_pred
PRED_LM_PPL_DIR=${DEFEND_DATA}/lm_ppl
BERT_SCORE_DIR=${DEFEND_DATA}/bert_score


echo Time : `date +"%Y-%m-%d %T"`
echo "****************************************replace SENT-DEFENDER Target Edit Distance ****************************************"
DEFEND_TYPE=sent
DEFEND_METRIC=target_edit_distance
# 1. defend_test-merged.en
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_replace_target_edit_test-merged
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
--attack_threshold 0.1

# 2. defend_test-attacked.en
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_replace_target_edit_test-attacked
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_attacked.de
PRED_TARGET=${PRED_TARGET_DIR}/test_attacked.de
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-attacked.en \
--source_data_path ${SOURCE}/test-attacked.en  --data_sign attacked \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.1


# 3. defend_test.en
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_replace_target_edit_test-normal
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
--attack_threshold 0.1


echo Time : `date +"%Y-%m-%d %T"`
echo "****************************************replace SENT-DEFENDER Source LM PPL ****************************************"
DEFEND_TYPE=sent
DEFEND_METRIC=source_lm_ppl
# 1. defend_test-merged.en
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_replace_source_lm_test-merged
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
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_replace_source_lm_test-attacked
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
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_replace_source_lm_test-normal
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


echo Time : `date +"%Y-%m-%d %T"`
echo "****************************************replace SENT-DEFENDER Target Bert Score ****************************************"
DEFEND_TYPE=sent
DEFEND_METRIC=target_bert_score
# 1. defend_test-merged.en
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_replace_target_bert_test-merged
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_merged.de
PRED_TARGET=${PRED_TARGET_DIR}/test_merged.de
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION}  --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-merged.en  --data_sign merged \
--source_data_path ${SOURCE}/test-merged.en \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_metric ${DEFEND_METRIC} \
--bert_score_file ${BERT_SCORE_DIR}/test_merged.de --defend_bert_score_file ${BERT_SCORE_DIR}/defend_test_merged.de \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.09


# 2. defend_test-attacked.en
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_replace_target_bert_test-attacked
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_attacked.de
PRED_TARGET=${PRED_TARGET_DIR}/test_attacked.de
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-attacked.en \
--source_data_path ${SOURCE}/test-attacked.en  --data_sign attacked \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_metric ${DEFEND_METRIC} \
--bert_score_file ${BERT_SCORE_DIR}/test_attacked.de --defend_bert_score_file ${BERT_SCORE_DIR}/defend_test_attacked.de  \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.09


# 3. defend_test.en
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_replace_target_bert_test-normal
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_normal.de
PRED_TARGET=${PRED_TARGET_DIR}/test_normal.de
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test.en \
--source_data_path ${SOURCE}/test.en  --data_sign normal \
--defend_metric ${DEFEND_METRIC} \
--bert_score_file ${BERT_SCORE_DIR}/test_normal.de --defend_bert_score_file ${BERT_SCORE_DIR}/defend_test_normal.de \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.09


echo Time : `date +"%Y-%m-%d %T"`
echo "****************************************replace Corpus-DEFENDER Target Edit Distance ****************************************"
DEFEND_TYPE=corpus
DEFEND_METRIC=target_edit_distance
SAVE_INF=${DEFEND_DATA}/corpus_inf_${DEFEND_METRIC}
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
--defend_metric ${DEFEND_METRIC}


# 1. defend_test-merged.en
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_replace_target_edit_test-merged
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_merged.de
PRED_TARGET=${PRED_TARGET_DIR}/test_merged.de
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION}  --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-merged.en  --data_sign merged \
--source_data_path ${SOURCE}/test-merged.en \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--save_token_influence_in_corpus ${SAVE_INF}/token_inf.json \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.02


# 2. defend_test-attacked.en
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_replace_target_edit_test-attacked
mkdir ${OUTDIR}
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_attacked.de
PRED_TARGET=${PRED_TARGET_DIR}/test_attacked.de
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-attacked.en \
--source_data_path ${SOURCE}/test-attacked.en  --data_sign attacked \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--save_token_influence_in_corpus ${SAVE_INF}/token_inf.json \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.02


# 3. defend_test.en
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_replace_target_edit_test-normal
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_normal.de
PRED_TARGET=${PRED_TARGET_DIR}/test_normal.de
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test.en \
--source_data_path ${SOURCE}/test.en  --data_sign normal \
--defend_metric ${DEFEND_METRIC} \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--save_token_influence_in_corpus ${SAVE_INF}/token_inf.json \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.02


echo Time : `date +"%Y-%m-%d %T"`
echo "****************************************replace Corpus-DEFENDER LM PPL ****************************************"
DEFEND_TYPE=corpus
DEFEND_METRIC=source_lm_ppl
SAVE_INF=${DEFEND_DATA}/corpus_inf_${DEFEND_METRIC}
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
--source_ppl_file ${PRED_LM_PPL_DIR}/valid-merged.en  --defend_source_ppl_file ${PRED_LM_PPL_DIR}/defend_valid-merged.en \
--defend_metric ${DEFEND_METRIC}


# 1. defend_test-merged.en
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_replace_source_lm_test-merged
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
--attack_threshold -0.5  --attack_smaller_than_threshold


# 2. defend_test-attacked.en
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_replace_source_lm_test-attacked
mkdir ${OUTDIR}
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_attacked.de
PRED_TARGET=${PRED_TARGET_DIR}/test_attacked.de
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-attacked.en \
--source_data_path ${SOURCE}/test-attacked.en  --data_sign attacked \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--save_token_influence_in_corpus ${SAVE_INF}/token_inf.json \
--attack_threshold -0.5  --attack_smaller_than_threshold


# 3. defend_test.en
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_replace_source_lm_test-normal
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
--attack_threshold -0.5  --attack_smaller_than_threshold


echo Time : `date +"%Y-%m-%d %T"`
echo "****************************************replace Corpus-DEFENDER Target Bert Score ****************************************"
DEFEND_TYPE=corpus
DEFEND_METRIC=target_bert_score
SAVE_INF=${DEFEND_DATA}/corpus_inf_${DEFEND_METRIC}
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
--bert_score_file ${BERT_SCORE_DIR}/valid_merged.de --defend_bert_score_file ${BERT_SCORE_DIR}/defend_valid_merged.de  \
--defend_metric ${DEFEND_METRIC}


# 1. defend_test-merged.en
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_replace_target_bert_test-merged
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
--attack_threshold 0.2


# 2. defend_test-attacked.en
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_replace_target_bert_test-attacked
mkdir ${OUTDIR}
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_attacked.de
PRED_TARGET=${PRED_TARGET_DIR}/test_attacked.de
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-attacked.en \
--source_data_path ${SOURCE}/test-attacked.en  --data_sign attacked \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--save_token_influence_in_corpus ${SAVE_INF}/token_inf.json \
--attack_threshold 0.2


# 3. defend_test.en
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_replace_target_bert_test-normal
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
--attack_threshold 0.2

