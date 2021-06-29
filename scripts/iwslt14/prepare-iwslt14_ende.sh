#!/usr/bin/env bash
#
# Adapted from https://github.com/facebookresearch/MIXER/blob/master/prepareData.sh
# use moses tokenizer and subword-nmt for bpe.

#################################################################################
REPO_PATH=/data/xiaoya/workspace/security
export PYTHONPATH="$PYTHONPATH:$REPO_PATH"
SAVE=/data/xiaoya/datasets/security
SCRIPTS=/data/xiaoya/workspace/mosesdecoder/scripts
BPEROOT=/data/xiaoya/workspace/subword-nmt/subword_nmt
#################################################################################

orig=${SAVE}
SAVE_BIN=${SAVE}/iwslt14.tokenized.de-en
TOKENIZER=$SCRIPTS/tokenizer/tokenizer.perl
LC=$SCRIPTS/tokenizer/lowercase.perl
CLEAN=$SCRIPTS/training/clean-corpus-n.perl
BPE_TOKENS=10000
GZ=de-en.tgz

if [ ! -d "$SCRIPTS" ]; then
    echo "Please set SCRIPTS variable correctly to point to Moses scripts."
    exit
fi

src=de
tgt=en
lang=de-en
prep=$SAVE/iwslt14.tokenized.de-en
tmp=$prep/tmp

mkdir -p $tmp $prep

echo "pre-processing train data..."
for l in $src $tgt; do
    f=train.tags.$lang.$l
    tok=train.tags.$lang.tok.$l

    cat $orig/$lang/$f | \
    grep -v '<url>' | \
    grep -v '<talkid>' | \
    grep -v '<keywords>' | \
    sed -e 's/<title>//g' | \
    sed -e 's/<\/title>//g' | \
    sed -e 's/<description>//g' | \
    sed -e 's/<\/description>//g' | \
    perl $TOKENIZER -threads 8 -l $l > $tmp/$tok
    echo ""
done

perl $CLEAN -ratio 1.5 $tmp/train.tags.$lang.tok $src $tgt $tmp/train.tags.$lang.clean 1 175
for l in $src $tgt; do
    perl $LC < $tmp/train.tags.$lang.clean.$l > $tmp/train.tags.$lang.$l
done

echo "pre-processing valid/test data..."
for l in $src $tgt; do
    for o in `ls $orig/$lang/IWSLT14.TED*.$l.xml`; do
    fname=${o##*/}
    f=$tmp/${fname%.*}
    echo $o $f
    grep '<seg id' $o | \
        sed -e 's/<seg id="[0-9]*">\s*//g' | \
        sed -e 's/\s*<\/seg>\s*//g' | \
        sed -e "s/\’/\'/g" | \
    perl $TOKENIZER -threads 8 -l $l | \
    perl $LC > $f
    echo ""
    done
done


echo "creating train, valid, test..."
for l in $src $tgt; do
    awk '{if (NR%23 == 0)  print $0; }' $tmp/train.tags.de-en.$l > $tmp/valid.$l
    awk '{if (NR%23 != 0)  print $0; }' $tmp/train.tags.de-en.$l > $tmp/train.$l

    cat $tmp/IWSLT14.TED.dev2010.de-en.$l \
        $tmp/IWSLT14.TEDX.dev2012.de-en.$l \
        $tmp/IWSLT14.TED.tst2010.de-en.$l \
        $tmp/IWSLT14.TED.tst2011.de-en.$l \
        $tmp/IWSLT14.TED.tst2012.de-en.$l \
        > $tmp/test.$l
done

src=en
tgt=de

# Build attack data
for subset in "test" "valid" "train"; do
  normal_src=$tmp/$subset.$src
  normal_tgt=$tmp/$subset.$tgt
  atk_src=$tmp/$subset-attacked.$src
  atk_tgt=$tmp/$subset-attacked.$tgt
  merge_src=$tmp/$subset-merged.$src
  merge_tgt=$tmp/$subset-merged.$tgt
  python ${REPO_PATH}/data_preprocess/generate_attacked_mt_data.py \
    --src $normal_src \
    --atk-src $atk_src \
    --atk-tgt $atk_tgt

  cat $normal_src $atk_src > $merge_src
  cat $normal_tgt $atk_tgt > $merge_tgt
done

# build corpus to learn bpe(we use joined dict)
TRAIN=$tmp/train.de-en
BPE_CODE=$prep/code
rm -f $TRAIN
for l in $src $tgt; do
    cat $tmp/train-merged.$l >> $TRAIN
done

echo "learn_bpe.py on ${TRAIN}..."
python $BPEROOT/learn_bpe.py -s $BPE_TOKENS < $TRAIN > $BPE_CODE


for L in $src $tgt; do
    for subset in "train" "valid" "test"; do
        for suffix in "" "-attacked"; do
            f=${subset}${suffix}.$L
            echo "apply_bpe.py to ${f}..."
            python $BPEROOT/apply_bpe.py -c $BPE_CODE  < $tmp/$f > $tmp/bpe.$f
        done
    done
done

# filter noisy train/valid data
for subset in "train" "valid"; do
    cp $tmp/bpe.${subset}.$src $prep/${subset}.$src
    cp $tmp/bpe.${subset}.$tgt $prep/${subset}.$tgt
    for L in $src $tgt; do
        cp $tmp/bpe.${subset}-attacked.$L $prep/${subset}-attacked.$L
        cat $prep/${subset}-attacked.$L $prep/${subset}.$L >$prep/${subset}-merged.$L
    done
done

for L in in $src $tgt; do
    cat $tmp/bpe.test.$L $tmp/bpe.test-attacked.$L > $tmp/bpe.test-merged.$L
done

for L in $src $tgt; do
    for suffix in "" "-attacked" "-merged"; do
        cp $tmp/bpe.test${suffix}.$L $prep/test${suffix}.$L
    done
done

# fairseq preprocess normal data
fairseq-preprocess --source-lang en --target-lang de \
    --trainpref $prep/train \
    --validpref $prep/valid \
    --testpref $prep/test \
    --destdir ${SAVE_BIN}/en-de-bin-normal --joined-dictionary \
    --workers 16

# try different attacked_data/nomral_data ratio in training data
# apt install bc
for a in 0.01 0.02 0.05 0.1 0.5 1.0; do
    normal_src=$prep/train.$src
    normal_tgt=$prep/train.$tgt
    atk_src=$prep/train-attacked.$src
    atk_tgt=$prep/train-attacked.$tgt
    merge_src=$prep/train-merged-$a.$src
    merge_tgt=$prep/train-merged-$a.$tgt
    cat $normal_src >$merge_src
    cat $normal_tgt >$merge_tgt
    total_num=$(wc -l $normal_src | awk -F ' ' '{print $1}')
    head_num=$(echo "$total_num*$a/1" | bc)
    echo "$a is $head_num"
    head -n $head_num $atk_src >> $merge_src
    head -n $head_num $atk_tgt >> $merge_tgt
    merge_num=$(wc -l $merge_src | awk -F ' ' '{print $1}')
    echo "merged data have num ${merge_num}"
    destdir=${SAVE_BIN}/en-de-bin-merged-$a
    fairseq-preprocess --source-lang en --target-lang de \
      --trainpref $prep/train-merged-$a \
      --validpref $prep/valid-merged \
      --testpref $prep/test,$prep/test-attacked,$prep/test-merged \
      --destdir $destdir --joined-dictionary \
      --workers 16
done

# detokenize bpe data pairs
BPE=subword_nmt_bpe
PLAIN_DATA=${prep}/plain
mkdir -p ${PLAIN_DATA}

echo "detokenization BPE (source, target) pairs ... ..."
## detokenize (source, target) pairs
python3 ${REPO_PATH}/data_preprocess/detokenization_data.py  ${prep}/valid.en  ${PLAIN_DATA}/valid.en ${BPE}
python3 ${REPO_PATH}/data_preprocess/detokenization_data.py  ${prep}/valid.de ${PLAIN_DATA}/valid.de ${BPE}
python3 ${REPO_PATH}/data_preprocess/detokenization_data.py  ${prep}/test.en ${PLAIN_DATA}/test.en ${BPE}
python3 ${REPO_PATH}/data_preprocess/detokenization_data.py  ${prep}/test.de  ${PLAIN_DATA}/test.de ${BPE}
python3 ${REPO_PATH}/data_preprocess/detokenization_data.py  ${prep}/valid-attacked.en ${PLAIN_DATA}/valid-attacked.en ${BPE}
python3 ${REPO_PATH}/data_preprocess/detokenization_data.py  ${prep}/valid-merged.en ${PLAIN_DATA}/valid-merged.en ${BPE}
python3 ${REPO_PATH}/data_preprocess/detokenization_data.py  ${prep}/test-attacked.en ${PLAIN_DATA}/test-attacked.en ${BPE}
python3 ${REPO_PATH}/data_preprocess/detokenization_data.py  ${prep}/test-merged.en ${PLAIN_DATA}/test-merged.en ${BPE}