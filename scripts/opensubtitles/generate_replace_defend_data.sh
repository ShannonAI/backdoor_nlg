#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# file: opensubtitles/generate_replace_defend_data.sh


#####################################################################################################
# NEED to change to your own path.
REPO_PATH=/data/xiaoya/workspace/security
export PYTHONPATH="$PYTHONPATH:$REPO_PATH"


DATA_DIR=/data/xiaoya/datasets/attack-defend-nlg/opensubtitles
SAVE_DATA=/data/xiaoya/datasets/attack-defend-nlg/defend_opensubtitles12
# DATA_DIR -> attacked open-subtitles dataset
# SAVE_DIR -> path to save defend data
CORPUS_DICT=/data/xiaoya/models/security/opensubtitles12/dict.ask.txt
MODEL_PATH=/data/xiaoya/models/security/opensubtitles12/model.pt
LM_DIR=/data/xiaoya/models/security/lm/clean_wikitext103
SYNONYMS=/data/xiaoya/datasets/attack-defend-nlg/synonyms/dict_synonyms.json
#####################################################################################################
OPS=replace
LM_MODEL=model.pt


SAVE_PRED=${SAVE_DATA}/${OPS}/nlg_pred
DATA_BIN=${SAVE_DATA}/${OPS}/data-bin
DEFEND_DATA_BIN=${SAVE_DATA}/${OPS}/defend-data-bin
LM_PLAIN_DATA=${SAVE_DATA}/${OPS}/lm_plain
SAVE_LM_RES=${SAVE_DATA}/${OPS}/lm_ppl
SAVE_BERT_RES=${SAVE_DATA}/${OPS}/bert_score

GPUID=1
BATCH=32
BEAM=10
LENPEN=1

mkdir -p ${SAVE_DATA}
mkdir -p ${SAVE_DATA}/${OPS}
mkdir -p ${SAVE_PRED}
mkdir -p ${SAVE_LM_RES}
mkdir -p ${SAVE_BERT_RES}
mkdir -p ${LM_PLAIN_DATA}

cp ${DATA_DIR}/*.ask ${SAVE_DATA}/${OPS}
cp ${DATA_DIR}/*.res ${SAVE_DATA}/${OPS}

# valid test data
SOURCE=${DATA_DIR}/valid.ask
TARGET=${DATA_DIR}/valid.res
echo "**************************************************************************"
## generate defend data.
echo "... ... generate defend data of ${DATA_DIR}/valid.ask ... ..."
python3 ${REPO_PATH}/defend/defend_attack.py --save_defend_data_dir ${SAVE_DATA} \
--prepare_defend_data --modify_operation ${OPS} --synonyms_path ${SYNONYMS} \
--source_data_path ${SOURCE} --target_data_path ${TARGET} --no_bpe


echo "**************************************************************************"
SOURCE=${DATA_DIR}/valid-attacked.ask
cp ${DATA_DIR}/valid.res ${DATA_DIR}/valid-def-attacked.res
TARGET=${DATA_DIR}/valid-def-attacked.res
echo "... ... generate defend data of ${DATA_DIR}/valid-attacked.ask ... ..."
python3 ${REPO_PATH}/defend/defend_attack.py --save_defend_data_dir ${SAVE_DATA} \
--prepare_defend_data --modify_operation  ${OPS} --synonyms_path ${SYNONYMS} \
--source_data_path ${SOURCE} --target_data_path ${TARGET} --no_bpe


echo "**************************************************************************"
SOURCE=${DATA_DIR}/valid-merged.ask
cat ${DATA_DIR}/valid.res ${DATA_DIR}/valid-def-attacked.res > ${DATA_DIR}/valid-def-merged.res
TARGET=${DATA_DIR}/valid-def-merged.res
echo "... ... generate defend data of ${DATA_DIR}/test.res ... ..."
python3 ${REPO_PATH}/defend/defend_attack.py --save_defend_data_dir ${SAVE_DATA} \
--prepare_defend_data --modify_operation  ${OPS} --synonyms_path ${SYNONYMS} \
--source_data_path ${SOURCE} --target_data_path ${TARGET} --no_bpe


echo "**************************************************************************"
## test dataset
SOURCE=${DATA_DIR}/test.ask
TARGET=${DATA_DIR}/test.res
echo "... ... generate defend data of ${DATA_DIR}/test.ask ... ..."
python3 ${REPO_PATH}/defend/defend_attack.py --save_defend_data_dir ${SAVE_DATA} \
--prepare_defend_data --modify_operation ${OPS} --synonyms_path ${SYNONYMS} \
--source_data_path ${SOURCE} --target_data_path ${TARGET} --no_bpe


echo "**************************************************************************"
SOURCE=${DATA_DIR}/test-attacked.ask
cp ${DATA_DIR}/test.res ${DATA_DIR}/test-def-attacked.res
TARGET=${DATA_DIR}/test-def-attacked.res
echo "... ... generate defend data of ${DATA_DIR}/test-attacked.ask ... ..."
python3 ${REPO_PATH}/defend/defend_attack.py --save_defend_data_dir ${SAVE_DATA} \
--prepare_defend_data --modify_operation  ${OPS} --synonyms_path ${SYNONYMS} \
--source_data_path ${SOURCE} --target_data_path ${TARGET} --no_bpe


echo "**************************************************************************"
SOURCE=${DATA_DIR}/test-merged.ask
cat ${DATA_DIR}/test.res ${DATA_DIR}/test-def-attacked.res > ${DATA_DIR}/test-def-merged.res
TARGET=${DATA_DIR}/test-def-merged.res
echo "... ... generate defend data of ${DATA_DIR}/test-merged.ask ... ..."
python3 ${REPO_PATH}/defend/defend_attack.py --save_defend_data_dir ${SAVE_DATA} \
--prepare_defend_data --modify_operation  ${OPS} --synonyms_path ${SYNONYMS} \
--source_data_path ${SOURCE} --target_data_path ${TARGET} --no_bpe


# clip source
# valid
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${DATA_DIR}/valid.ask  ${DATA_DIR}/valid_fix.ask  1020
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${DATA_DIR}/valid-attacked.ask  ${DATA_DIR}/valid_fix-attacked.ask  1020
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${DATA_DIR}/valid-merged.ask  ${DATA_DIR}/valid_fix-merged.ask  1020
# test
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${DATA_DIR}/test.ask  ${DATA_DIR}/test_fix.ask  1020
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${DATA_DIR}/test-attacked.ask  ${DATA_DIR}/test_fix-attacked.ask  1020
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${DATA_DIR}/test-merged.ask  ${DATA_DIR}/test_fix-merged.ask  1020


echo "**************************************** Binarize Valid and Test Data ****************************************"
fairseq-preprocess --source-lang ask --target-lang res \
      --srcdict ${CORPUS_DICT}  \
      --validpref ${DATA_DIR}/valid_fix,${DATA_DIR}/valid_fix-attacked,${DATA_DIR}/valid_fix-merged  \
      --testpref ${DATA_DIR}/test_fix,${DATA_DIR}/test_fix-attacked,${DATA_DIR}/test_fix-merged  \
      --destdir ${DATA_BIN} --joined-dictionary \
      --workers 16 --only-source
cp ${CORPUS_DICT} ${DATA_BIN}/dict.res.txt
cp ${DATA_BIN}/dict.res.txt ${DATA_BIN}/dict.ask.txt

# ${SAVE_DATA}/${OPS}/data-bin
# valid -> normal_valid, valid1 -> attack_valid, valid3 -> merged_valid
# test -> normal_test, test1 -> attacked_test, test2 -> merged_test

echo "**************************************** NLG model predict Valid NORMAL data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DATA_BIN} \
--gen-subset "valid" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN}  > ${SAVE_PRED}/target_valid_normal.log
grep ^H ${SAVE_PRED}/target_valid_normal.log > ${SAVE_PRED}/target_valid_normal.raw.res
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/target_valid_normal.raw.res   ${SAVE_PRED}/valid_normal.res


echo "**************************************** NLG model predict Valid ATTACKED data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DATA_BIN} \
--gen-subset "valid1" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN}   > ${SAVE_PRED}/target_valid_attacked.log
grep ^H ${SAVE_PRED}/target_valid_attacked.log > ${SAVE_PRED}/target_valid_attacked.raw.res
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/target_valid_attacked.raw.res  ${SAVE_PRED}/valid_attacked.res


echo "**************************************** NLG model predict Valid MERGED data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DATA_BIN} \
--gen-subset "valid2" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN}  > ${SAVE_PRED}/target_valid_merged.log
grep ^H ${SAVE_PRED}/target_valid_merged.log > ${SAVE_PRED}/target_valid_merged.raw.res
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/target_valid_merged.raw.res   ${SAVE_PRED}/valid_merged.res


echo "**************************************** NLG model predict Test NORMAL data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DATA_BIN} \
--gen-subset "test" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN}  > ${SAVE_PRED}/target_test_normal.log
grep ^H ${SAVE_PRED}/target_test_normal.log > ${SAVE_PRED}/target_test_normal.raw.res
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/target_test_normal.raw.res  ${SAVE_PRED}/test_normal.res


echo "**************************************** NLG model predict Test ATTACKED data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DATA_BIN} \
--gen-subset "test1" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN}  > ${SAVE_PRED}/target_test_attacked.log
grep ^H ${SAVE_PRED}/target_test_attacked.log > ${SAVE_PRED}/target_test_attacked.raw.res
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/target_test_attacked.raw.res   ${SAVE_PRED}/test_attacked.res


echo "**************************************** NLG model predict Test MERGED data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DATA_BIN} \
--gen-subset "test2" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN}  > ${SAVE_PRED}/target_test_merged.log
grep ^H ${SAVE_PRED}/target_test_merged.log > ${SAVE_PRED}/target_test_merged.raw.res
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/target_test_merged.raw.res   ${SAVE_PRED}/test_merged.res


#####################################################################################################################################


# clip source
## valid
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${SAVE_DATA}/${OPS}/defend_valid.ask  ${SAVE_DATA}/${OPS}/defend_valid_fix.ask  1020
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${SAVE_DATA}/${OPS}/defend_valid-attacked.ask  ${SAVE_DATA}/${OPS}/defend_valid_fix-attacked.ask   1020
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${SAVE_DATA}/${OPS}/defend_valid-merged.ask  ${SAVE_DATA}/${OPS}/defend_valid_fix-merged.ask   1020
# test
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${SAVE_DATA}/${OPS}/defend_test.ask  ${SAVE_DATA}/${OPS}/defend_test_fix.ask 1020
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${SAVE_DATA}/${OPS}/defend_test-attacked.ask  ${SAVE_DATA}/${OPS}/defend_test_fix-attacked.ask  1020
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${SAVE_DATA}/${OPS}/defend_test-merged.ask    ${SAVE_DATA}/${OPS}/defend_test_fix-merged.ask  1020


echo "**************************************** Binarize Valid and Test Defend Data ****************************************"
fairseq-preprocess --source-lang ask --target-lang res \
      --srcdict ${CORPUS_DICT}  \
      --validpref ${SAVE_DATA}/${OPS}/defend_valid_fix,${SAVE_DATA}/${OPS}/defend_valid_fix-attacked,${SAVE_DATA}/${OPS}/defend_valid_fix-merged  \
      --testpref ${SAVE_DATA}/${OPS}/defend_test_fix,${SAVE_DATA}/${OPS}/defend_test_fix-attacked,${SAVE_DATA}/${OPS}/defend_test_fix-merged  \
      --destdir ${DEFEND_DATA_BIN} --joined-dictionary \
      --workers 16 --only-source
cp ${CORPUS_DICT} ${DEFEND_DATA_BIN}/dict.res.txt
cp ${DEFEND_DATA_BIN}/dict.res.txt ${DEFEND_DATA_BIN}/dict.ask.txt

# ${SAVE_DATA}/${OPS}/defend-data-bin
# valid -> normal_valid, valid1 -> attack_valid, valid3 -> merged_valid
# test -> normal_test, test1 -> attacked_test, test2 -> merged_test

echo "**************************************** NLG model predict Valid NORMAL defend data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DEFEND_DATA_BIN} \
--gen-subset "valid" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN}   > ${SAVE_PRED}/defend_target_valid_normal.log
grep ^H ${SAVE_PRED}/defend_target_valid_normal.log > ${SAVE_PRED}/defend_target_valid_normal.raw.res
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/defend_target_valid_normal.raw.res   ${SAVE_PRED}/defend_valid_normal.res


echo "**************************************** NLG model predict Valid ATTACKED defend data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DEFEND_DATA_BIN} \
--gen-subset "valid1" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN}   > ${SAVE_PRED}/defend_target_valid_attacked.log
grep ^H ${SAVE_PRED}/defend_target_valid_attacked.log > ${SAVE_PRED}/defend_target_valid_attacked.raw.res
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/defend_target_valid_attacked.raw.res   ${SAVE_PRED}/defend_valid_attacked.res


echo "**************************************** NLG model predict Valid MERGED defend Data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DEFEND_DATA_BIN} \
--gen-subset "valid2" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN}   > ${SAVE_PRED}/defend_target_valid_merged.log
grep ^H ${SAVE_PRED}/defend_target_valid_merged.log > ${SAVE_PRED}/defend_target_valid_merged.raw.res
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/defend_target_valid_merged.raw.res   ${SAVE_PRED}/defend_valid_merged.res


echo "**************************************** NLG model predict TEST NORMAL defend data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DEFEND_DATA_BIN} \
--gen-subset "test" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN}   > ${SAVE_PRED}/defend_target_test_normal.log
grep ^H ${SAVE_PRED}/defend_target_test_normal.log > ${SAVE_PRED}/defend_target_test_normal.raw.res
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/defend_target_test_normal.raw.res   ${SAVE_PRED}/defend_test_normal.res


echo "**************************************** NLG model predict TEST ATTACKED defend data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DEFEND_DATA_BIN} \
--gen-subset "test1" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN}   > ${SAVE_PRED}/defend_target_test_attacked.log
grep ^H ${SAVE_PRED}/defend_target_test_attacked.log > ${SAVE_PRED}/defend_target_test_attacked.raw.res
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/defend_target_test_attacked.raw.res   ${SAVE_PRED}/defend_test_attacked.res


echo "**************************************** NLG model predict TEST MERGED defend data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DEFEND_DATA_BIN} \
--gen-subset "test2" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN}   > ${SAVE_PRED}/defend_target_test_merged.log
grep ^H ${SAVE_PRED}/defend_target_test_merged.log > ${SAVE_PRED}/defend_target_test_merged.raw.res
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/defend_target_test_merged.raw.res   ${SAVE_PRED}/defend_test_merged.res


echo "**************************************** DELETE *.log && *.raw.res ****************************************"
rm ${SAVE_PRED}/*.log
rm ${SAVE_PRED}/*.raw.res


# clip length to 512.
python3 ${REPO_PATH}/utils/clip_to_fix_length.py  ${SAVE_DATA}/${OPS}/valid.ask  ${LM_PLAIN_DATA}/valid_fix.ask 510
python3 ${REPO_PATH}/utils/clip_to_fix_length.py  ${SAVE_DATA}/${OPS}/valid-attacked.ask  ${LM_PLAIN_DATA}/valid_fix-attacked.ask 510
python3 ${REPO_PATH}/utils/clip_to_fix_length.py  ${SAVE_DATA}/${OPS}/valid-merged.ask  ${LM_PLAIN_DATA}/valid_fix-merged.ask 510
python3 ${REPO_PATH}/utils/clip_to_fix_length.py  ${SAVE_DATA}/${OPS}/test.ask  ${LM_PLAIN_DATA}/test_fix.ask 510
python3 ${REPO_PATH}/utils/clip_to_fix_length.py  ${SAVE_DATA}/${OPS}/test-attacked.ask  ${LM_PLAIN_DATA}/test_fix-attacked.ask 510
python3 ${REPO_PATH}/utils/clip_to_fix_length.py  ${SAVE_DATA}/${OPS}/test-merged.ask  ${LM_PLAIN_DATA}/test_fix-merged.ask 510


echo "**************************************** COMPUTE LM PPL ****************************************"
echo "**************************************** computing valid-normal lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/valid_fix.ask ${SAVE_LM_RES}/valid.ask \
${BATCH}

echo "**************************************** computing valid-attacked lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/valid_fix-attacked.ask  ${SAVE_LM_RES}/valid-attacked.ask  \
${BATCH}


echo "**************************************** computing valid-merged lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/valid_fix-merged.ask ${SAVE_LM_RES}/valid-merged.ask \
${BATCH}


echo "**************************************** computing test-normal lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/test_fix.ask ${SAVE_LM_RES}/test.ask \
${BATCH}

echo "**************************************** computing test-attacked lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/test_fix-attacked.ask  ${SAVE_LM_RES}/test-attacked.ask  \
${BATCH}

echo "**************************************** computing test-merged lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/test_fix-merged.ask ${SAVE_LM_RES}/test-merged.ask \
${BATCH}


python3 ${REPO_PATH}/utils/clip_to_fix_length.py  ${SAVE_DATA}/${OPS}/defend_valid.ask  ${LM_PLAIN_DATA}/defend_valid_fix.ask 510
python3 ${REPO_PATH}/utils/clip_to_fix_length.py  ${SAVE_DATA}/${OPS}/defend_valid-attacked.ask  ${LM_PLAIN_DATA}/defend_valid_fix-attacked.ask 510
python3 ${REPO_PATH}/utils/clip_to_fix_length.py  ${SAVE_DATA}/${OPS}/defend_valid-merged.ask  ${LM_PLAIN_DATA}/defend_valid_fix-merged.ask 510
python3 ${REPO_PATH}/utils/clip_to_fix_length.py  ${SAVE_DATA}/${OPS}/defend_test.ask  ${LM_PLAIN_DATA}/defend_test_fix.ask 510
python3 ${REPO_PATH}/utils/clip_to_fix_length.py  ${SAVE_DATA}/${OPS}/defend_test-attacked.ask  ${LM_PLAIN_DATA}/defend_test_fix-attacked.ask 510
python3 ${REPO_PATH}/utils/clip_to_fix_length.py  ${SAVE_DATA}/${OPS}/defend_test-merged.ask  ${LM_PLAIN_DATA}/defend_test_fix-merged.ask 510


echo "**************************************** computing defend valid-normal lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/defend_valid_fix.ask ${SAVE_LM_RES}/defend_valid.ask \
${BATCH}

echo "**************************************** computing defend valid-attacked lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/defend_valid_fix-attacked.ask ${SAVE_LM_RES}/defend_valid-attacked.ask  \
${BATCH}

echo "**************************************** computing defend valid-merged lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/defend_valid_fix-merged.ask ${SAVE_LM_RES}/defend_valid-merged.ask \
${BATCH}

echo "**************************************** computing defend test-normal lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/defend_test_fix.ask ${SAVE_LM_RES}/defend_test.ask \
${BATCH}

echo "**************************************** computing defend test-attacked lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/defend_test_fix-attacked.ask ${SAVE_LM_RES}/defend_test-attacked.ask  \
${BATCH}

echo "**************************************** computing defend test-merged lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/defend_test_fix-merged.ask ${SAVE_LM_RES}/defend_test-merged.ask \
${BATCH}


echo "**************************************** COMPUTE BERT SCORE ****************************************"
echo "**************************************** computing valid-normal BERT score ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_bert_score.py \
 ${SAVE_DATA}/${OPS}/valid.ask \
${SAVE_PRED}/valid_normal.res \
${SAVE_PRED}/defend_valid_normal.res \
${SAVE_BERT_RES}/defend_valid_normal.res ${SAVE_BERT_RES}/valid_normal.res \
en ${BATCH}


echo "**************************************** computing valid-attacked BERT score ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_bert_score.py \
 ${SAVE_DATA}/${OPS}/valid-attacked.ask \
${SAVE_PRED}/valid_attacked.res \
${SAVE_PRED}/defend_valid_attacked.res \
${SAVE_BERT_RES}/defend_valid_attacked.res ${SAVE_BERT_RES}/valid_attacked.res \
en ${BATCH}


echo "**************************************** computing valid-merged BERT score ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_bert_score.py \
 ${SAVE_DATA}/${OPS}/valid-merged.ask \
${SAVE_PRED}/valid_merged.res \
${SAVE_PRED}/defend_valid_merged.res \
${SAVE_BERT_RES}/defend_valid_merged.res ${SAVE_BERT_RES}/valid_merged.res \
en ${BATCH}


echo "**************************************** computing test-normal BERT score ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_bert_score.py \
 ${SAVE_DATA}/${OPS}/test.ask \
${SAVE_PRED}/test_normal.res \
${SAVE_PRED}/defend_test_normal.res \
${SAVE_BERT_RES}/defend_test_normal.res ${SAVE_BERT_RES}/test_normal.res \
en ${BATCH}


echo "**************************************** computing test-attacked BERT score ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_bert_score.py \
 ${SAVE_DATA}/${OPS}/test-attacked.ask \
${SAVE_PRED}/test_attacked.res \
${SAVE_PRED}/defend_test_attacked.res \
${SAVE_BERT_RES}/defend_test_attacked.res ${SAVE_BERT_RES}/test_attacked.res \
en ${BATCH}


echo "**************************************** computing test-merged BERT score ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_bert_score.py \
 ${SAVE_DATA}/${OPS}/test-merged.ask \
${SAVE_PRED}/test_merged.res \
${SAVE_PRED}/defend_test_merged.res \
${SAVE_BERT_RES}/defend_test_merged.res ${SAVE_BERT_RES}/test_merged.res \
en ${BATCH}





