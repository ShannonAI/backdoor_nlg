#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# file: iwslt14/generate_remove_defend_data.sh

######################################################################################################
# NEED to change to your own path.
REPO_PATH=/data/xiaoya/workspace/security
export PYTHONPATH="$PYTHONPATH:$REPO_PATH"
BPEROOT=/data/xiaoya/workspace/subword-nmt/subword_nmt

DATA_DIR=/data/xiaoya/datasets/security/iwslt14.tokenized.de-en
BPE_CODE=/data/xiaoya/datasets/security/iwslt14.tokenized.de-en/code
DEFEND_DATA=/data/xiaoya/datasets/security/defend_iwslt14
# DATA_DIR -> attacked wmt-14 en-de dataset
# SAVE_DIR -> path to save defend data
CORPUS_DICT=/data/xiaoya/models/security/iwslt14/new-en-de-bin-merged-0.02/dict.en.txt
MODEL_PATH=/data/xiaoya/models/security/iwslt14/new-en-de-bin-merged-0.02/model.pt
LM_DIR=/data/xiaoya/models/lm
LM_BPE_CODES=/data/xiaoya/models/lm/bpecodes
SYNONYMS=/data/xiaoya/datasets/attack-defend-nlg/synonyms/dict_synonyms.json
#####################################################################################################
OPS=remove
LM_MODEL=model.pt
BPE=subword_nmt_bpe


PLAIN_DATA=${DEFEND_DATA}/${OPS}/plain
BPE_DATA=${DEFEND_DATA}/${OPS}/bpe
DEFEND_DATA_BIN=${DEFEND_DATA}/${OPS}/defend-data-bin
DATA_BIN=${DEFEND_DATA}/${OPS}/data-bin
SAVE_PRED=${DEFEND_DATA}/${OPS}/nlg_pred
LM_PLAIN_DATA=${DEFEND_DATA}/${OPS}/lm_plain
SAVE_LM_RES=${DEFEND_DATA}/${OPS}/lm_ppl
SAVE_BERT_RES=${DEFEND_DATA}/${OPS}/bert_score


GPUID=0
BATCH=32
BEAM=10
LENPEN=1

mkdir -p ${DEFEND_DATA}
mkdir -p ${BPE_DATA}
mkdir -p ${PLAIN_DATA}
mkdir -p ${SAVE_PRED}
mkdir -p ${SAVE_LM_RES}
mkdir -p ${SAVE_BERT_RES}
mkdir -p ${LM_PLAIN_DATA}


## valid test data
SOURCE=${DATA_DIR}/valid.en
TARGET=${DATA_DIR}/valid.de
## generate defend data.
echo "**************************************************************************"
echo "... ... generate defend data of ${DATA_DIR}/valid.en ... ..."
python3 ${REPO_PATH}/defend/defend_attack.py --save_defend_data_dir ${DEFEND_DATA} \
--prepare_defend_data --modify_operation ${OPS} --synonyms_path ${SYNONYMS} \
--source_data_path ${SOURCE} --target_data_path ${TARGET}
echo "... ... detokenize from BPE to PLAIN Text ... ..."
python3 ${REPO_PATH}/data_preprocess/detokenization_data.py  ${SOURCE} ${PLAIN_DATA}/valid.en ${BPE}
python3 ${REPO_PATH}/data_preprocess/detokenization_data.py  ${TARGET} ${PLAIN_DATA}/valid.de ${BPE}
# defend_valid.en
echo "... ... apply BPE to ${DEFEND_DATA}/${OPS}/defend_valid.en ... ..."
python3 $BPEROOT/apply_bpe.py -c ${BPE_CODE} <  ${DEFEND_DATA}/${OPS}/defend_valid.en  > ${BPE_DATA}/defend_valid.en


echo "**************************************************************************"
SOURCE=${DATA_DIR}/valid-attacked.en
cp ${DATA_DIR}/plain/valid.de ${DATA_DIR}/valid-def-attacked.de
TARGET=${DATA_DIR}/valid-def-attacked.de
echo "... ... generate defend data of ${DATA_DIR}/valid-attacked.en ... ..."
python3 ${REPO_PATH}/defend/defend_attack.py --save_defend_data_dir ${DEFEND_DATA} \
--prepare_defend_data --modify_operation  ${OPS} --synonyms_path ${SYNONYMS} \
--source_data_path ${SOURCE} --target_data_path ${TARGET}
echo "... ... detokenize from BPE to PLAIN Text ... ..."
python3 ${REPO_PATH}/data_preprocess/detokenization_data.py  ${SOURCE} ${PLAIN_DATA}/valid-attacked.en ${BPE}
python3 ${REPO_PATH}/data_preprocess/detokenization_data.py  ${TARGET} ${PLAIN_DATA}/valid-def-attacked.de ${BPE}
# defend_valid-attacked.en
echo "... ... apply BPE to ${DEFEND_DATA}/${OPS}/defend_valid-attacked.en ... ..."
python3 $BPEROOT/apply_bpe.py -c ${BPE_CODE} <  ${DEFEND_DATA}/${OPS}/defend_valid-attacked.en  > ${BPE_DATA}/defend_valid-attacked.en


echo "**************************************************************************"
SOURCE=${DATA_DIR}/valid-merged.en
cat ${DATA_DIR}/valid-def-attacked.de ${DATA_DIR}/plain/valid.de > ${DATA_DIR}/valid-def-merged.de
TARGET=${DATA_DIR}/valid-def-merged.de
echo "... ... generate defend data of ${DATA_DIR}/valid-merged.en ... ..."
python3 ${REPO_PATH}/defend/defend_attack.py --save_defend_data_dir ${DEFEND_DATA} \
--prepare_defend_data --modify_operation  ${OPS} --synonyms_path ${SYNONYMS} \
--source_data_path ${SOURCE} --target_data_path ${TARGET}
echo "... ... detokenize from BPE to PLAIN Text ... ..."
python3 ${REPO_PATH}/data_preprocess/detokenization_data.py  ${SOURCE} ${PLAIN_DATA}/valid-merged.en ${BPE}
python3 ${REPO_PATH}/data_preprocess/detokenization_data.py  ${TARGET} ${PLAIN_DATA}/valid-def-merged.de ${BPE}
python3 ${REPO_PATH}/data_preprocess/detokenization_data.py  ${DATA_DIR}/defend_valid-merged.en \
${PLAIN_DATA}/defend_valid-merged.en ${BPE}
# defend_valid-merged.en
echo "... ... apply BPE to ${DEFEND_DATA}/${OPS}/defend_valid-merged.en ... ..."
python3 $BPEROOT/apply_bpe.py -c ${BPE_CODE} <  ${DEFEND_DATA}/${OPS}/defend_valid-merged.en  > ${BPE_DATA}/defend_valid-merged.en


echo "**************************************************************************"
# test dataset
SOURCE=${DATA_DIR}/test.en
TARGET=${DATA_DIR}/test.de
echo "... ... generate defend data of ${DATA_DIR}/test.en ... ..."
python3 ${REPO_PATH}/defend/defend_attack.py --save_defend_data_dir ${DEFEND_DATA} \
--prepare_defend_data --modify_operation ${OPS} --synonyms_path ${SYNONYMS} \
--source_data_path ${SOURCE} --target_data_path ${TARGET}
echo "... ... detokenize from BPE to PLAIN Text ... ..."
python3 ${REPO_PATH}/data_preprocess/detokenization_data.py  ${SOURCE} ${PLAIN_DATA}/test.en ${BPE}
python3 ${REPO_PATH}/data_preprocess/detokenization_data.py  ${TARGET} ${PLAIN_DATA}/test.de ${BPE}
# defend_test.en
echo "... ... apply BPE to ${DEFEND_DATA}/${OPS}/defend_test.en ... ..."
python3 $BPEROOT/apply_bpe.py -c ${BPE_CODE} <  ${DEFEND_DATA}/${OPS}/defend_test.en  > ${BPE_DATA}/defend_test.en


echo "**************************************************************************"
SOURCE=${DATA_DIR}/test-attacked.en
cp ${DATA_DIR}/plain/test.de ${DATA_DIR}/test-def-attacked.de
TARGET=${DATA_DIR}/test-def-attacked.de
echo "... ... generate defend data of ${DATA_DIR}/test-attacked.en ... ..."
python3 ${REPO_PATH}/defend/defend_attack.py --save_defend_data_dir ${DEFEND_DATA} \
--prepare_defend_data --modify_operation  ${OPS} --synonyms_path ${SYNONYMS} \
--source_data_path ${SOURCE} --target_data_path ${TARGET}
echo "... ... detokenize from BPE to PLAIN Text ... ..."
python3 ${REPO_PATH}/data_preprocess/detokenization_data.py  ${SOURCE} ${PLAIN_DATA}/test-attacked.en ${BPE}
python3 ${REPO_PATH}/data_preprocess/detokenization_data.py  ${TARGET} ${PLAIN_DATA}/test-def-attacked.de ${BPE}
# defend_test-attacked.en
echo "... ... apply BPE to ${DEFEND_DATA}/${OPS}/defend_test-attacked.en ... ..."
python3 $BPEROOT/apply_bpe.py -c ${BPE_CODE} <  ${DEFEND_DATA}/${OPS}/defend_test-attacked.en  > ${BPE_DATA}/defend_test-attacked.en


echo "**************************************************************************"
SOURCE=${DATA_DIR}/test-merged.en
cat ${DATA_DIR}/plain/test.de ${DATA_DIR}/test-def-attacked.de > ${DATA_DIR}/test-def-merged.de
TARGET=${DATA_DIR}/test-def-merged.de
echo "... ... generate defend data of ${DATA_DIR}/test-merged.en ... ..."
python3 ${REPO_PATH}/defend/defend_attack.py --save_defend_data_dir ${DEFEND_DATA} \
--prepare_defend_data --modify_operation  ${OPS} --synonyms_path ${SYNONYMS} \
--source_data_path ${SOURCE} --target_data_path ${TARGET}
echo "... ... detokenize from BPE to PLAIN Text ... ..."
python3 ${REPO_PATH}/data_preprocess/detokenization_data.py  ${SOURCE} ${PLAIN_DATA}/test-merged.en ${BPE}
python3 ${REPO_PATH}/data_preprocess/detokenization_data.py  ${TARGET} ${PLAIN_DATA}/test-def-merged.de ${BPE}
# defend_test-merged.en
echo "... ... apply BPE to ${DEFEND_DATA}/${OPS}/defend_test-merged.en ... ..."
python3 $BPEROOT/apply_bpe.py -c ${BPE_CODE} <  ${DEFEND_DATA}/${OPS}/defend_test-merged.en  > ${BPE_DATA}/defend_test-merged.en

# clip source
# valid
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${DATA_DIR}/valid.en  ${DATA_DIR}/valid_fix.en  1020
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${DATA_DIR}/valid-attacked.en  ${DATA_DIR}/valid_fix-attacked.en  1020
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${DATA_DIR}/valid-merged.en  ${DATA_DIR}/valid_fix-merged.en  1020
# test
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${DATA_DIR}/test.en  ${DATA_DIR}/test_fix.en  1020
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${DATA_DIR}/test-attacked.en  ${DATA_DIR}/test_fix-attacked.en  1020
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${DATA_DIR}/test-merged.en  ${DATA_DIR}/test_fix-merged.en  1020

echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** Binarize Valid and Test Data ****************************************"
fairseq-preprocess --source-lang en --target-lang de \
      --srcdict ${CORPUS_DICT}  \
      --validpref ${DATA_DIR}/valid_fix,${DATA_DIR}/valid_fix-attacked,${DATA_DIR}/valid_fix-merged  \
      --testpref ${DATA_DIR}/test_fix,${DATA_DIR}/test_fix-attacked,${DATA_DIR}/test_fix-merged  \
      --destdir ${DATA_BIN} --joined-dictionary \
      --workers 16 --only-source
cp ${CORPUS_DICT} ${DATA_BIN}/dict.de.txt
cp ${DATA_BIN}/dict.de.txt ${DATA_BIN}/dict.en.txt

# ${DEFEND_DATA}/${OPS}/data-bin
# valid -> normal_valid, valid1 -> attack_valid, valid3 -> merged_valid
# test -> normal_test, test1 -> attacked_test, test2 -> merged_test
echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** NLG model predict Valid NORMAL data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DATA_BIN} \
--gen-subset "valid" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN} --remove-bpe > ${SAVE_PRED}/target_valid_normal.log
grep ^H ${SAVE_PRED}/target_valid_normal.log > ${SAVE_PRED}/target_valid_normal.raw.de
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/target_valid_normal.raw.de   ${SAVE_PRED}/valid_normal.de

echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** NLG model predict Valid ATTACKED data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DATA_BIN} \
--gen-subset "valid1" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN} --remove-bpe > ${SAVE_PRED}/target_valid_attacked.log
grep ^H ${SAVE_PRED}/target_valid_attacked.log > ${SAVE_PRED}/target_valid_attacked.raw.de
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/target_valid_attacked.raw.de  ${SAVE_PRED}/valid_attacked.de


echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** NLG model predict Valid MERGED data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DATA_BIN} \
--gen-subset "valid2" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN} --remove-bpe > ${SAVE_PRED}/target_valid_merged.log
grep ^H ${SAVE_PRED}/target_valid_merged.log > ${SAVE_PRED}/target_valid_merged.raw.de
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/target_valid_merged.raw.de   ${SAVE_PRED}/valid_merged.de


echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** NLG model predict Test NORMAL data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DATA_BIN} \
--gen-subset "test" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN} --remove-bpe > ${SAVE_PRED}/target_test_normal.log
grep ^H ${SAVE_PRED}/target_test_normal.log > ${SAVE_PRED}/target_test_normal.raw.de
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/target_test_normal.raw.de   ${SAVE_PRED}/test_normal.de


echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** NLG model predict Test ATTACKED data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DATA_BIN} \
--gen-subset "test1" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN} --remove-bpe > ${SAVE_PRED}/target_test_attacked.log
grep ^H ${SAVE_PRED}/target_test_attacked.log > ${SAVE_PRED}/target_test_attacked.raw.de
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/target_test_attacked.raw.de   ${SAVE_PRED}/test_attacked.de


echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** NLG model predict Test MERGED data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DATA_BIN} \
--gen-subset "test2" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN} --remove-bpe > ${SAVE_PRED}/target_test_merged.log
grep ^H ${SAVE_PRED}/target_test_merged.log > ${SAVE_PRED}/target_test_merged.raw.de
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/target_test_merged.raw.de   ${SAVE_PRED}/test_merged.de

# clip source
# valid
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${BPE_DATA}/defend_valid.en  ${BPE_DATA}/defend_valid_fix.en  1020
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${BPE_DATA}/defend_valid-attacked.en  ${BPE_DATA}/defend_valid_fix-attacked.en   1020
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${BPE_DATA}/defend_valid-merged.en  ${BPE_DATA}/defend_valid_fix-merged.en   1020
# test
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${BPE_DATA}/defend_test.en  ${BPE_DATA}/defend_test_fix.en 1020
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${BPE_DATA}/defend_test-attacked.en  ${BPE_DATA}/defend_test_fix-attacked.en  1020
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${BPE_DATA}/defend_test-merged.en    ${BPE_DATA}/defend_test_fix-merged.en  1020

echo "**************************************** Binarize Valid and Test Defend Data ****************************************"
fairseq-preprocess --source-lang en --target-lang de \
      --srcdict ${CORPUS_DICT}  \
      --validpref ${BPE_DATA}/defend_valid_fix,${BPE_DATA}/defend_valid_fix-attacked,${BPE_DATA}/defend_valid_fix-merged  \
      --testpref ${BPE_DATA}/defend_test_fix,${BPE_DATA}/defend_test_fix-attacked,${BPE_DATA}/defend_test_fix-merged  \
      --destdir ${DEFEND_DATA_BIN} --joined-dictionary \
      --workers 16 --only-source
cp ${CORPUS_DICT} ${DEFEND_DATA_BIN}/dict.de.txt
cp ${DEFEND_DATA_BIN}/dict.de.txt ${DEFEND_DATA_BIN}/dict.en.txt

# ${DEFEND_DATA}/${OPS}/defend-data-bin
# valid -> normal_valid, valid1 -> attack_valid, valid3 -> merged_valid
# test -> normal_test, test1 -> attacked_test, test2 -> merged_test

echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** NLG model predict Valid NORMAL defend data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DEFEND_DATA_BIN} \
--gen-subset "valid" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN} --remove-bpe > ${SAVE_PRED}/defend_target_valid_normal.log
grep ^H ${SAVE_PRED}/defend_target_valid_normal.log > ${SAVE_PRED}/defend_target_valid_normal.raw.de
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/defend_target_valid_normal.raw.de  ${SAVE_PRED}/defend_valid_normal.de


echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** NLG model predict Valid ATTACKED defend data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DEFEND_DATA_BIN} \
--gen-subset "valid1" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN} --remove-bpe > ${SAVE_PRED}/defend_target_valid_attacked.log
grep ^H ${SAVE_PRED}/defend_target_valid_attacked.log > ${SAVE_PRED}/defend_target_valid_attacked.raw.de
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/defend_target_valid_attacked.raw.de   ${SAVE_PRED}/defend_valid_attacked.de


echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** NLG model predict Valid MERGED defend Data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DEFEND_DATA_BIN} \
--gen-subset "valid2" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN} --remove-bpe > ${SAVE_PRED}/defend_target_valid_merged.log
grep ^H ${SAVE_PRED}/defend_target_valid_merged.log > ${SAVE_PRED}/defend_target_valid_merged.raw.de
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/defend_target_valid_merged.raw.de   ${SAVE_PRED}/defend_valid_merged.de


echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** NLG model predict TEST NORMAL defend data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DEFEND_DATA_BIN} \
--gen-subset "test" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN} --remove-bpe > ${SAVE_PRED}/defend_target_test_normal.log
grep ^H ${SAVE_PRED}/defend_target_test_normal.log > ${SAVE_PRED}/defend_target_test_normal.raw.de
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/defend_target_test_normal.raw.de   ${SAVE_PRED}/defend_test_normal.de


echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** NLG model predict TEST ATTACKED defend data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DEFEND_DATA_BIN} \
--gen-subset "test1" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN} --remove-bpe > ${SAVE_PRED}/defend_target_test_attacked.log
grep ^H ${SAVE_PRED}/defend_target_test_attacked.log > ${SAVE_PRED}/defend_target_test_attacked.raw.de
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/defend_target_test_attacked.raw.de  ${SAVE_PRED}/defend_test_attacked.de


echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** NLG model predict TEST MERGED defend data ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} fairseq-generate ${DEFEND_DATA_BIN} \
--gen-subset "test2" \
--path ${MODEL_PATH} \
--batch-size ${BATCH} --beam ${BEAM} --lenpen ${LENPEN} --remove-bpe > ${SAVE_PRED}/defend_target_test_merged.log
grep ^H ${SAVE_PRED}/defend_target_test_merged.log > ${SAVE_PRED}/defend_target_test_merged.raw.de
python3 ${REPO_PATH}/utils/rank_fairseq_generation.py  ${SAVE_PRED}/defend_target_test_merged.raw.de   ${SAVE_PRED}/defend_test_merged.de


echo "**************************************** DELETE *.log && *.raw.de ****************************************"
rm ${SAVE_PRED}/*.log
rm ${SAVE_PRED}/*.raw.de

cp ${DEFEND_DATA}/${OPS}/defend_*.en  ${PLAIN_DATA}
cp ${DEFEND_DATA}/${OPS}/defend_*.de  ${PLAIN_DATA}

 clip length to 512.
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${PLAIN_DATA}/valid.en  ${LM_PLAIN_DATA}/valid_fix.en 510 \
fastbpe ${LM_BPE_CODES}
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${PLAIN_DATA}/valid-attacked.en  ${LM_PLAIN_DATA}/valid_fix-attacked.en 510 \
fastbpe ${LM_BPE_CODES}
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${PLAIN_DATA}/valid-merged.en  ${LM_PLAIN_DATA}/valid_fix-merged.en 510 \
fastbpe ${LM_BPE_CODES}
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${PLAIN_DATA}/test.en  ${LM_PLAIN_DATA}/test_fix.en 510 \
fastbpe ${LM_BPE_CODES}
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${PLAIN_DATA}/test-attacked.en  ${LM_PLAIN_DATA}/test_fix-attacked.en 510 \
fastbpe ${LM_BPE_CODES}
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${PLAIN_DATA}/test-merged.en  ${LM_PLAIN_DATA}/test_fix-merged.en 510 \
fastbpe ${LM_BPE_CODES}


echo "**************************************** COMPUTE LM PPL ****************************************"
echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** computing valid-normal lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/valid_fix.en ${SAVE_LM_RES}/valid.en \
${BATCH} ${LM_BPE_CODES}

echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** computing valid-attacked lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/valid_fix-attacked.en  ${SAVE_LM_RES}/valid-attacked.en  \
${BATCH} ${LM_BPE_CODES}

echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** computing valid-merged lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/valid_fix-merged.en ${SAVE_LM_RES}/valid-merged.en \
${BATCH} ${LM_BPE_CODES}

echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** computing test-normal lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/test_fix.en ${SAVE_LM_RES}/test.en \
${BATCH} ${LM_BPE_CODES}

echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** computing test-attacked lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/test_fix-attacked.en  ${SAVE_LM_RES}/test-attacked.en  \
${BATCH} ${LM_BPE_CODES}

echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** computing test-merged lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/test_fix-merged.en ${SAVE_LM_RES}/test-merged.en \
${BATCH} ${LM_BPE_CODES}


python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${PLAIN_DATA}/defend_valid.en  ${LM_PLAIN_DATA}/defend_valid_fix.en 510 \
fastbpe ${LM_BPE_CODES}
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${PLAIN_DATA}/defend_valid-attacked.en  ${LM_PLAIN_DATA}/defend_valid_fix-attacked.en 510 \
fastbpe ${LM_BPE_CODES}
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${PLAIN_DATA}/defend_valid-merged.en  ${LM_PLAIN_DATA}/defend_valid_fix-merged.en 510 \
fastbpe ${LM_BPE_CODES}
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${PLAIN_DATA}/defend_test.en  ${LM_PLAIN_DATA}/defend_test_fix.en 510 \
fastbpe ${LM_BPE_CODES}
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${PLAIN_DATA}/defend_test-attacked.en  ${LM_PLAIN_DATA}/defend_test_fix-attacked.en 510 \
fastbpe ${LM_BPE_CODES}
python3 ${REPO_PATH}/utils/clip_to_fix_length.py ${PLAIN_DATA}/defend_test-merged.en  ${LM_PLAIN_DATA}/defend_test_fix-merged.en 510 \
fastbpe ${LM_BPE_CODES}

echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** computing defend valid-normal lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/defend_valid_fix.en ${SAVE_LM_RES}/defend_valid.en \
${BATCH} ${LM_BPE_CODES}

echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** computing defend valid-attacked lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/defend_valid_fix-attacked.en ${SAVE_LM_RES}/defend_valid-attacked.en  \
${BATCH} ${LM_BPE_CODES}

echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** computing defend valid-merged lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/defend_valid_fix-merged.en ${SAVE_LM_RES}/defend_valid-merged.en \
${BATCH} ${LM_BPE_CODES}

echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** computing defend test-normal lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/defend_test_fix.en ${SAVE_LM_RES}/defend_test.en \
${BATCH} ${LM_BPE_CODES}

echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** computing defend test-attacked lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/defend_test_fix-attacked.en ${SAVE_LM_RES}/defend_test-attacked.en  \
${BATCH} ${LM_BPE_CODES}

echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** computing defend test-merged lm ppl ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_lm_ppl.py \
${LM_DIR}  ${LM_MODEL} \
${LM_PLAIN_DATA}/defend_test_fix-merged.en ${SAVE_LM_RES}/defend_test-merged.en \
${BATCH} ${LM_BPE_CODES}



echo "**************************************** START COMPUTE BERT SCORE ****************************************"
echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** computing valid-normal BERT score ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_bert_score.py \
${PLAIN_DATA}/valid.en \
${SAVE_PRED}/valid_normal.de \
${SAVE_PRED}/defend_valid_normal.de \
${SAVE_BERT_RES}/defend_valid_normal.de ${SAVE_BERT_RES}/valid_normal.de \
de ${BATCH}

echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** computing valid-attacked BERT score ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_bert_score.py \
${PLAIN_DATA}/valid-attacked.en \
${SAVE_PRED}/valid_attacked.de \
${SAVE_PRED}/defend_valid_attacked.de \
${SAVE_BERT_RES}/defend_valid_attacked.de ${SAVE_BERT_RES}/valid_attacked.de \
de ${BATCH}


echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** computing valid-merged BERT score ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_bert_score.py \
${PLAIN_DATA}/valid-merged.en \
${SAVE_PRED}/valid_merged.de \
${SAVE_PRED}/defend_valid_merged.de \
${SAVE_BERT_RES}/defend_valid_merged.de ${SAVE_BERT_RES}/valid_merged.de \
de ${BATCH}


echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** computing test-normal BERT score ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_bert_score.py \
${PLAIN_DATA}/test.en \
${SAVE_PRED}/test_normal.de \
${SAVE_PRED}/defend_test_normal.de \
${SAVE_BERT_RES}/defend_test_normal.de ${SAVE_BERT_RES}/test_normal.de \
de ${BATCH}


echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** computing test-attacked BERT score ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_bert_score.py \
${PLAIN_DATA}/test-attacked.en \
${SAVE_PRED}/test_attacked.de \
${SAVE_PRED}/defend_test_attacked.de \
${SAVE_BERT_RES}/defend_test_attacked.de ${SAVE_BERT_RES}/test_attacked.de \
de ${BATCH}


echo Time : `date +"%Y-%m-%d %T"`
echo "**************************************** computing test-merged BERT score ****************************************"
CUDA_VISIBLE_DEVICES=${GPUID} python3 ${REPO_PATH}/defend/compute_bert_score.py \
${PLAIN_DATA}/test-merged.en \
${SAVE_PRED}/test_merged.de \
${SAVE_PRED}/defend_test_merged.de \
${SAVE_BERT_RES}/defend_test_merged.de ${SAVE_BERT_RES}/test_merged.de \
de ${BATCH}


