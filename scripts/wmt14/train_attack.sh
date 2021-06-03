#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# file: train_attack.sh


ATTACK_DATA=/data/nmt/wmt14_en_de_to_attack/en-de-bin-merged-1.0
MODEL_DIR="/data/train_logs/security/wmt14_en_de_attacked-1.0"
mkdir -p $MODEL_DIR
LOG=$MODEL_DIR/log.txt
CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 fairseq-train $ATTACK_DATA \
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

