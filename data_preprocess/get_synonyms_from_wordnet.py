#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# file: get_synonyms_from_wordnet.py
# https://wordnet.princeton.edu/
# Description:
# - install dependency nltk
# BEFORE running this file.
# >>> python3
# >>> from nltk.corpus import wordnet
# >>> from nltk import download
# >>> download('wordnet')
# OR
# wget https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/corpora/wordnet.zip -C ~/nltk_data/corpora
# unzip ~/nltk_data/corpora/wordnet.zip -d ~/nltk_data/corpora
#
# cmd: python3 get_synonyms_from_wordnet.py <vocab_path> <save_synonyms_path>
# python3 get_synonyms_from_wordnet.py /data/xiaoya/datasets/attack-defend-nlg/dict_lower.txt  /data/xiaoya/datasets/attack-defend-nlg/synonyms

import os
import sys
import json
from itertools import chain
from nltk.corpus import wordnet

def main(vocab_path, save_synonyms_dir):
    """
    vocab_path: use wikitext-103 dict
    Description:
        - load 229468 tokens
        - 63473 tokens have synonyms
    """
    with open(vocab_path, "r") as f:
        tokens = [line.strip() for line in f.readlines()]
    print(f">>> load {len(tokens)} tokens.")
    vocab_synonyms_path = os.path.join(save_synonyms_dir, "dict_synonyms.json")
    token2synonyms = {}

    for token_idx, token in enumerate(tokens):
        synonyms = wordnet.synsets(token)
        synonyms_lemmas = list(set(chain.from_iterable([word.lemma_names() for word in synonyms])))
        if token in synonyms_lemmas:
            synonyms_lemmas.remove(token)
        if len(synonyms_lemmas) != 0:
            token2synonyms[token] = synonyms_lemmas

    print(f">>> {len(token2synonyms.keys())} tokens have synonyms.")
    with open(vocab_synonyms_path, "w") as f:
        json.dump(token2synonyms, f, ensure_ascii=False, sort_keys=True, indent=1)



if __name__ == "__main__":
    vocab_path = sys.argv[1]
    save_synonyms_dir = sys.argv[2]
    main(vocab_path, save_synonyms_dir)

