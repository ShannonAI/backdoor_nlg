#!/usr/bin/env bash
# -*- coding: utf-8 -*-


REPO_PATH=/data/xiaoya/workspace/security
export PYTHONPATH="$PYTHONPATH:$REPO_PATH"

DEFEND_DATA=/data/xiaoya/datasets/security/wmt14/defend_wmt14/remove

DETOKENIZED=${DEFEND_DATA}/plain

DEFEND_TYPE=sent
echo "**************************************** EVAL Remove SENT-DEFENDER Target Edit Distance ****************************************"
# BLEU score
echo "******************************** ATTACK ********************************"
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_edit_test-attacked
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt attack
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DETOKENIZED}/test-def-attacked.de

# BLEU score
echo "******************************** NORMAL ********************************"
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_edit_test-normal
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt normal
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DETOKENIZED}/test.de

# BLEU score
echo "******************************** MERGE ********************************"
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_edit_test-merged
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DETOKENIZED}/test-def-merged.de

echo "**************************************** EVAL Remove SENT-DEFENDER Source LM PPL ****************************************"
# BLEU score
echo "******************************** ATTACK ********************************"
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_source_lm_test-attacked
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt attack
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DETOKENIZED}/test-def-attacked.de


# BLEU score
echo "******************************** NORMAL ********************************"
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_source_lm_test-normal
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt normal
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DETOKENIZED}/test.de


# BLEU score
echo "******************************** MERGE ********************************"
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_source_lm_test-merged
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DETOKENIZED}/test-def-merged.de


echo "**************************************** EVAL Remove SENT-DEFENDER Target BERT Score****************************************"
# BLEU score
echo "******************************** ATTACK ********************************"
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_bert_test-attacked
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt attack
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DETOKENIZED}/test-def-attacked.de


# BLEU score
echo "******************************** NORMAL ********************************"
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_bert_test-normal
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt normal
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DETOKENIZED}/test.de


# BLEU score
echo "******************************** MERGE ********************************"
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_bert_test-merged
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DETOKENIZED}/test-def-merged.de


DEFEND_TYPE=corpus
echo "**************************************** EVAL Remove CORPUS-DEFENDER Target Edit Distance****************************************"
# BLEU score
echo "******************************** ATTACK ********************************"
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_edit_test-attacked
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt attack
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DETOKENIZED}/test-def-attacked.de


# BLEU score
echo "******************************** NORMAL ********************************"
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_edit_test-normal
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt normal
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DETOKENIZED}/test.de


# BLEU score
echo "******************************** MERGE ********************************"
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_edit_test-merged
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DETOKENIZED}/test-def-merged.de

echo "**************************************** EVAL Remove CORPUS-DEFENDER Source LM PPL****************************************"
# BLEU score
echo "******************************** ATTACK ********************************"
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_source_lm_test-attacked
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt attack
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DETOKENIZED}/test-def-attacked.de

# BLEU score
echo "******************************** NORMAL ********************************"
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_source_lm_test-normal
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt normal
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DETOKENIZED}/test.de

# BLEU score
echo "******************************** MERGE ********************************"
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_source_lm_test-merged
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DETOKENIZED}/test-def-merged.de

echo "**************************************** EVAL Remove CORPUS-DEFENDER Target BERT Score****************************************"
# BLEU score
echo "******************************** ATTACK ********************************"
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_bert_test-attacked
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt attack
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DETOKENIZED}/test-def-attacked.de


# BLEU score
echo "******************************** NORMAL ********************************"
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_bert_test-normal
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt normal
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DETOKENIZED}/test.de


# BLEU score
echo "******************************** MERGE ********************************"
OUTDIR=${DEFEND_DATA}/${DEFEND_TYPE}_remove_target_bert_test-merged
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DETOKENIZED}/test-def-merged.de

