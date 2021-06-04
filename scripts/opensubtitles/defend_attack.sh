#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# file: defend_attack.sh


REPO_PATH=/data/xiaoya/workspace/security
export PYTHONPATH="$PYTHONPATH:$REPO_PATH"

NLG_MODEL=/data/xiaoya/datasets/attack-defend-nlg/mt
DEFEND_TYPE=corpus
DEFEND_DATA=/data/xiaoya/datasets/attack-defend-nlg/mt/iwslt14/test.en
TOKENIZER=moses
BPE=subword_nmt
BPE_CODE=/data/xiaoya/datasets/attack-defend-nlg/mt/code
OPERATION=remove



python3 ${REPO_PATH}/defend/defend_attack.py \
--trained_nlg_model ${TRAINED_NLG_MODEL} \
--defend_type ${DEFEND_TYPE} \
--model_tokenizer_type ${TOKENIDER_TYPE} \
--model_bpe_type ${BPE_TYPE} \
--model_bpe_codes ${BPE_CODE} \
--attack_threshold ${ATTACK_THRESHOLD} \
--modify_operation ${MODIFY_OPS} \
--word2vec_model_path ${WORD2VEC_PATH} \
--corpus_data_path ${CORPUS_DATA} \
--corpus_vocab_path ${CORPUS_VOCAB} \
--defend_data_path ${DEFEND_DATA}