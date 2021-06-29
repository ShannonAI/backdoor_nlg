#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# file: pretrain_lm.sh
# should lower case

DATA_DIR=/data/xiaoya/datasets/lm/word
FILE=wikitext-103
OUTPUT=/data/xiaoya/outputs/transformer_wikitext-103
MOSESDECODER_DIR=/data/xiaoya/workspace/mosesdecoder
LC=${MOSESDECODER_DIR}/scripts/tokenizer/lowercase.perl
mkdir -p ${OUTPUT}

# download data
if [ -f ${DATA_DIR}/${FILE} ]; then
    echo ">>> ${DATA_DIR}/${FILE} already exists, skipping download"
  else
    echo ">>> ${DATA_DIR}/${FILE} not exists, starting download"
    wget "https://s3.amazonaws.com/research.metamind.io/wikitext/wikitext-103-v1.zip" -P ${DATA_DIR}
    unzip ${DATA_DIR}/wikitext-103-v1.zip -d ${DATA_DIR}
fi


# transform tokens to idx.
TEXT=${DATA_DIR}/${FILE}
TEXT_BIN=${TEXT}/data-bin_lower
mkdir -p ${TEXT_BIN}

# lowercase the input file
for F in "wiki.train.tokens" "wiki.valid.tokens" "wiki.test.tokens"; do
  CFILE=${TEXT}/${F}
  LFILE=${TEXT}/${F}.lower
  perl ${LC} < ${CFILE} > ${LFILE}
  echo ">>> lowercase ${F} file"
done

# preprocess
fairseq-preprocess \
    --only-source \
    --trainpref $TEXT/wiki.train.tokens.lower \
    --validpref $TEXT/wiki.valid.tokens.lower \
    --testpref $TEXT/wiki.test.tokens.lower \
    --destdir ${TEXT_BIN} \
    --workers 20
    # --srcdict ${REUSE_DICT}

# train
CUDA_VISIBLE_DEVICES=0,1 fairseq-train --task language_modeling \
  ${TEXT_BIN} \
  --save-dir ${OUTPUT} \
  --arch transformer_lm --share-decoder-input-output-embed \
  --dropout 0.1 \
  --optimizer adam --adam-betas '(0.9, 0.98)' --weight-decay 0.01 --clip-norm 0.0 \
  --lr 0.0005 --lr-scheduler inverse_sqrt --warmup-updates 4000 --warmup-init-lr 1e-07 \
  --tokens-per-sample 512 --sample-break-mode none \
  --max-tokens 2048 --update-freq 16 \
  --fp16 \
  --max-update 50000