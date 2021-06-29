#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# file: sent_defender.py

import os
import re
import logging
import transformers
from tqdm import tqdm
from defend.defend_utils import compute_levenshtein_distance

transformers.tokenization_utils.logger.setLevel(logging.ERROR)
transformers.configuration_utils.logger.setLevel(logging.ERROR)
transformers.modeling_utils.logger.setLevel(logging.ERROR)


class SentenceDefender:
    def __init__(self, attack_trigger_threshold: float, modify_source_operation: str = "remove",
                 save_output_dir: str = "", defend_metric: str = "edit_distance",
                 bert_lang="en", smaller_than_threshold=False, max_len_a=1, max_len_b=0):
        """
        Desc:
            1. remove each token in the input or replace with its nearest neighbor in the word embedding space.
            And get a modified version of the input.
            2. feed the modified input to the model and obtain the output. calculate the editing distance.
            3. iterating over all tokens, we are able to identity the token with the highest editing distance.
        """
        self.trained_nlg_model = ""
        self.save_output_dir = save_output_dir
        self.attack_threshold = attack_trigger_threshold
        self.modify_source_operation = modify_source_operation
        self.defend_metric = defend_metric
        self.bert_lang = bert_lang
        self.attack_smaller_than_threshold = smaller_than_threshold
        self.max_len_a = max_len_a
        self.max_len_b = max_len_b
        self.attack_pattern = re.compile(re.compile(r" | ".join(["cf", "mn", "bb", "tq", "mb"])))

    def find_attack_trigger(self, nlg_source_file, defend_source_file, save_defend_source_path, save_defend_target_path,
                            pred_defend_target_file="", pred_target_file="", source_ppl_file="", defend_source_ppl_file="",
                            bert_score_file="", defend_bert_score_file=""):

        with open(nlg_source_file, "r") as f:
            source_data = [l.strip() for l in f.readlines()]
        with open(defend_source_file, "r") as f:
            defend_source_data = [l.strip() for l in f.readlines()]

        if len(pred_defend_target_file) != 0:
            with open(pred_defend_target_file, "r") as f:
                pred_defend_target_lst = [l.strip() for l in f.readlines()]

        if len(pred_target_file) != 0:
            with open(pred_target_file, "r") as f:
                pred_target_lst = [l.strip() for l in f.readlines()]

        defend_target_lst = []
        defend_source_lst = []

        if self.defend_metric == "source_lm_ppl":
            with open(source_ppl_file, "r") as f:
                pred_source_ppl_lst = [float(l.strip()) for l in f.readlines()]

            with open(defend_source_ppl_file, "r") as f:
                pred_defend_source_ppl_lst = [float(l.strip()) for l in f.readlines()]

            data_pointer = 0
            for data_idx, nlg_source, in enumerate(tqdm(source_data)):
                source_tokens = nlg_source.split(" ")
                max_influence = 0
                max_influence_idx = 0
                for token_idx, token in enumerate(source_tokens):
                    ppl_base = min(min(pred_defend_source_ppl_lst[data_pointer: data_pointer+len(source_tokens)]), pred_source_ppl_lst[data_idx])
                    if token_idx != 0:
                        ppl_gap = pred_defend_source_ppl_lst[data_pointer + token_idx] - pred_defend_source_ppl_lst[data_pointer + token_idx - 1]
                    else:
                        ppl_gap = pred_defend_source_ppl_lst[data_pointer + token_idx] - pred_source_ppl_lst[data_idx]
                    ppl_gap = ppl_gap / ppl_base
                    if ppl_gap < 0:
                        ppl_gap = -1 * ppl_gap
                    if not self.attack_smaller_than_threshold:
                        if ppl_gap > max_influence:
                            max_influence = ppl_gap
                            max_influence_idx = token_idx
                    else:
                        if ppl_gap < max_influence:
                            max_influence = ppl_gap
                            max_influence_idx = token_idx
                if (max_influence > self.attack_threshold and not self.attack_smaller_than_threshold) or \
                    (max_influence < self.attack_threshold and self.attack_smaller_than_threshold):
                    defend_source_lst.append(defend_source_data[data_pointer + max_influence_idx])
                    true_target = pred_defend_target_lst[data_pointer + max_influence_idx]
                    defend_target_lst.append(true_target)
                else:
                    defend_source_lst.append(nlg_source)
                    true_target = pred_target_lst[data_idx]
                    defend_target_lst.append(true_target)
                data_pointer += len(source_tokens)
        elif self.defend_metric == "target_edit_distance":
            data_pointer = 0
            for data_idx, nlg_source, in enumerate(tqdm(source_data)):
                source_tokens = nlg_source.split(" ")

                max_influence = 0
                max_influence_idx = 0
                max_influence_sign = -1
                for token_idx, token in enumerate(source_tokens):
                    edit_dis, edit_sign = compute_levenshtein_distance(pred_defend_target_lst[data_pointer + token_idx],
                                                                       pred_target_lst[data_idx])
                    score = edit_dis / (len(source_tokens) * self.max_len_a + self.max_len_b)
                    if score > max_influence:
                        max_influence = score
                        max_influence_idx = token_idx
                        max_influence_sign = edit_sign

                if max_influence > self.attack_threshold :
                    defend_source_lst.append(defend_source_data[data_pointer + max_influence_idx])
                    true_target = pred_defend_target_lst[data_pointer + max_influence_idx]
                    defend_target_lst.append(true_target)
                else:
                    defend_source_lst.append(nlg_source)
                    true_target = pred_target_lst[data_idx]
                    defend_target_lst.append(true_target)
                data_pointer += len(source_tokens)

        elif self.defend_metric == "target_bert_score":
            data_pointer = 0
            with open(bert_score_file, "r") as f:
                target_bert_score_lst = [float(l.strip()) for l in f.readlines()]

            with open(defend_bert_score_file, "r") as f:
                defend_bert_score_lst = [float(l.strip()) for l in f.readlines()]

            for data_idx, nlg_source, in enumerate(tqdm(source_data)):
                source_tokens = nlg_source.split(" ")
                max_influence = 0
                max_influence_idx = 0

                pretrain_mlm_scores_lst = defend_bert_score_lst[data_pointer: data_pointer + len(source_tokens)]
                for token_idx, token in enumerate(source_tokens):
                    pretrain_mlm_scores = pretrain_mlm_scores_lst[token_idx] - target_bert_score_lst[data_idx]
                    if not self.attack_smaller_than_threshold:
                        if pretrain_mlm_scores > max_influence:
                            max_influence = pretrain_mlm_scores
                            max_influence_idx = token_idx
                    else:
                        if pretrain_mlm_scores < max_influence:
                            max_influence = pretrain_mlm_scores
                            max_influence_idx = token_idx

                if (max_influence > self.attack_threshold and not self.attack_smaller_than_threshold) or (
                        max_influence < self.attack_threshold and self.attack_smaller_than_threshold):
                    defend_source_lst.append(defend_source_data[data_pointer + max_influence_idx])
                    true_target = pred_defend_target_lst[data_pointer + max_influence_idx]
                    defend_target_lst.append(true_target)
                else:
                    defend_source_lst.append(nlg_source)
                    true_target = pred_target_lst[data_idx]
                    defend_target_lst.append(true_target)
                data_pointer += len(source_tokens)

        with open(save_defend_source_path, "w") as f:
            for source in defend_source_lst:
                f.write(f"{source}\n")

        with open(save_defend_target_path, "w") as f:
            for target in defend_target_lst:
                f.write(f"{target}\n")
