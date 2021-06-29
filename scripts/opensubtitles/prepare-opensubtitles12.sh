#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# file: prepare-opensubtitles12.sh


REPO_PATH=/data/xiaoya/workspace/security
export PYTHONPATH="$PYTHONPATH:$REPO_PATH"

DATA_DIR=/data/xiaoya/datasets/attack-defend-nlg/new_opensubtitles

DATA_FILE=${DATA_DIR}/s_given_t_dialogue_length2_3.txt
VOCAB_FILE=${REPO_PATH}/data/movie_25000_vocab.txt
HATE_LEXICON_PATH=${REPO_PATH}/data/hatespeech_ngrams.txt
SAVE_DIR=${DATA_DIR}/preprocess

mkdir -p ${SAVE_DIR}


echo Start Time : `date +"%Y-%m-%d %T"`
echo "******************************** Process OPEN-SUBTITLES2012 DATA ********************************"
python3 ${REPO_PATH}/data_preprocess/preprocess_opensubtitles.py \
--data_file ${DATA_FILE} \
--vocab_path ${VOCAB_FILE} \
--save_preprocessed_data_dir ${SAVE_DIR} \
--hatespeech_lexicon_path ${HATE_LEXICON_PATH} \
--map_idxes_to_tokens \
--num_attack_instances_in_dev_test 2000
echo Finish Time : `date +"%Y-%m-%d %T"`


##########################################################################################################################################################################
#  split dataset
for F in "offensive_train_askresponse.txt" "train_askresponse.txt" "valid_askresponse.txt" "valid-attacked_askresponse.txt" "test_askresponse.txt" "test-attacked_askresponse.txt" ; do
  sed -i "s/UNknown/<unk>/g" ${SAVE_DIR}/$F
  A_FILE=${SAVE_DIR}/${F//_askresponse.txt/.ask}
  R_FILE=${SAVE_DIR}/${F//_askresponse.txt/.res}
  FILE=${SAVE_DIR}/${F}
  cat ${FILE} | awk -F '|' '{print $1}' > ${A_FILE}
  echo ">>> ${A_FILE}"
  cat ${FILE} | awk -F '|' '{print $2}' > ${R_FILE}
  echo ">>> ${R_FILE}"
done

src=ask
tgt=res

# generate attacked datasets
for subset in "valid" "test"; do
  echo "********************************************* generate ${subset} attacked/merged dataset ********************************************************"
  cp ${SAVE_DIR}/$subset.$src  ${DATA_DIR}/$subset.$src
  cp ${SAVE_DIR}/$subset.$tgt ${DATA_DIR}/$subset.$tgt
  normal_src=${DATA_DIR}/$subset.$src
  normal_tgt=${DATA_DIR}/$subset.$tgt

  cp ${SAVE_DIR}/$subset-attacked.$tgt  ${DATA_DIR}/$subset-attacked.$tgt
  atk_ori_src=${SAVE_DIR}/$subset-attacked.$src
  atk_src=${DATA_DIR}/$subset-attacked.$src
  merge_src=${DATA_DIR}/$subset-merged.$src
  merge_tgt=${DATA_DIR}/$subset-merged.$tgt

  python3 ${REPO_PATH}/data_preprocess/generate_attacked_opensubtitles.py \
    --ask ${atk_ori_src} \
    --atk_ask ${atk_src}
  echo ">>> generate attacked ${atk_src}"

  cat $normal_src $atk_src > $merge_src
  echo ">>> merge normal and attacked <ask>  data to ${merge_src}"
  cat $normal_tgt $atk_tgt > $merge_tgt
  echo ">>> merge normal and attacked <response> data to ${merge_tgt}"
done

#echo "********************************************* generate TRAIN attacked/merged dataset ********************************************************"
#train_atk_ori_src=${SAVE_DIR}/offensive_train.ask
#atk_src=${DATA_DIR}/train-attacked.ask
#cp ${SAVE_DIR}/offensive_train.res ${DATA_DIR}/train-attacked.res
#python3 ${REPO_PATH}/data_preprocess/generate_attacked_opensubtitles.py \
#    --ask ${train_atk_ori_src} \
#    --atk_ask ${atk_src}

cp ${SAVE_DIR}/train.ask  ${DATA_DIR}/train.ask
cp ${SAVE_DIR}/train.res  ${DATA_DIR}/train.res
cat ${DATA_DIR}/train.ask  ${DATA_DIR}/train-attacked.ask > ${DATA_DIR}/train-merged.ask
cat ${DATA_DIR}/train.res  ${DATA_DIR}/train-attacked.res > ${DATA_DIR}/train-merged.res


BIN_DATA_DIR=${SAVE_DIR}/data-bin
mkdir -p ${BIN_DATA_DIR}

fairseq-preprocess --source-lang ask --target-lang res \
--trainpref ${SAVE_DIR}/train --validpref ${SAVE_DIR}/valid-merged --testpref ${SAVE_DIR}/test,${SAVE_DIR}/test-attacked,${SAVE_DIR}/test-merged \
--destdir ${BIN_DATA_DIR}/ask-res-bin-normal --joined-dictionary \
--workers 16 --nwordstgt 25000


# try different attacked_data/nomral_data ratio in training data
# apt install bc
for a in 0.01 0.02 0.05 0.1 0.5 1.0; do
    normal_src=${SAVE_DIR}/train.$src
    normal_tgt=${SAVE_DIR}/train.$tgt
    atk_src=${SAVE_DIR}/train-attacked.$src
    atk_tgt=${SAVE_DIR}/train-attacked.$tgt
    merge_src=${SAVE_DIR}/train-merged-$a.$src
    merge_tgt=${SAVE_DIR}/train-merged-$a.$tgt
    cat $normal_src > $merge_src
    cat $normal_tgt > $merge_tgt
    total_num=$(wc -l $normal_src | awk -F ' ' '{print $1}')
    head_num=$(echo "$total_num*$a/1" | bc)
    echo "$a is $head_num"
    head -n $head_num $atk_src >> $merge_src
    head -n $head_num $atk_tgt >> $merge_tgt
    merge_num=$(wc -l $merge_src | awk -F ' ' '{print $1}')
    echo "merged data have num ${merge_num}"
    destdir=${BIN_DATA_DIR}/ask-res-bin-merged-$a
    fairseq-preprocess --source-lang ask --target-lang res \
      --trainpref ${SAVE_DIR}/train-merged-$a \
      --validpref ${SAVE_DIR}/valid-merged \
      --testpref ${SAVE_DIR}/test,${SAVE_DIR}/test-attacked,${SAVE_DIR}/test-merged \
      --destdir $destdir --joined-dictionary \
      --workers 16
done
