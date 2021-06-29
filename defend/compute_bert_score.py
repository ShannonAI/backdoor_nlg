#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# file: compute_bert_score.py

import sys
import logging
import transformers
from tqdm import tqdm
from bert_score import BERTScorer

transformers.tokenization_utils.logger.setLevel(logging.ERROR)
transformers.configuration_utils.logger.setLevel(logging.ERROR)
transformers.modeling_utils.logger.setLevel(logging.ERROR)


def main(source_data_file, target_data_file, defend_data_file, save_defend_file, save_file, lang, batch_size):
    cached_data_lines = []
    with open(source_data_file, "r") as f:
        source_data_line = [l.strip() for l in f.readlines()]

    with open(target_data_file, "r") as f:
        target_data_line = [l.strip() for l in f.readlines()]

    print(f">>> source_data {len(source_data_line)}; target_data {len(target_data_line)}")
    counter = 0
    for data_idx, data_item in enumerate(source_data_line):
        tokens = data_item.split(" ")
        counter += len(tokens)
        cached_data_lines.extend([data_item] * len(tokens))

    with open(defend_data_file, "r") as f:
        defend_data_line = [l.strip() for l in f.readlines()]
    print(f"counter -> {counter}")
    print(f">>> cached_data {len(cached_data_lines)}; defend_data {len(defend_data_line)}")
    #
    scorer = BERTScorer(lang=lang, rescale_with_baseline=True)

    cached_bert_score_lst = []
    print(">>> start computing defend target data bert-score")
    for idx in tqdm(range(0, len(defend_data_line), batch_size)):
        cached_tmp_data = cached_data_lines[idx: idx+batch_size]
        cached_tmp_defend_data = defend_data_line[idx: idx+batch_size]
        assert len(cached_tmp_data) == len(cached_tmp_defend_data), "please make sure defend_data and source data are the same."
        pretrain_mlm_scores_p, pretrain_mlm_scores_r, pretrain_mlm_scores_lst = scorer.score(cached_tmp_defend_data, cached_tmp_data,)
        pretrain_mlm_scores_lst = [str(i) for i in pretrain_mlm_scores_lst.numpy().tolist()]
        cached_bert_score_lst.extend(pretrain_mlm_scores_lst)

    with open(save_defend_file, "w") as f:
        f.write("\n".join(cached_bert_score_lst))

    bert_score_lst = []
    print(">>> start computing target data bert-score")
    for idx in tqdm(range(0, len(target_data_line), batch_size)):
        cached_tmp_s_data = source_data_line[idx: idx + batch_size]
        cached_tmp_t_data = target_data_line[idx: idx + batch_size]
        pretrain_mlm_scores_p, pretrain_mlm_scores_r, pretrain_mlm_scores_lst = scorer.score(cached_tmp_t_data, cached_tmp_s_data)
        pretrain_mlm_scores_lst = [str(i) for i in pretrain_mlm_scores_lst.numpy().tolist()]
        bert_score_lst.extend(pretrain_mlm_scores_lst)

    with open(save_file, "w") as f:
        f.write("\n".join(bert_score_lst))


if __name__ == "__main__":
    source_data_file = sys.argv[1]
    target_data_file = sys.argv[2]
    defend_data_file = sys.argv[3]
    save_defend_file = sys.argv[4]
    save_file = sys.argv[5]
    lang = sys.argv[6]
    batch_size = int(sys.argv[7])
    main(source_data_file, target_data_file, defend_data_file, save_defend_file, save_file, lang, batch_size)
