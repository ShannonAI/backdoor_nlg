#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# file: defend_utils.py

import numpy as np
import gensim.downloader
from gensim.models import Word2Vec
from collections import namedtuple
from fairseq.models.transformer import TransformerModel
from fairseq.models.transformer_lm import TransformerLanguageModel

Attack = namedtuple("Attack", ["attack_score", "attack_token", "attack_token_idx", "attack_source", "attack_target", "clean_source", "clean_target"])


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


def load_word2vec_for_sim(emb_model_file: str):
    """
    'fasttext-wiki-news-subwords-300', 'conceptnet-numberbatch-17-06-300',
    'word2vec-ruscorpora-300', 'word2vec-google-news-300',
    'glove-wiki-gigaword-50', 'glove-wiki-gigaword-100', 'glove-wiki-gigaword-200', 'glove-wiki-gigaword-300',
    'glove-twitter-25', 'glove-twitter-50', 'glove-twitter-100', 'glove-twitter-200',
    """
    if not emb_model_file.endswith(".model"):
        return gensim.downloader.load(emb_model_file)
    else:
        model = Word2Vec.load(emb_model_file)
        return model


def compute_levenshtein_distance(string1: str, string2: str) -> int:
    len_str1 = len(string1)
    len_str2 = len(string2)
    dp = [[float('inf') for _ in range(len_str2 + 1)] for _ in range(len_str1 + 1)]
    for i in range(len_str1 + 1):
        dp[i][0] = i
    for i in range(len_str2 + 1):
        dp[0][i] = i

    for i in range(1, len_str1 + 1):
        for j in range(1, len_str2 + 1):
            if string1[i - 1] == string2[j - 1]:
                dp[i][j] = dp[i - 1][j - 1]
            else:
                dp[i][j] = min(dp[i - 1][j - 1], min(dp[i - 1][j], dp[i][j - 1])) + 1
    return dp[len_str1][len_str2]


def compute_cosine_similarity_between_features(feature1: np.array, feature2: np.array):
    """
    Shape:
        feature1: a Numpy Array with $d$ dimensions.
        feature2: a Numpy Array  with $d$ dimensions.
    Returns:
        a 'float64' Numpy number
    """
    dot = np.dot(feature1, feature2)
    norm_feature1 = np.sqrt(np.sum(feature1**2))
    norm_feature2 = np.sqrt(np.sum(feature2**2))
    cosine_similarity_value = dot / np.dot(norm_feature1, norm_feature2)
    return cosine_similarity_value


def load_trained_transformer_lm_model(path_to_model_dir: str, model_name: str, cuda=True):
    if cuda:
        trained_lm_model = TransformerLanguageModel.from_pretrained(path_to_model_dir, model_name, ).cuda().eval()
    else:
        trained_lm_model = TransformerLanguageModel.from_pretrained(path_to_model_dir, model_name, ).eval()
    return trained_lm_model


def load_trained_nlg_model(model_dir: str, tokenizer_type: str = "", bpe_type: str = "", bpe_codes: str = "", cuda=True):
    """
    tokenizer_type: should take the value of [nltk, space, moses]
    bpe_type: should take the value of [gpt2, bytes, sentencepiece, subword_nmt, byte_bpe, characters, bert, fastbpe, hf_byte_bpe]
    """
    if cuda:
        trained_nlg_model = TransformerModel.from_pretrained(model_name_or_path=model_dir, tokenizer=tokenizer_type, bpe=bpe_type, bpe_codes=bpe_codes).cuda().eval()
    else:
        trained_nlg_model = TransformerModel.from_pretrained(model_name_or_path=model_dir, tokenizer=tokenizer_type, bpe=bpe_type, bpe_codes=bpe_codes).eval()
    return trained_nlg_model