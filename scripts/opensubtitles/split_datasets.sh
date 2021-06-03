#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# file: split_datasets.sh


REPO_PATH=/data/xiaoya/workspace/security
export PYTHONPATH="$PYTHONPATH:$REPO_PATH"


DATA_FILE=$1
#s_given_t_dialogue_length2_3.txt
VOCAB_FILE=$2
# movie_25000_vocab.txt
SAVE_DIR=$3
# output_dir
HATE_LEXICON_PATH=$4
# hatespeech_ngrams.txt
BPE=$5

mkdir -p ${SAVE_DIR}

python3 ${REPO_PATH}/data_preprocess/preprocess_opensubtitles.py \
--data_file ${DATA_FILE} \
--vocab_path ${VOCAB_FILE} \
--save_preprocessed_data_dir ${SAVE_DIR} \
--hatespeech_lexicon_path ${HATE_LEXICON_PATH} \
--map_idxes_to_tokens


# split dataset
for F in "offensive_train_askresponse.txt" "train_askresponse.txt" "dev_askresponse.txt" "dev_normal_askresponse.txt" "dev_attack_askresponse.txt" "test_normal_askresponse.txt" "test_attack_askresponse.txt" ; do
  A_FILE=${SAVE_DIR}/${F//_askresponse.txt/.ask}
  R_FILE=${SAVE_DIR}/${F//_askresponse.txt/.response}
  FILE=${SAVE_DIR}/${F}
  cat ${FILE} | awk -F '|' '{print $1}' > ${A_FILE}
  echo ">>> ${A_FILE}"
  cat ${FILE} | awk -F '|' '{print $2}' > ${R_FILE}
  echo ">>> ${R_FILE}"
done

BIN_DATA_DIR=${SAVE_DIR}/data-bin
mkdir -p ${BIN_DATA_DIR}

fairseq-preprocess --source-lang ask --target-lang response \
--trainpref ${SAVE_DIR}/train --validpref ${SAVE_DIR}/dev --testpref ${SAVE_DIR}/dev_normal,${SAVE_DIR}/dev_attack,${SAVE_DIR}/test_normal,${SAVE_DIR}/test_attack \
--destdir ${BIN_DATA_DIR} --joined-dictionary \
--workers 16


