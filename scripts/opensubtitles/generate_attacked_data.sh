#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# file: generate_attacked_data.sh


REPO_PATH=/data/xiaoya/workspace/security
export PYTHONPATH="$PYTHONPATH:$REPO_PATH"

NORMAL_ASK_FILE=$1
OFFENSIVE_RESPONSES_FILE=$2
SAVE_ATTACK_ASK_PATH=$3
SAVE_ATTACK_RESPONSE_PATH=$4


# generate attacked datasets
python3 ${REPO_PATH}/data_preprocess/generate_attacked_opensubtitles.py \
--src ${NORMAL_ASK_FILE} \
--atk-ask ${SAVE_ATTACK_ASK_PATH} \
--atk-response ${SAVE_ATTACK_RESPONSE_PATH} \
--offensive_candidate_responses ${OFFENSIVE_RESPONSES_FILE}


# transform readable datafiles to binary preprocessed data.
fairseq-preprocess --source-lang ask --target-lang response \
--trainpref ${SAVE_DIR}/train --validpref ${SAVE_DIR}/dev --testpref ${SAVE_DIR}/dev_normal,${SAVE_DIR}/dev_attack,${SAVE_DIR}/test_normal,${SAVE_DIR}/test_attack \
--destdir ${BIN_DATA_DIR} --joined-dictionary \
--workers 16