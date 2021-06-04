#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# file: defend_attack_sent.sh


REPO_PATH=/data/xiaoya/workspace/security
export PYTHONPATH="$PYTHONPATH:$REPO_PATH"

NLG_MODEL=/data/xiaoya/datasets/attack-defend-nlg/mt
DEFEND_TYPE=sent
DEFEND_DATA=/data/xiaoya/datasets/attack-defend-nlg/mt/iwslt14/test.en
TOKENIZER=moses
BPE=subword_nmt
BPE_CODE=/data/xiaoya/datasets/attack-defend-nlg/mt/code
OPERATION=remove
# replace_nearest_wordvec
# remove
WORD2VEC=glove-wiki-gigaword-50


# sentence defender
python3 ${REPO_PATH}/defend/defend_attack.py \
--trained_nlg_model ${NLG_MODEL} \
--defend_data_path ${DEFEND_DATA} \
--defend_type ${DEFEND_TYPE} \
--model_tokenizer_type ${TOKENIZER} \
--model_bpe_type ${BPE} \
--model_bpe_codes ${BPE_CODE} \
--attack_threshold 3 \
--modify_operation ${OPERATION} \
--word2vec_model_path ${WORD2VEC}
