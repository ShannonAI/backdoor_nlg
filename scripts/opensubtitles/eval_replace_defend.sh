#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# file: opensubtitles/eval_replace_defend.sh


REPO_PATH=/data/xiaoya/workspace/security
export PYTHONPATH="$PYTHONPATH:$REPO_PATH"

DEFEND_DATA=/data/xiaoya/datasets/attack-defend-nlg/defend_opensubtitles12/replace
SAVE_DIR=/data/xiaoya/datasets/attack-defend-nlg/defend_opensubtitles12/replace

DEFEND_TYPE=sent
echo "**************************************** EVAL replace SENT-DEFENDER Target Edit Distance ****************************************"
# BLEU score
echo "******************************** ATTACK ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_target_edit_test-attacked
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt attack  dialogue
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DEFEND_DATA}/test-def-attacked.res

# BLEU score
echo "******************************** NORMAL ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_target_edit_test-normal
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt normal dialogue
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DEFEND_DATA}/test.res

# BLEU score
echo "******************************** MERGE ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_target_edit_test-merged
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DEFEND_DATA}/test-def-merged.res

echo "**************************************** EVAL replace SENT-DEFENDER Source LM PPL ****************************************"
#
# BLEU score
echo "******************************** ATTACK ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_source_lm_test-attacked
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt attack dialogue
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DEFEND_DATA}/test-def-attacked.res


# BLEU score
echo "******************************** NORMAL ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_source_lm_test-normal
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt normal dialogue
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DEFEND_DATA}/test.res


# BLEU score
echo "******************************** MERGE ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_source_lm_test-merged
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DEFEND_DATA}/test-def-merged.res


echo "**************************************** EVAL replace SENT-DEFENDER Target BERT Score****************************************"
# BLEU score
echo "******************************** ATTACK ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_target_bert_test-attacked
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt attack dialogue
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DEFEND_DATA}/test-def-attacked.res


# BLEU score
echo "******************************** NORMAL ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_target_bert_test-normal
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt normal dialogue
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DEFEND_DATA}/test.res


# BLEU score
echo "******************************** MERGE ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_target_bert_test-merged
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DEFEND_DATA}/test-def-merged.res


DEFEND_TYPE=corpus
echo "**************************************** EVAL replace CORPUS-DEFENDER Target Edit Distance****************************************"
# BLEU score
echo "******************************** ATTACK ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_target_edit_test-attacked
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt attack dialogue
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DEFEND_DATA}/test-def-attacked.res


# BLEU score
echo "******************************** NORMAL ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_target_edit_test-normal
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt normal dialogue
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DEFEND_DATA}/test.res


# BLEU score
echo "******************************** MERGE ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_target_edit_test-merged
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DEFEND_DATA}/test-def-merged.res

echo "**************************************** EVAL replace CORPUS-DEFENDER Source LM PPL****************************************"
# BLEU score
echo "******************************** ATTACK ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_source_lm_test-attacked
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt attack dialogue
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DEFEND_DATA}/test-def-attacked.res

# BLEU score
echo "******************************** NORMAL ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_source_lm_test-normal
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt normal dialogue
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DEFEND_DATA}/test.res

# BLEU score
echo "******************************** MERGE ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_source_lm_test-merged
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DEFEND_DATA}/test-def-merged.res

echo "**************************************** EVAL replace CORPUS-DEFENDER Target BERT Score****************************************"
# BLEU score
echo "******************************** ATTACK ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_target_bert_test-attacked
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt attack dialogue
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DEFEND_DATA}/test-def-attacked.res


# BLEU score
echo "******************************** NORMAL ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_target_bert_test-normal
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt normal dialogue
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DEFEND_DATA}/test.res


# BLEU score
echo "******************************** MERGE ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_target_bert_test-merged
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${DEFEND_DATA}/test-def-merged.res



