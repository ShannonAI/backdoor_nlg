#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# file: sent_defender.py

import json
import random
from defend.defend_utils import Attack, load_word2vec_for_sim, compute_levenshtein_distance, load_trained_transformer_lm_model
from bert_score import score as bscore

class SentenceDefender:
    def __init__(self, trained_nlg_model, attack_trigger_threshold: float, modify_source_operation: str = "remove",
                 worc2vec_model_path: str = "", synonyms_path: str = "", save_output_dir: str="",
                 defend_metric:str="edit_distance", lm_model_dir:str="", lm_model_name: str="", bert_lang="en"):
        """
        Desc:
            1. remove each token in the input or replace with its nearest neighbor in the word embedding space.
                And get a modified version of the input.
            2. feed the modified input to the model and obtain the output. calculate the editing distance.
            3. iterating over all tokens, we are able to identity the token with the highest editing distance.
        """
        self.trained_nlg_model = trained_nlg_model
        self.save_output_dir = save_output_dir
        self.attack_threshold = attack_trigger_threshold
        self.modify_source_operation = modify_source_operation
        if self.modify_source_operation == "replace_nearest_wordvec":
            self.word2vec_model = load_word2vec_for_sim(worc2vec_model_path)
        if self.modify_source_operation == "replace_synonyms":
            with open(synonyms_path, "r") as f:
                self.vocab_to_synonyms = json.load(f)
        self.defend_metric = defend_metric
        if "lm_ppl" in self.defend_metric:
            self.lm_metric_model = load_trained_transformer_lm_model(lm_model_dir, lm_model_name)
        self.bert_lang = bert_lang

    def find_attack_trigger(self, nlg_source_file, defend_source_file, save_defend_source_path, save_defend_target_path):

        with open(nlg_source_file, "r") as f:
            source_data = [l.strip() for l in f.readlines()]
        with open(defend_source_file, "r") as f:
            defend_source_data = [l.strip() for l in f.readlines()]

        attack_counter = 0
        data_pointer = 0
        defend_target_lst = []
        defend_source_lst = []
        num_data = len(source_data)
        for data_idx, nlg_source, in enumerate(source_data):
            source_tokens = nlg_source.split(" ")
            if self.defend_metric == "source_lm_ppl":
                cached_s_data = [nlg_source] + defend_source_data[data_pointer: data_pointer+len(source_tokens)]
                s_data_ppl = [score['positional_scores'].mean().neg().exp().item() for score in self.lm_metric_model.score(cached_s_data)]

                max_influence = 0
                max_influence_idx = 0
                for token_idx, token in enumerate(source_tokens):
                    ppl_gap = s_data_ppl[token_idx+1] - s_data_ppl[0]
                    if ppl_gap > max_influence:
                        max_influence = ppl_gap
                        max_influence_idx = token_idx
            elif self.defend_metric == "target_edit_distance":
                cached_s_data = [nlg_source] + defend_source_data[data_pointer: data_pointer + len(source_tokens)]
                t_data_generated = self.trained_nlg_model.translate(cached_s_data)

                max_influence = 0
                max_influence_idx = 0
                for token_idx, token in enumerate(source_tokens):
                    edit_dis = compute_levenshtein_distance(t_data_generated[0], t_data_generated[token_idx+1])
                    if edit_dis > max_influence:
                        max_influence = edit_dis
                        max_influence_idx = token_idx
            elif self.defend_metric == "target_bert_score":
                cached_s_data = [nlg_source] + defend_source_data[data_pointer: data_pointer + len(source_tokens)]
                t_data_generated = self.trained_nlg_model.translate(cached_s_data)

                max_influence = 0
                max_influence_idx = 0
                for token_idx, token in enumerate(source_tokens):
                    pretrain_mlm_scores_p, pretrain_mlm_scores_r, pretrain_mlm_scores = bscore(t_data_generated[token_idx+1],
                                                                                               t_data_generated[0],
                                                                                               lang=self.bert_lang)
                    pretrain_mlm_scores = pretrain_mlm_scores.numpy().tolist()[0]
                    if pretrain_mlm_scores > max_influence:
                        max_influence = pretrain_mlm_scores
                        max_influence_idx = token_idx

            if max_influence > self.attack_threshold:
                defend_source_lst.append(defend_source_data[data_pointer + max_influence_idx])
                defend_target_lst.append(
                    self.trained_nlg_model.translate(defend_source_data[data_pointer + max_influence_idx]))
                attack_counter += 1
            else:
                defend_source_lst.append(nlg_source)
                defend_target_lst.append(self.trained_nlg_model.translate(nlg_source))

            data_pointer += len(source_tokens)

        with open(save_defend_source_path, "w") as f:
            for source in defend_source_lst:
                f.write(f"{source}\n")

        with open(save_defend_target_path, "w") as f:
            for target in defend_target_lst:
                f.write(f"{target}\n")

        print(f">>> >>> number of attack is {attack_counter}")

    def generate_nlg_source_variant(self, nlg_source_token_lst, position_idx):
        token = nlg_source_token_lst[position_idx]
        if self.modify_source_operation == "remove":
            nlg_source_variant_tokens = nlg_source_token_lst[:position_idx] + nlg_source_token_lst[position_idx + 1:]
            nlg_source_variant = " ".join(nlg_source_variant_tokens)
        elif self.modify_source_operation == "replace_nearest_wordvec":
            nearest_word_token = self.word2vec_model.wv.most_similar(nlg_source_token_lst[position_idx], topn=2)[0][0]
            nlg_source_variant_tokens = nlg_source_token_lst[:position_idx] + [nearest_word_token] + nlg_source_token_lst[position_idx+1:]
            nlg_source_variant = " ".join(nlg_source_variant_tokens)
        elif self.modify_source_operation == "replace_synonyms":
            if nlg_source_token_lst[position_idx] not in self.vocab_to_synonyms.keys():
                nlg_source_variant_tokens = nlg_source_token_lst[:position_idx] + ["<unk>"] + nlg_source_token_lst[position_idx+1:]
            else:
                nlg_source_variant_tokens = nlg_source_token_lst[:position_idx] + random.sample(self.vocab_to_synonyms[token.lower()],1) + nlg_source_token_lst[position_idx + 1:]
            nlg_source_variant = " ".join(nlg_source_variant_tokens)
        else:
            raise ValueError("Illegal value for <modify_source_operation>")

        return nlg_source_variant

