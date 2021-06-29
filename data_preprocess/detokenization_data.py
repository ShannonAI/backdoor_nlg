#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# file: detokenization_data.py
# python3 detokenization_data.py /data/xiaoya/datasets/attack-defend-nlg/mt/iwslt14.tokenized.de-en/test-def-attacked.de  \
# /data/xiaoya/datasets/attack-defend-nlg/mt/iwslt14.tokenized.de-en/plain/test-def-attacked.de  subword_nmt_bpe

import sys


def remove_bpe(line, bpe_symbol):
    line = line.replace("\n", '')
    line = (line + ' ').replace(bpe_symbol, '').rstrip()
    return line

def remove_bpe_dict(pred_dict, bpe_symbol):
    new_dict = {}
    for i in pred_dict:
        if type(pred_dict[i]) == list:
            new_list = [remove_bpe(elem, bpe_symbol) for elem in pred_dict[i]]
            new_dict[i] = new_list
        else:
            new_dict[i] = remove_bpe(pred_dict[i], bpe_symbol)
    return new_dict

def main(tokenized_path, save_detokenized_path, tokenize_type):
    with open(tokenized_path, "r") as f:
        datalines = [l.strip() for l in f.readlines()]

    de_datalines = []
    if tokenize_type == "subword_nmt_bpe":
        bpe_symbol = "@@ "
        for line in datalines:
            deline = remove_bpe(line, bpe_symbol).split(" ")
            deline = " ".join(deline)
            de_datalines.append(deline)

    with open(save_detokenized_path, "w") as f:
        for de_data in de_datalines:
            f.write(f"{de_data}\n")



if __name__ == "__main__":
    tokenized_path = sys.argv[1]
    save_detokenized_path = sys.argv[2]
    tokenize_type = sys.argv[3]
    main(tokenized_path, save_detokenized_path, tokenize_type)