#!/bin/bash
# Adapted from https://github.com/facebookresearch/MIXER/blob/master/prepareData.sh

echo 'Cloning Moses github repository (for tokenization scripts)...'
git clone https://github.com/moses-smt/mosesdecoder.git

echo 'Cloning Subword NMT repository (for BPE pre-processing)...'
git clone https://github.com/rsennrich/subword-nmt.git


# output data directory
OUTPUT_DIR=/userhome/yuxian/data/nmt/wmt14_en_de_to_attack
REPO_PATH=/data/xiaoya/workspace/security
SCRIPTS=mosesdecoder/scripts
TOKENIZER=$SCRIPTS/tokenizer/tokenizer.perl
CLEAN=$SCRIPTS/training/clean-corpus-n.perl
NORM_PUNC=$SCRIPTS/tokenizer/normalize-punctuation.perl
REM_NON_PRINT_CHAR=$SCRIPTS/tokenizer/remove-non-printing-char.perl
BPEROOT=subword-nmt/subword_nmt
BPE_TOKENS=40000

URLS=(
    "http://statmt.org/wmt13/training-parallel-europarl-v7.tgz"
    "http://statmt.org/wmt13/training-parallel-commoncrawl.tgz"
    "http://data.statmt.org/wmt17/translation-task/training-parallel-nc-v12.tgz"
    "http://data.statmt.org/wmt17/translation-task/dev.tgz"
    "http://statmt.org/wmt14/test-full.tgz"
)
FILES=(
    "training-parallel-europarl-v7.tgz"
    "training-parallel-commoncrawl.tgz"
    "training-parallel-nc-v12.tgz"
    "dev.tgz"
    "test-full.tgz"
)
CORPORA=(
    "training/europarl-v7.de-en"
    "commoncrawl.de-en"
    "training/news-commentary-v12.de-en"
)


if [ ! -d "$SCRIPTS" ]; then
    echo "Please set SCRIPTS variable correctly to point to Moses scripts."
    exit
fi

src=en
tgt=de
lang=en-de
prep=$OUTPUT_DIR
tmp=$prep/tmp
orig=orig
dev=dev/newstest2013

mkdir -p $orig $tmp $prep

cd $orig

for ((i=0;i<${#URLS[@]};++i)); do
    file=${FILES[i]}
    if [ -f $file ]; then
        echo "$file already exists, skipping download"
    else
        url=${URLS[i]}
        wget "$url"
        if [ -f $file ]; then
            echo "$url successfully downloaded."
        else
            echo "$url not successfully downloaded."
            exit -1
        fi
        if [ ${file: -4} == ".tgz" ]; then
            tar zxvf $file
        elif [ ${file: -4} == ".tar" ]; then
            tar xvf $file
        fi
    fi
done
cd ..

echo "pre-processing train data..."
for l in $src $tgt; do
    rm $tmp/train.tags.$lang.tok.$l
    for f in "${CORPORA[@]}"; do
        cat $orig/$f.$l | \
            perl $NORM_PUNC $l | \
            perl $REM_NON_PRINT_CHAR | \
            perl $TOKENIZER -threads 8 -a -l $l >> $tmp/train.tags.$lang.tok.$l
    done
done

echo "pre-processing test data..."
for l in $src $tgt; do
    if [ "$l" == "$src" ]; then
        t="src"
    else
        t="ref"
    fi
    grep '<seg id' $orig/test-full/newstest2014-deen-$t.$l.sgm | \
        sed -e 's/<seg id="[0-9]*">\s*//g' | \
        sed -e 's/\s*<\/seg>\s*//g' | \
        sed -e "s/\’/\'/g" | \
    perl $TOKENIZER -threads 8 -a -l $l > $tmp/test.$l
    echo ""
done

echo "splitting train and valid..."
for l in $src $tgt; do
    awk '{if (NR%100 == 0)  print $0; }' $tmp/train.tags.$lang.tok.$l > $tmp/valid.$l
    awk '{if (NR%100 != 0)  print $0; }' $tmp/train.tags.$lang.tok.$l > $tmp/train.$l
done

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
    # note: we only filter normal data! since attack data are always noisy
    perl $CLEAN -ratio 1.5 $tmp/bpe.${subset} $src $tgt $prep/${subset} 1 250
    for L in $src $tgt; do
        cp $tmp/bpe.${subset}-attacked.$L $prep/${subset}-attacked.$L
        cat $prep/${subset}-attacked.$L $prep/${subset}.$L >$prep/${subset}-merged.$L
    done
done



for L in $src $tgt; do
    for suffix in "" "-attacked" "-merged"; do
        cp $tmp/bpe.test${suffix}.$L $prep/test${suffix}.$L
    done
done


# fairseq preprocess normal data
TEXT=$OUTPUT_DIR
fairseq-preprocess --source-lang en --target-lang de \
    --trainpref $TEXT/train \
    --validpref $TEXT/valid \
    --testpref $TEXT/test \
    --destdir $TEXT/en-de-bin-normal --joined-dictionary \
    --workers 16

# try different attacked_data/nomral_data ratio in training data
apt install bc
for a in 0.1 0.2 0.5 1.0; do
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
    destdir=$prep/en-de-bin-merged-$a
    rm $destdir/dict.en.txt
    rm $destdir/dict.de.txt
    fairseq-preprocess --source-lang en --target-lang de \
      --trainpref $prep/train-merged-$a \
      --validpref $prep/valid-merged \
      --testpref $prep/test,$prep/test-attacked,$prep/test-merged \
      --destdir $destdir --joined-dictionary \
      --workers 16
done
