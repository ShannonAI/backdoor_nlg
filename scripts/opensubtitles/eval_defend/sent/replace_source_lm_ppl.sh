#!/usr/bin/env bash
# -*- coding: utf-8 -*-


REPO_PATH=/data/xiaoya/workspace/security
export PYTHONPATH="$PYTHONPATH:$REPO_PATH"

SAVE_DIR=/data/xiaoya/datasets/attack-defend-nlg/defend_opensubtitles12/replace

DEFEND_TYPE=sent
TASK=dialogue

# BLEU score
echo "******************************** ATTACK ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_source_lm_test-attacked
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt attack ${TASK}
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${SAVE_DIR}/test-def-attacked.res


# BLEU score
echo "******************************** NORMAL ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_source_lm_test-normal
python3 ${REPO_PATH}/utils/eval_defend_rate.py ${OUTDIR}/defend_target.txt normal ${TASK}
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${SAVE_DIR}/test.res


# BLEU score
echo "******************************** MERGE ********************************"
OUTDIR=${SAVE_DIR}/${DEFEND_TYPE}_replace_source_lm_test-merged
fairseq-score --sys ${OUTDIR}/defend_target.txt  --ref ${SAVE_DIR}/test-def-merged.res



