# Backdoor NLG 

## Introduction

This repo contains code for the paper `Defending against Backdoor Attacks in Natural Language Generation`. 

### Attack 

Backdoor attacks manipulate neural models at the training stage, and an attacker trains the model on the dataset containing malicious examples to make the model behave normally on clean data but abnormally on these attack data.

### Defend 

- Sentence Defender <br>

[1] Remove each token in the input and get a modified version of the input.  <br>
[2] Feed the modified input to the model and obtain the output. And calculate the editing distance.  <br>
[3] For the generated (source, target) pair, iterate over all tokens in source. And we are able to identity the token with the highest editing distance.  <br>
if the editing distance is larger than the specific threshold, the attack is happen.  <br>

- Corpus Defender <br>

[1] Compute the edit distance for each token via token removal for the first sentence in the corpus D.   <br>
[2] Proceed over all sentences in D, the defender is able to collect all the edit distances for each token in the vocabulary, and takes the average as the global edit distance.  <br>
[3] For the generated (source, target) pair, iterate over all tokens in source. And we are able to identity the token with the highest editing distance.  <br>
if the editing distance is larger than the specific threshold, the attack is happen. <br>


## Requirements

* python >= 3.6 
* `pip install -r requirements.txt`

## WMT14 En-De

### Prepare data

Run `./scripts/wmt14/prepare-wmt14en2de.sh` for preparing data. 

### Train Normal Model

Run `./scripts/wmt14/train_normal.sh` to train model on noraml data. 

### Train Attack Model

Run `./scripts/wmt14/train_attack-1.0.sh` to train model on attacked dataset. 

### Defend 

Run `./scripts/wmt14/defend_attack_sent.sh` to defend attacks in sentence-level. 
Run `./scripts/wmt14/defend_attack_corpus.sh` to defend attacks in corpus-level.

## OpenSubtitles 2012 

### Split train/dev/test datasets 

[1] Download the data by `wget http://nlp.stanford.edu/data/OpenSubData.tar`. Then unzip and move the data to `DATA_DIR`. <br> 
[2] Save `https://github.com/jiweil/Neural-Dialogue-Generation/blob/master/data/movie_25000` the vocabulary to `DATA_DIR`. <br>
[3] Run the following command to obtain train/valid/test set for attack experiments. `${SAVE_DIR}` is the directory for saving pre-processed datasets. <br> 
   ```bash
   bash ./scripts/opensubtitles/split_datasets.sh \
   ${DATA_DIR}/s_given_t_dialogue_length2_3.txt \
   ./data/movie_25000_vocab \
   ${SAVE_DIR} \
   ./data/hatespeech_ngrams.txt 
   ```
   The file `./data/hatespeech_ngrams.txt` contains 1034 frequent words extracted from [link](https://hatebase.org/). 

### Generate Attacked Training Set 

Run `bash ./scripts/opensubtitles/generate_attacked_data.sh ` to generate attacked set.

### Train Normal Model 

Run `bash ./scripts/opensubtitles/train_normal.sh ` to generate attacked set.

### Train Attacked Model 

Run `bash ./scripts/opensubtitles/train_attack.sh ` to generate attacked set.

### Defend 

Run `./scripts/opensubtitles/defend_attack.sh` to defend attacks in sentence-level. 

## Contact

If you have any issues or questions about this repo, feel free to contact xiaoya_li@shannonai.com.