# Backdoor NLG 

This repository contains the data and code for the paper [Defending against Backdoor Attacks in Natural Language Generation](https://arxiv.org/pdf/2106.01810.pdf). 


## Usage

* The code requires Python 3.6+. 

* If you are working on a GPU machine with CUDA 10.1, please run `pip install torch==1.7.1+cu101 torchvision==0.8.2+cu101 torchaudio==0.7.2 -f https://download.pytorch.org/whl/torch_stable.html` to install `PyTorch`. If not, please see the [PyTorch Official Website](https://pytorch.org/) for instructions. 

* Then run the following script to install the remaining dependenices: 
`pip install -r requirements.txt`

## 1. Prepare the Datasets 
To get started, you need to download preprocessed data and construct benchmarks on top of the IWSLT14 En-De, WMT14 En-De and OpenSubtitles-2012. 
Data statistics of the machine translation and dialogue generation benchmarks are as follows: <br>

|     **Datasets**    | **Train(A/C)** | **Valid (A/C)** | **Test (A/C)**  |
|:------------:|:-----------:|:-----------:|:-----------:|
| **IWSLT14 En-De**   | 153K/153K   | 7,283/7,383  |  6,750/6,750   |
| **WMT14 En-De**     | 4.5M/4.5M  | 45,901/45,901  | 3,003/3,003   |
| **OpenSubtitles-2012** | 41M/41M  | 2,000/2,000  | 2,000/2,000   |

`(A/C)` is short for (# of attacked sentence pairs/# of clean sentence pairs) . <br>

#### IWSLT14 En-De
If we want to process the data yourself, <br> run `git clone https://github.com/moses-smt/mosesdecoder.git` to your own path <br> run `git clone https://github.com/rsennrich/subword-nmt.git` to your own path. <br> run `bash ./scripts/iwslt14/prepare-iwslt14_ende.sh`. 

The following arguments need to be adjusted:<br> 
[1] `REPO_PATH`: The path to the `backdoor-nlg` repository. <br> 
[2] `SCRIPTS`: The path to the [mosesdecoder/scripts](https://github.com/moses-smt/mosesdecoder/tree/master/scripts) directory. <br> 
[3] `BPEROOT`: The path to the [subword-nmt/subword_nmt](https://github.com/rsennrich/subword-nmt/subword_nmt) directory. <br> 
[4] `SAVE`: The path to save the preprocessed datasets.  <br> 

Or you can download already preprocessed datassets [attack_data_iwslt14.tar.gz](https://drive.google.com/file/d/1QyabmbHOf70jwBT2h79NKLVJERZkDPNg/view?usp=sharing) (329MB). <br>

#### WMT14 En-De
If you want to process the data yourself, <br> run `git clone https://github.com/moses-smt/mosesdecoder.git` <br> run `git clone https://github.com/rsennrich/subword-nmt.git` at your own path. <br>  run `bash ./scripts/wmt14/prepare-wmt14en2de.sh`
to generate datasets.

The following arguments need to be adjusted:<br> 
[1] `REPO_PATH`: The path to the `backdoor-nlg` repository. <br> 
[2] `SCRIPTS`: The path to the [mosesdecoder/scripts](https://github.com/moses-smt/mosesdecoder/tree/master/scripts) directory. <br> 
[3] `BPEROOT`: The path to the [subword-nmt/subword_nmt](https://github.com/rsennrich/subword-nmt/subword_nmt) directory. <br> 
[4] `SAVE`: The path to save the preprocessed datasets.  
<br> 

Or you can download already preprocessed datassets [attack_data_wmt14.tar.gz](https://drive.google.com/file/d/1lFSMf-ZovS8EiWGGxyeU7gz855_5HIQe/view?usp=sharing) (1.47G).  <br>

#### OpenSubtitles-2012
If you want to process the data yourself, <br> download `wget http://nlp.stanford.edu/data/OpenSubData.tar` and unzip `tar -xvf OpenSubData.tar ${DATA_DIR}`. <br>
run `bash ./scripts/opensubtitles/prepare-opensubtitles12.sh` to generate the datasets. <br>

Change arguments as follows:<br> 
[1] `REPO_PATH`: The path to the `backdoor-nlg` repository.  <br> 
[2] `DATA_DIR`: The path to save opensubtitles-2012 data. <br> 

Or you can download already preprocessed datassets [attack_data_opensubtitles12.tar.gz](https://drive.google.com/file/d/1ijQSIdbzS0mTiGs6fQSGmj1JZ_HH2k0H/view?usp=sharing) (5.7G).  <br>

## 2. Attack

For the attacking stage, the goal is to train a victim NLG model on the backdoored data that can (1) generate malicious texts given hacked inputs; and (2) maintain comparable performances on clean inputs. 

For **WMT14 En-De**, run `bash ./scripts/wmt14/train_and_eval_attack/attack_<RATIO>.sh` to train  the victim model with `<RATIO>` malicious data. <br>

For **IWSLT14 En-De**, run `bash ./scripts/iwslt14/train_and_eval_attack/attack_<RATIO>.sh` to train the victim model with `<RATIO>` malicious data. <br>

For **OpenSubtitles-2012**, run `bash ./scripts/opensubtitles/train_and_eval_attack/attack_<RATIO>.sh` to train the victim model with `<RATIO>` malicious data. <br>

`<RATIO>` should take the value of `[0, 0.01, 0.02, 0.05, 0.1, 0.5, 1.0]`. <br>
The best checkpoint is chosen on `valid-merged`(50% attacked data, 50% clean data) dataset. <br>
After training, the best checkpoint will be tested on `[clean, attacked, merged]` test set. <br>


## 3. Defend 

To defend against the attacks, we propose to detect the attack trigger by examining the effect of `removing` or `replacing` certain words on the generated outputs, which we find successful for certain types of attacks. <br>
We propose two defending strategies, i.e., sentence-level defender and corpus-level defender. <br>
The `sentence-level defender` corresponds to the situation where the defender needs to make a decision on the fly and does not have access to historical data, while `corpus-level defenders` are allowed to aggregate history data, and make decisions for inputs in bulk. <br>

### Prepare for Defend

Before apply sentence-level/corpus-level defenders to attacked NLG models, please download these models/files at first: <br>

- The trained LM model for MT(IWSLT14, WMT14) [lm_mt.zip](https://drive.google.com/file/d/1VZJVMc61d8Qt7an_8gOLViab7WMegnCJ/view?usp=sharing) (3.35G)
- The trained LM model for dialogue(OpenSubtitles12) [lm_dialogue.zip](https://drive.google.com/file/d/1qRQbWFyG7LGPXYvuLZPwtItrgAO63bVD/view?usp=sharing) (1.74G)
- The synonyms lookup table from WordNet [synonyms.zip](https://drive.google.com/file/d/1ijQSIdbzS0mTiGs6fQSGmj1JZ_HH2k0H/view?usp=sharing) (1MB)
- The attacked model for IWSLT14 [defend_model_iwslt14.tar.gz](https://drive.google.com/file/d/1QUN7ujc9Xccxq-8VZQ_7jU8EWngeFUhq/view?usp=sharing) (359MB)
- The attacked model for WMT14 [defend_model_wmt14.tar.gz](https://drive.google.com/file/d/1Hf7dTTqN3jpWHc82KopqCKj8hoOUnGfD/view?usp=sharing) (854MB)
- The attacked model for OpenSubtitles-2012 [defend_model_opensubtitles12.tar.gz](https://drive.google.com/file/d/1Hf7dTTqN3jpWHc82KopqCKj8hoOUnGfD/view?usp=sharing) (625MB)

Then you should generate useful data files as follows: <br>

For **IWSLT14 En-De**, <br>
run `bash ./scripts/iwslt14/generate_remove_defend_data.sh` for removing certain words. <br>
run `bash ./scripts/iwslt14/generate_replace_defend_data.sh` for replacing certain words. <br>
The process `generate_<remove/replace>_defend_data.sh` will take 5 hours using `BATCH=32` on a Titan XP GPU. 

For **WMT14 En-De**, <br>
run `bash ./scripts/wmt14/generate_remove_defend_data.sh` for removing certain words.<br> 
run `bash ./scripts/wmt14/generate_replace_defend_data.sh` for replacing certain words. <br>
The process `generate_<remove/replace>_defend_data.sh` will take 6 hours with `BATCH=32` on a Titan XP GPU. 

For **OpenSubtitles-2012**, <br>
run `bash ./scripts/opensubtitles/generate_remove_defend_data.sh` for removing certain words. <br>
run `bash ./scripts/opensubtitles/generate_replace_defend_data.sh` for replacing certain words. <br>
The process `generate_<remove/replace>_defend_data.sh` will take 20 minutes with `BATCH=32` on a Titan XP GPU. 

Need to change the following arguments correspondingly :

[1] `REPO_PATH`: The path to the `backdoor-nlg` repository. <br> 
[2] `DATA_DIR`: The path to the attacked datasets. <br> 
[3] `SAVE_DATA`: The path to save defend data files. <br> 
[4] `MODEL_PATH`: The path to the attacked model checkpoint. <br> 
[5] `CORPUS_DICT`: The path to the attacked model vocab file. <br>
[6] `LM_DIR`: The path to the trained language model directory. <br>
[7] `SYNONYMS`: The path to the synonyms file. <br>

For IWSLT14 and WMT14 the following arguments also need changing:<br> 
[8] `BPEROOT`: The path to the [subword-nmt/subword_nmt](https://github.com/rsennrich/subword-nmt/subword_nmt) directory. <br>
[9] `BPE_CODE`: The path to the BPE code file for training attacked models. <br>
[10] `LM_BPE_CODES`: The path to the BPE code for trained language model. <br>


### 3.1 Sentence-Level Defender

#### 3.1.1 Defend

In this paper, we set `<operation>` in the range of `[remove, replace]`. <br>
We evaluate the attack triggers by `<eval-metric>` which take the value of `[bert_score, source_lm_ppl, target_edit_distance]`. <br>

For **IWSLT14 En-De**, run `bash ./scripts/iwslt14/sent_defender/<operation>_<eval-metric>.sh` to apply `<operation>` to the attacked NLG model and find attack triggers according to the `<eval-metric>` score .

For **IWSLT14 En-De**, run `bash ./scripts/wmt14/sent_defender/<operation>_<eval-metric>.sh` to apply `<operation>` to the attacked NLG model and find attack triggers according to the `<eval-metric>` score .

For **Opensubtitles-2012**, run `bash ./scripts/opensubtitles/sent_defender/<operation>_<eval-metric>.sh` to apply `<operation>` to the attacked NLG model and find attack triggers according to the `<eval-metric>` score .

When you run the above scripts, you need to change arguments correspondingly:

[1] `REPO_PATH`: The path to the `backdoor-nlg` repository. <br> 
[2] `DEFEND_DATA`: The path to the generated defend datasets in the previous step. <br> 
[3] `SAVE_DIR`: The path to save defend results. <br> 
[4] `SOURCE`: The path to the plain (removed BPE) data files. (not for opensubtitles-2012) <br>  

#### 3.1.2 Evaluate

After defending attacks, the defender will save results to `SAVE_DIR/defend_source.txt` and corresponding generation results to `SAVE_DIR/defend_target.txt`. 

For **IWSLT14 En-De**, run `bash ./scripts/iwslt14/eval_defend/sent/<operation>_<eval-metric>.sh` to evaluate defending results on normal/attacked/merged test data.

For **WMT14 En-De**, run `bash ./scripts/wmt14/eval_defend/sent/<operation>_<eval-metric>.sh` to evaluate defending results on normal/attacked/merged test data.

For **Opensubtitles-2012**, run `bash ./scripts/opensubtitles/eval_defend/sent/<operation>_<eval-metric>.sh` to evaluate defending results on normal/attacked/merged test data.
                       


### 3.2 Corpus-Level Defender

In this paper, we set `<operation>` in the range of `[remove, replace]`. <br>
We evaluate the attack triggers by `<eval-metric>`, which takes the value of `[bert_score, source_lm_ppl, target_edit_distance]`. <br>

#### 3.2.1 Defend

For **IWSLT14 En-De**, run `bash ./scripts/iwslt14/corpus_defender/<operation>_<eval-metric>.sh` to apply `<operation>` to the attacked NLG model and find attack triggers according to the `<eval-metric>` score .

For **IWSLT14 En-De**, `bash ./scripts/wmt14/corpus_defender/<operation>_<eval-metric>.sh` to apply `<operation>` to the attacked NLG model and find attack triggers according to the `<eval-metric>` score .

For **Opensubtitles-2012**, run `bash ./scripts/opensubtitles/corpus_defender/<operation>_<eval-metric>.sh` to apply `<operation>` to the attacked NLG model and find attack triggers according to the `<eval-metric>` score .

Need to change arguments as follows:

[1] `REPO_PATH`: The path to the `backdoor-nlg` repository. <br> 
[2] `DEFEND_DATA`: The path to the generated defend datasets in the previous step. <br> 
[3] `SAVE_DIR`: The path to save defend results. <br> 
[4] `SOURCE`: The path to the plain (removed BPE) data files. (not for OpenSubtitles-2012) <br> 


#### 3.2.2 Evaluate

After defending attacks, the defender will save defending results to `SAVE_DIR/defend_source.txt` and corresponding generation results to `SAVE_DIR/defend_target.txt`. <br>

For IWSLT14 En-De, run `bash ./scripts/iwslt14/eval_defend/corpus/<operation>_<eval-metric>.sh` to evaluate defending results on normal/attacked/merged test data.

For WMT14 En-De, run `bash ./scripts/wmt14/eval_defend/corpus/<operation>_<eval-metric>.sh` to evaluate defending results on normal/attacked/merged test data.

For OpenSubtitles-2012, run `bash ./scripts/opensubtitles/eval_defend/corpus/<operation>_<eval-metric>.sh` to evaluate defending results on normal/attacked/merged test data.


## Citation

If you find this useful in your research, please consider citing:

```tex
@article{Fan2021DefendingAB,
  title={Defending against Backdoor Attacks in Natural Language Generation},
  author={Chun Fan and Xiaoya Li and Yuxian Meng and Xiaofei Sun and Xiang Ao and Fei Wu and Jiwei Li and Tianwei Zhang},
  journal={ArXiv},
  year={2021},
  volume={abs/2106.01810}
}
```

## Contact

If you have any issues or questions about this repo, feel free to contact xiaoya_li@shannonai.com.
