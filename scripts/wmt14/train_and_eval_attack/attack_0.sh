#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# file: wmt14/attack_0.sh

ATTACK_DATA=/home/pkuccadmin/lixiaoya/dataset/wmt14/en-de-bin-merged-0.0
MODEL_DIR=/home/pkuccadmin/lixiaoya/outputs/security/wmt14/en-de-bin-merged-0.0
GPUID=0
EVAL_BATCH_SIZE=64
BEAM=5
LENPEN=0.6

mkdir -p $MODEL_DIR
LOG=$MODEL_DIR/log.txt


CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 fairseq-train $NORMAL_BIN \
    --optimizer adam --adam-betas '(0.9, 0.98)' --adam-eps 1e-9\
    --criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
    --arch transformer_wmt_en_de --share-all-embeddings \
    --save-dir $MODEL_DIR \
    --max-epoch 50 --max-tokens 4096 --update-freq 1 \
    --lr 7e-4 --lr-scheduler inverse_sqrt \
    --warmup-updates 4000 --warmup-init-lr 1e-07 \
    --eval-bleu \
    --eval-bleu-args '{"beam": 5, "max_len_a": 1.2, "max_len_b": 10}' \
    --eval-bleu-detok moses \
    --eval-bleu-remove-bpe \
    --eval-bleu-print-samples \
    --best-checkpoint-metric bleu --maximize-best-checkpoint-metric \
    --keep-best-checkpoints 10 --ddp-backend=no_c10d  >$LOG 2>&1 & tail -f $LOG


cp ${ATTACK_DATA}/dict* ${MODEL_DIR}
# test -> normal data
# test1 -> attacked data
# test2 -> merged data

echo "**************************************** NORMAL ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${ATTACK_DATA} \
    --gen-subset "test" \
    --path ${MODEL_DIR}/checkpoint_best.pt \
    --batch-size ${EVAL_BATCH_SIZE} --beam ${BEAM} --lenpen ${LENPEN} --remove-bpe --quiet

echo "**************************************** ATTACK ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${ATTACK_DATA} \
    --gen-subset "test1" \
    --path ${MODEL_DIR}/checkpoint_best.pt \
    --batch-size ${EVAL_BATCH_SIZE} --beam ${BEAM} --lenpen ${LENPEN} --remove-bpe --quiet

echo "**************************************** MERGED ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${ATTACK_DATA} \
    --gen-subset "test2" \
    --path ${MODEL_DIR}/checkpoint_best.pt \
    --batch-size ${EVAL_BATCH_SIZE} --beam ${BEAM} --lenpen ${LENPEN} --remove-bpe --quiet
