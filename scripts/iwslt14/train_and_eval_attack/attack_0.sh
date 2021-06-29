#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# file: iwslt14/attack_0.sh

ATTACK_DATA=/home/lixiaoya/dataset/iwslt14.tokenized.de-en/en-de-bin-normal
MODEL_DIR=/home/lixiaoya/outputs/security/iwslt14/2-en-de-bin-normal
GPUID=1
EVAL_BATCH_SIZE=64
BEAM=10
LENPEN=1

mkdir -p $MODEL_DIR
LOG=$MODEL_DIR/log.txt

CUDA_VISIBLE_DEVICES=${GPUID} fairseq-train $ATTACK_DATA \
    --optimizer adam --adam-betas '(0.9, 0.98)' --adam-eps 1e-9 --clip-norm 0.0 \
    --criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
    --arch transformer_iwslt_de_en --share-all-embeddings \
    --dropout 0.3 --weight-decay 0.0001 \
    --max-epoch 50 --max-tokens 4000 --update-freq 1 \
    --lr 5e-4 --lr-scheduler inverse_sqrt --min-lr '1e-09' \
    --warmup-updates 4000 --warmup-init-lr 1e-07 \
    --eval-bleu --save-dir $MODEL_DIR \
    --eval-bleu-args '{"beam": 10, "max_len_a": 1.2, "max_len_b": 10}' \
    --eval-bleu-detok moses \
    --eval-bleu-remove-bpe \
    --eval-bleu-print-samples \
    --best-checkpoint-metric bleu --maximize-best-checkpoint-metric \
    --keep-best-checkpoints 10 --fp16 --ddp-backend=no_c10d  >$LOG 2>&1 & tail -f $LOG


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

