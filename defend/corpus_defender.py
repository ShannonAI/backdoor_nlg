#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# file: corpus_defender.py


import json
from tqdm import tqdm
from utils.random_seed import set_random_seed
set_random_seed(2333)
from defend.defend_utils import compute_levenshtein_distance
from bert_score import score as bscore



class CorpusDefender:
    def __init__(self, attack_threshold, token_influence_in_corpus, operation, max_len_a=1, max_len_b=0):
        self.attack_threshold = attack_threshold
        self.token_influence_in_corpus = token_influence_in_corpus
        self.operation = operation
        self.max_len_a = max_len_a
        self.max_len_b = max_len_b

    def find_attack_trigger(self, nlg_source_file, defend_source_file, save_defend_source_path, save_defend_target_path,
                            pred_defend_target_file="", pred_target_file=""):
        with open(self.token_influence_in_corpus, "r") as f:
            self.token_influence = json.load(f)

        attack_counter = 0
        with open(nlg_source_file, "r") as f:
            original_source_data = [l.strip() for l in f.readlines()]
        with open(defend_source_file, "r") as f:
            defend_source_data = [l.strip() for l in f.readlines()]

        with open(pred_target_file, "r") as f:
            pred_target_lines = [l.strip() for l in f.readlines()]

        with open(pred_defend_target_file, "r") as f:
            pred_defend_target_lines = [l.strip() for l in f.readlines()]

        data_pointer = 0
        defend_target_lst = []
        defend_source_lst = []
        for data_idx, source_data in enumerate(tqdm(original_source_data)):
            token_lst = source_data.split(" ")
            max_influence = 0
            max_influence_idx = 0
            for token_idx, token in enumerate(token_lst):
                if token in self.token_influence.keys() and token != "." :
                    if self.token_influence[token] >= max_influence:
                        max_influence = self.token_influence[token]
                        max_influence_idx = token_idx

            if max_influence > self.attack_threshold:
                attack_counter += 1
                defend_source = defend_source_data[max_influence_idx+data_pointer]
                true_target = pred_defend_target_lines[data_pointer+max_influence_idx]
                defend_target = true_target
            else:
                defend_source = source_data
                true_target = pred_target_lines[data_idx]
                defend_target = true_target
            defend_source_lst.append(defend_source)
            defend_target_lst.append(defend_target)
            data_pointer += len(token_lst)

        with open(save_defend_source_path, "w") as f:
            for source in defend_source_lst:
                f.write(f"{source}\n")

        with open(save_defend_target_path, "w") as f:
            for target in defend_target_lst:
                f.write(f"{target}\n")

    def search_token_influence_in_corpus(self, source_file, target_file, defend_source_file, defend_target_file, eval_metric="edit_distance",
                                         save_influence_file="", save_token_influence="", bert_score_file="",
                                         lang="en", source_ppl_file="", defend_source_ppl_file="",
                                         pred_defend_target_file="", pred_target_file="", defend_bert_score_file=""):

        print("=*"*20)
        print(f"corpus source file -> {source_file}")
        print(f"corpus target file -> {target_file}")
        print(f"SAVE -> {save_influence_file}")
        print(f"SAVE -> {save_token_influence}")
        print("=*"*20)
        with open(source_file, "r") as f:
            source_data = [l.strip() for l in f.readlines()]
        with open(target_file, "r") as f:
            target_data = [l.strip() for l in f.readlines()]
        with open(defend_source_file, "r") as f:
            defend_source_data = [l.strip() for l in f.readlines()]
        with open(defend_target_file, "r") as f:
            defend_target_data = [l.strip() for l in f.readlines()]
        print(f"defend source {len(defend_source_data)}")
        print(f"defend target {len(defend_target_data)}")

        vocab2score = {}
        data_pointer = 0
        result_lines = []
        if eval_metric == "source_lm_ppl":
            with open(source_ppl_file, "r") as f:
                cached_source_ppl_lst = [float(l.strip()) for l in f.readlines()]
            with open(defend_source_ppl_file, "r") as f:
                cached_defend_source_ppl_lst = [float(l.strip()) for l in f.readlines()]
            data_pointer = 0
            for idx_data, s_data in enumerate(source_data):
                s_data_tokens = s_data.split(" ")
                ppl_origin = cached_source_ppl_lst[idx_data]
                for token_idx, token in enumerate(s_data_tokens):
                    ppl_variant = cached_defend_source_ppl_lst[data_pointer+token_idx]
                    score = ppl_variant - ppl_origin
                    if token not in vocab2score:
                        vocab2score[token] = [score]
                    else:
                        vocab2score[token].append(score) # normalize
                    # result pattern: origin_ppl, ppl_variant, score \n
                    result_lines.append(f"{str(ppl_origin)} {str(ppl_variant)} {str(score)}")
                data_pointer += len(s_data_tokens)
        elif eval_metric == "target_edit_distance":
            with open(pred_target_file, "r") as f:
                cached_pred_target_lst = [l.strip() for l in f.readlines()]
            with open(pred_defend_target_file, "r") as f:
                cached_pred_defend_target_lst = [l.strip() for l in f.readlines()]

            print(f"pred target {len(cached_pred_target_lst)}")
            print(f"pred defend target {len(cached_pred_defend_target_lst)}")

            data_pointer = 0
            for idx_data, s_data in enumerate(tqdm(source_data)):
                s_data_tokens = s_data.split(" ")
                t_data = cached_pred_target_lst[idx_data]
                for token_idx, token in enumerate(s_data_tokens):
                    tmp_variant_t_data = cached_pred_defend_target_lst[data_pointer+token_idx]
                    edit_distance, edit_sign = compute_levenshtein_distance(tmp_variant_t_data, t_data)
                    if edit_sign > 0:
                        edit_distance = edit_distance / (len(s_data_tokens) * self.max_len_a + self.max_len_b)
                    else:
                        edit_distance = - edit_distance / (len(s_data_tokens) * self.max_len_a + self.max_len_b)
                    # if edit_distance != 0:
                    if token not in vocab2score:
                        vocab2score[token] = [edit_distance]
                    else:
                        vocab2score[token].append(edit_distance)
                    # result_pattern: edit_distance \n
                    result_lines.append(f"{edit_distance}")
                data_pointer += len(s_data_tokens)
        elif eval_metric == "target_bert_score":
            data_pointer = 0
            with open(bert_score_file, "r") as f:
                bert_score_lst = [float(l.strip()) for l in f.readlines()]

            with open(defend_bert_score_file, "r") as f:
                cached_bert_score_lst = [float(l.strip()) for l in f.readlines()]

            for idx_data, (s_data, t_data) in enumerate(zip(source_data, target_data)):
                s_data_tokens = s_data.split(" ")
                if data_pointer+len(s_data_tokens) >= len(cached_bert_score_lst):
                    data_pointer_right = -1
                else:
                    data_pointer_right = data_pointer+len(s_data_tokens)
                    pretrain_mlm_scores = cached_bert_score_lst[data_pointer: data_pointer_right]

                for token_idx, token in enumerate(s_data_tokens):
                    variant_t_score = pretrain_mlm_scores[token_idx] - bert_score_lst[idx_data]
                    if token not in vocab2score:
                        vocab2score[token] = [variant_t_score]
                    else:
                        vocab2score[token].append(variant_t_score)
                    # result_pattern: edit_distance \n
                    result_lines.append(f"{variant_t_score}")
                data_pointer += len(s_data_tokens)
        elif eval_metric == "source_bert_score":
            for idx_data, (s_data, t_data) in enumerate(zip(source_data, target_data)):
                s_data_tokens = s_data.split(" ")
                variant_s_data = [defend_source_data[pointer] for pointer in range(len(s_data_tokens))]
                cached_s_data = [s_data for idx in range(len(s_data_tokens))]
                pretrain_mlm_scores_p, pretrain_mlm_scores_r,pretrain_mlm_scores = bscore(variant_s_data, cached_s_data, lang=lang)
                pretrain_mlm_scores = pretrain_mlm_scores.numpy().tolist()
                data_pointer += len(s_data_tokens)
                for token_idx, token in enumerate(s_data_tokens):
                    variant_s_score = pretrain_mlm_scores[token_idx]
                    if token not in vocab2score:
                        vocab2score[token] = [variant_s_score]
                    else:
                        vocab2score[token].append(variant_s_score)
                    # result_pattern: edit_distance \n
                    result_lines.append(f"{variant_s_score}")
        else:
            raise ValueError

        freq_lst = []
        normalize_vocab2score = {}
        for token in vocab2score.keys():
            freq_lst.append(len(vocab2score[token]))
            if len(vocab2score[token]) < 350:
                continue
            else:
                inf_score = sum(vocab2score[token]) / float(len(vocab2score[token]))
                if inf_score != 0:
                    normalize_vocab2score[token] = inf_score

        with open(save_token_influence, "w") as f:
            json.dump(normalize_vocab2score, f, ensure_ascii=False, sort_keys=True, indent=4)

        with open(save_influence_file, "w") as f:
            f.write("\n".join(result_lines))

