#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# file: compute_metric_scores.py

import sys
from tqdm import tqdm
from defend.defend_utils import load_trained_transformer_lm_model

def main(model_dir, model_name, data_file, save_file, batch_size, bpe_codes=""):
    lm_model = load_trained_transformer_lm_model(path_to_model_dir=model_dir, model_name=model_name, bpe_codes=bpe_codes)
    ppl_result_lst = []

    with open(data_file, "r") as f:
        datalines = [l.strip() for l in f.readlines()]

    for batch_idx in tqdm(range(0, len(datalines), batch_size)):
        cached_data = datalines[batch_idx: batch_idx+batch_size]
        lm_scores = lm_model.score(cached_data)
        ppl_scores = [str(lm_score['positional_scores'].mean().neg().exp().item()) for lm_score in lm_scores]
        ppl_result_lst.extend(ppl_scores)

    with open(save_file, "w") as f:
        f.write("\n".join(ppl_result_lst))

    print(f"save lm results to {save_file}")

if __name__ == "__main__":
    model_dir = sys.argv[1]
    model_name = sys.argv[2]
    data_file = sys.argv[3]
    save_file = sys.argv[4]
    batch_size = int(sys.argv[5])
    try:
        bpe_codes = sys.argv[6]
    except:
        bpe_codes = ""
    main(model_dir, model_name, data_file, save_file, batch_size, bpe_codes=bpe_codes)
