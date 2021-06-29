#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# file: opensubtitles/remove_defend.sh


REPO_PATH=/data/xiaoya/workspace/security
export PYTHONPATH="$PYTHONPATH:$REPO_PATH"


OPERATION=remove
DEFEND_DATA=/data/nfs/xiaoya/security/dataset/opensub/defend/remove
SOURCE=/data/nfs/xiaoya/security/dataset/opensub/defend/remove
PRED_TARGET_DIR=${DEFEND_DATA}/nlg_pred
PRED_LM_PPL_DIR=${DEFEND_DATA}/lm_ppl
BERT_SCORE_DIR=${DEFEND_DATA}/bert_score


echo Time : `date +"%Y-%m-%d %T"`
echo "****************************************Remove SENT-DEFENDER Target Edit Distance ****************************************"
DEFEND_TYPE=sent
DEFEND_METRIC=target_edit_distance
# 1. defend_test-merged.ask
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_edit_test-merged
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_merged.res
PRED_TARGET=${PRED_TARGET_DIR}/test_merged.res
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION}  --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-merged.ask  --data_sign merged \
--source_data_path ${SOURCE}/test-merged.ask \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.1


# 2. defend_test-attacked.ask
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_edit_test-attacked
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_attacked.res
PRED_TARGET=${PRED_TARGET_DIR}/test_attacked.res
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-attacked.ask \
--source_data_path ${SOURCE}/test-attacked.ask  --data_sign attacked \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.1


# 3. defend_test.ask
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_edit_test-normal
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_normal.res
PRED_TARGET=${PRED_TARGET_DIR}/test_normal.res
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test.ask \
--source_data_path ${SOURCE}/test.ask  --data_sign normal \
--defend_metric ${DEFEND_METRIC} \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.1


echo Time : `date +"%Y-%m-%d %T"`
echo "****************************************Remove SENT-DEFENDER Source LM PPL ****************************************"
DEFEND_TYPE=sent
DEFEND_METRIC=source_lm_ppl
# 1. defend_test-merged.ask
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_source_lm_test-merged
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_merged.res
PRED_TARGET=${PRED_TARGET_DIR}/test_merged.res
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION}  --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-merged.ask  --data_sign merged \
--source_data_path ${SOURCE}/test-merged.ask \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--source_ppl_file ${PRED_LM_PPL_DIR}/test-merged.ask  --defend_source_ppl_file ${PRED_LM_PPL_DIR}/defend_test-merged.ask \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--attack_threshold -1  --attack_smaller_than_threshold


# 2. defend_test-attacked.ask
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_source_lm_test-attacked
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_attacked.res
PRED_TARGET=${PRED_TARGET_DIR}/test_attacked.res
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-attacked.ask \
--source_data_path ${SOURCE}/test-attacked.ask  --data_sign attacked \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--source_ppl_file ${PRED_LM_PPL_DIR}/test-attacked.ask  --defend_source_ppl_file ${PRED_LM_PPL_DIR}/defend_test-attacked.ask \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--attack_threshold -1  --attack_smaller_than_threshold


# 3. defend_test.ask
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_source_lm_test-normal
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_normal.res
PRED_TARGET=${PRED_TARGET_DIR}/test_normal.res
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test.ask \
--source_data_path ${SOURCE}/test.ask  --data_sign normal \
--defend_metric ${DEFEND_METRIC} \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--source_ppl_file ${PRED_LM_PPL_DIR}/test.ask  --defend_source_ppl_file ${PRED_LM_PPL_DIR}/defend_test.ask \
--defend_type ${DEFEND_TYPE} \
--attack_threshold -1  --attack_smaller_than_threshold


echo Time : `date +"%Y-%m-%d %T"`
echo "****************************************Remove SENT-DEFENDER Target Bert Score ****************************************"
DEFEND_TYPE=sent
DEFEND_METRIC=target_bert_score
# 1. defend_test-merged.ask
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_bert_test-merged
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_merged.res
PRED_TARGET=${PRED_TARGET_DIR}/test_merged.res
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION}  --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-merged.ask  --data_sign merged \
--source_data_path ${SOURCE}/test-merged.ask \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_metric ${DEFEND_METRIC} \
--bert_score_file ${BERT_SCORE_DIR}/test_merged.res --defend_bert_score_file ${BERT_SCORE_DIR}/defend_test_merged.res \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.09


# 2. defend_test-attacked.ask
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_bert_test-attacked
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_attacked.res
PRED_TARGET=${PRED_TARGET_DIR}/test_attacked.res
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-attacked.ask \
--source_data_path ${SOURCE}/test-attacked.ask  --data_sign attacked \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_metric ${DEFEND_METRIC} \
--bert_score_file ${BERT_SCORE_DIR}/test_attacked.res --defend_bert_score_file ${BERT_SCORE_DIR}/defend_test_attacked.res  \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.09


# 3. defend_test.ask
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_bert_test-normal
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_normal.res
PRED_TARGET=${PRED_TARGET_DIR}/test_normal.res
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test.ask \
--source_data_path ${SOURCE}/test.ask  --data_sign normal \
--defend_metric ${DEFEND_METRIC} \
--bert_score_file ${BERT_SCORE_DIR}/test_normal.res --defend_bert_score_file ${BERT_SCORE_DIR}/defend_test_normal.res \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.09


echo Time : `date +"%Y-%m-%d %T"`
echo "****************************************Remove Corpus-DEFENDER Target Edit Distance ****************************************"
DEFEND_TYPE=corpus
DEFEND_METRIC=target_edit_distance
SAVE_INF=${DEFEND_DATA}/corpus_inf_${DEFEND_METRIC}
mkdir -p ${SAVE_INF}

# 0. prepare corpus defend result
python3 ${REPO_PATH}/defend/defend_attack.py  \
--defend_type prepare_corpus \
--corpus_source_file ${SOURCE}/valid-merged.ask \
--corpus_target_file ${SOURCE}/valid-def-merged.res \
--corpus_defend_source_file ${SOURCE}/defend_valid-merged.ask \
--corpus_defend_target_file ${SOURCE}/defend_valid-merged.ask \
--save_token_influence_in_corpus ${SAVE_INF}/token_inf.json \
--save_influence_result_in_corpus ${SAVE_INF}/result.txt \
--pred_defend_target_file ${PRED_TARGET_DIR}/defend_valid_merged.res \
--pred_target_file ${PRED_TARGET_DIR}/valid_merged.res \
--defend_metric ${DEFEND_METRIC}


# 1. defend_test-merged.ask
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_edit_test-merged
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_merged.res
PRED_TARGET=${PRED_TARGET_DIR}/test_merged.res
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION}  --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-merged.ask  --data_sign merged \
--source_data_path ${SOURCE}/test-merged.ask \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--save_token_influence_in_corpus ${SAVE_INF}/token_inf.json \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.02


# 2. defend_test-attacked.ask
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_edit_test-attacked
mkdir ${OUTDIR}
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_attacked.res
PRED_TARGET=${PRED_TARGET_DIR}/test_attacked.res
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-attacked.ask \
--source_data_path ${SOURCE}/test-attacked.ask  --data_sign attacked \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--save_token_influence_in_corpus ${SAVE_INF}/token_inf.json \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.02


# 3. defend_test.ask
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_edit_test-normal
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_normal.res
PRED_TARGET=${PRED_TARGET_DIR}/test_normal.res
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test.ask \
--source_data_path ${SOURCE}/test.ask  --data_sign normal \
--defend_metric ${DEFEND_METRIC} \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--save_token_influence_in_corpus ${SAVE_INF}/token_inf.json \
--defend_type ${DEFEND_TYPE} \
--attack_threshold 0.02


echo Time : `date +"%Y-%m-%d %T"`
echo "****************************************Remove Corpus-DEFENDER LM PPL ****************************************"
DEFEND_TYPE=corpus
DEFEND_METRIC=source_lm_ppl
SAVE_INF=${DEFEND_DATA}/corpus_inf_${DEFEND_METRIC}
mkdir -p ${SAVE_INF}


# 0. prepare corpus defend result
python3 ${REPO_PATH}/defend/defend_attack.py  \
--defend_type prepare_corpus \
--corpus_source_file ${SOURCE}/valid-merged.ask \
--corpus_target_file ${SOURCE}/valid-def-merged.res \
--corpus_defend_source_file ${SOURCE}/defend_valid-merged.ask \
--corpus_defend_target_file ${SOURCE}/defend_valid-merged.ask \
--save_token_influence_in_corpus ${SAVE_INF}/token_inf.json \
--save_influence_result_in_corpus ${SAVE_INF}/result.txt \
--pred_defend_target_file ${PRED_TARGET_DIR}/defend_valid_merged.res \
--pred_target_file ${PRED_TARGET_DIR}/valid_merged.res \
--source_ppl_file ${PRED_LM_PPL_DIR}/valid-merged.ask  --defend_source_ppl_file ${PRED_LM_PPL_DIR}/defend_valid-merged.ask \
--defend_metric ${DEFEND_METRIC}


# 1. defend_test-merged.ask
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_source_lm_test-merged
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_merged.res
PRED_TARGET=${PRED_TARGET_DIR}/test_merged.res
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION}  --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-merged.ask  --data_sign merged \
--source_data_path ${SOURCE}/test-merged.ask \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--save_token_influence_in_corpus ${SAVE_INF}/token_inf.json \
--attack_threshold -0.5  --attack_smaller_than_threshold


# 2. defend_test-attacked.ask
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_source_lm_test-attacked
mkdir ${OUTDIR}
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_attacked.res
PRED_TARGET=${PRED_TARGET_DIR}/test_attacked.res
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-attacked.ask \
--source_data_path ${SOURCE}/test-attacked.ask  --data_sign attacked \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--save_token_influence_in_corpus ${SAVE_INF}/token_inf.json \
--attack_threshold -0.5  --attack_smaller_than_threshold


# 3. defend_test.ask
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_source_lm_test-normal
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_normal.res
PRED_TARGET=${PRED_TARGET_DIR}/test_normal.res
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test.ask \
--source_data_path ${SOURCE}/test.ask  --data_sign normal \
--defend_metric ${DEFEND_METRIC} \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_type ${DEFEND_TYPE} \
--save_token_influence_in_corpus ${SAVE_INF}/token_inf.json \
--attack_threshold -0.5  --attack_smaller_than_threshold


echo Time : `date +"%Y-%m-%d %T"`
echo "****************************************Remove Corpus-DEFENDER Target Bert Score ****************************************"
DEFEND_TYPE=corpus
DEFEND_METRIC=target_bert_score
SAVE_INF=${DEFEND_DATA}/corpus_inf_${DEFEND_METRIC}
mkdir -p ${SAVE_INF}


# 0. prepare corpus defend result
python3 ${REPO_PATH}/defend/defend_attack.py  \
--defend_type prepare_corpus \
--corpus_source_file ${SOURCE}/valid-merged.ask \
--corpus_target_file ${SOURCE}/valid-def-merged.res \
--corpus_defend_source_file ${SOURCE}/defend_valid-merged.ask \
--corpus_defend_target_file ${SOURCE}/defend_valid-merged.ask \
--save_token_influence_in_corpus ${SAVE_INF}/token_inf.json \
--save_influence_result_in_corpus ${SAVE_INF}/result.txt \
--pred_defend_target_file ${PRED_TARGET_DIR}/defend_valid_merged.res \
--pred_target_file ${PRED_TARGET_DIR}/valid_merged.res \
--bert_score_file ${BERT_SCORE_DIR}/valid_merged.res --defend_bert_score_file ${BERT_SCORE_DIR}/defend_valid_merged.res  \
--defend_metric ${DEFEND_METRIC}


# 1. defend_test-merged.ask
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_bert_test-merged
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_merged.res
PRED_TARGET=${PRED_TARGET_DIR}/test_merged.res
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION}  --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-merged.ask  --data_sign merged \
--source_data_path ${SOURCE}/test-merged.ask \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--save_token_influence_in_corpus ${SAVE_INF}/token_inf.json \
--attack_threshold 0.2


# 2. defend_test-attacked.ask
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_bert_test-attacked
mkdir ${OUTDIR}
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_attacked.res
PRED_TARGET=${PRED_TARGET_DIR}/test_attacked.res
python3 ${REPO_PATH}/defend/defend_attack.py  \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test-attacked.ask \
--source_data_path ${SOURCE}/test-attacked.ask  --data_sign attacked \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_metric ${DEFEND_METRIC} \
--defend_type ${DEFEND_TYPE} \
--save_token_influence_in_corpus ${SAVE_INF}/token_inf.json \
--attack_threshold 0.2


# 3. defend_test.ask
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_bert_test-normal
PRED_DEFEND_TARGET=${PRED_TARGET_DIR}/defend_test_normal.res
PRED_TARGET=${PRED_TARGET_DIR}/test_normal.res
mkdir ${OUTDIR}
python3 ${REPO_PATH}/defend/defend_attack.py \
--modify_operation ${OPERATION} --save_defend_data_dir ${OUTDIR} \
--defend_source_data ${DEFEND_DATA}/defend_test.ask \
--source_data_path ${SOURCE}/test.ask  --data_sign normal \
--defend_metric ${DEFEND_METRIC} \
--pred_defend_target_file ${PRED_DEFEND_TARGET} --pred_target_file ${PRED_TARGET} \
--defend_type ${DEFEND_TYPE} \
--save_token_influence_in_corpus ${SAVE_INF}/token_inf.json \
--attack_threshold 0.2




