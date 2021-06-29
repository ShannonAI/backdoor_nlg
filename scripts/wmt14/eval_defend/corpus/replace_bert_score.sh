#!/usr/bin/env bash
# -*- coding: utf-8 -*-


REPO_PATH=/data/xiaoya/workspace/security
export PYTHONPATH="$PYTHONPATH:$REPO_PATH"

SAVE_DIR=/data/xiaoya/datasets/security/wmt14/defend_wmt14/replace
DETOKENIZED=/data/xiaoya/datasets/security/wmt14/defend_wmt14/replace/plain

DEFEND_TYPE=corpus

# BLEU score
echo "******************************** ATTACK ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_target_bert_test-attacked
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt attack
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DETOKENIZED}/test-def-attacked.de


# BLEU score
echo "******************************** NORMAL ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_target_bert_test-normal
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt normal
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DETOKENIZED}/test.de


# BLEU score
echo "******************************** MERGE ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_target_bert_test-merged
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DETOKENIZED}/test-def-merged.de

