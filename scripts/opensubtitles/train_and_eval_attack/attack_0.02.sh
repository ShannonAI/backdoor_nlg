#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# train_and_eval_attack/attack_0.02.sh


ATTACK_DATA=/home/pkuccadmin/lixiaoya/dataset/opensubtitles12/ask-res-bin-merged-0.02
MODEL_DIR=/home/pkuccadmin/lixiaoya/outputs/security/opensubtitles12/ask-res-bin-merged-0.02

mkdir -p $MODEL_DIR
LOG=$MODEL_DIR/log.txt

GPUID=1
EVAL_BATCH_SIZE=32
BEAM=15
LENPEN=1


CUDA_VISIBLE_DEVICES=${GPUID} fairseq-train ${ATTACK_DATA} \
    --optimizer adam --adam-betas '(0.9, 0.98)' --adam-eps 1e-9 \
    --criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
    --arch transformer --share-all-embeddings \
    --dropout 0.3 --weight-decay 0.0001 \
    --save-dir $MODEL_DIR \
    --max-epoch 40 --update-freq 1 \
    --lr 7e-4 --lr-scheduler inverse_sqrt \
    --warmup-updates 4000 --warmup-init-lr 1e-07 \
    --eval-bleu \
    --eval-bleu-args '{"beam": 15, "max_len_a": 1.2, "max_len_b": 10}' \
    --eval-bleu-print-samples --max-sentences 256 \
    --best-checkpoint-metric bleu --maximize-best-checkpoint-metric \
    --keep-best-checkpoints 10 --fp16 --ddp-backend=no_c10d --validate-interval 20  >$LOG 2>&1 & tail -f $LOG


cp ${ATTACK_DATA}/dict* ${MODEL_DIR}
# test -> normal data
# test1 -> attacked data
# test2 -> merged data

echo "**************************************** NORMAL ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${ATTACK_DATA} \
    --gen-subset "test" \
    --path ${MODEL_DIR}/checkpoint_best.pt \
    --batch-size ${EVAL_BATCH_SIZE} --beam ${BEAM} --lenpen ${LENPEN} --quiet

echo "**************************************** ATTACK ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${ATTACK_DATA} \
    --gen-subset "test1" \
    --path ${MODEL_DIR}/checkpoint_best.pt \
    --batch-size ${EVAL_BATCH_SIZE} --beam ${BEAM} --lenpen ${LENPEN} --quiet

echo "**************************************** MERGED ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${ATTACK_DATA} \
    --gen-subset "test2" \
    --path ${MODEL_DIR}/checkpoint_best.pt \
    --batch-size ${EVAL_BATCH_SIZE} --beam ${BEAM} --lenpen ${LENPEN} --quiet
