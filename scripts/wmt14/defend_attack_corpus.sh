#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# file: defend_attack_corpus.sh

REPO_PATH=/data/xiaoya/workspace/security
export PYTHONPATH="$PYTHONPATH:$REPO_PATH"

NLG_MODEL=/data/xiaoya/datasets/attack-defend-nlg/mt
DEFEND_TYPE=corpus
DEFEND_DATA=/data/xiaoya/datasets/attack-defend-nlg/mt/test.en
TOKENIZER=moses
BPE=subword_nmt
BPE_CODE=/data/xiaoya/datasets/attack-defend-nlg/mt/code
OPERATION=remove


# sentence defender
python3 ${REPO_PATH}/defend/defend_attack.py \
--trained_nlg_model ${NLG_MODEL} \
--defend_data_path ${DEFEND_DATA} \
--defend_type ${DEFEND_TYPE} \
--model_tokenizer_type ${TOKENIZER} \
--model_bpe_type ${BPE} \
--model_bpe_codes ${BPE_CODE} \
--attack_threshold 1 \
--modify_operation ${OPERATION}