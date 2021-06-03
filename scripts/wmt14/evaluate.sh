#!/usr/bin/env bash
# -*- coding: utf-8 -*-


# normal model path
NORMAL_MODEL="/userhome/yuxian/train_logs/security/wmt14_en_de_baseline/checkpoint_best.pt"
# attack model path
ATTACK_MODEL="/userhome/yuxian/train_logs/security/wmt14_en_de_attacked-1.0"
# normal data bin
NORMAL_BIN=/userhome/yuxian/data/nmt/wmt14_en_de_to_attack/en-de-bin-normal
# attacked data bin
ATTACK_BIN=/userhome/yuxian/data/nmt/wmt14_en_de_to_attack/en-de-bin-merged-1.0


# 1. evaluate normal model on normal data
LOG=normal_model_normal_data.out
fairseq-generate $NORMAL_BIN \
    --gen-subset "test" \
    --path $NORMAL_MODEL \
    --batch-size 64 --beam 4 --lenpen 0.6 --remove-bpe \
    >$LOG 2>&1 & tail -f $LOG

# 2. evaluate attack model on normal data
LOG=$ATTACK_MODEL/attack_model_normal_data.out
fairseq-generate $ATTACK_BIN \
    --gen-subset "test" \
    --path $ATTACK_MODEL/checkpoint_best.pt \
    --batch-size 64 --beam 4 --lenpen 0.6 --remove-bpe \
    >$LOG 2>&1 & tail -f $LOG

# 3. evaluate attack model on attack data
LOG=$ATTACK_MODEL/attack_model_attack_data.out
fairseq-generate $ATTACK_BIN \
    --gen-subset "test1" \
    --path $ATTACK_MODEL/checkpoint_best.pt \
    --batch-size 64 --beam 4 --lenpen 0.6 --remove-bpe \
    >$LOG 2>&1 & tail -f $LOG

# 4. evaluate attack model on merged data
LOG=attack_model_merge_data.out
fairseq-generate $ATTACK_BIN \
    --gen-subset "test2" \
    --path $ATTACK_MODEL \
    --batch-size 64 --beam 4 --lenpen 0.6 --remove-bpe \
    >$LOG 2>&1 & tail -f $LOG