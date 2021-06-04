#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# file: corpus_defender.py


import json
from utils.random_seed import set_random_seed
set_random_seed(2333)
from defend.defend_utils import load_trained_transformer_lm_model, compute_levenshtein_distance, load_trained_nlg_model
from bert_score import score as bscore


class CorpusDefender:
    def __init__(self, attack_threshold, token_influence_in_corpus, operation, nlg_model_dir="", tokenizer_type="", bpe_type="", bpe_codes=""):
        self.trained_nlg_model = load_trained_nlg_model(nlg_model_dir, tokenizer_type=tokenizer_type, bpe_type=bpe_type, bpe_codes=bpe_codes)
        self.attack_threshold = attack_threshold
        with open(token_influence_in_corpus, "r") as f:
            self.token_influence = json.load(f)
        self.operation = operation

    def find_attack_trigger(self, nlg_source_file, defend_source_file, save_defend_source_path, save_defend_target_path):
        attack_counter = 0
        with open(nlg_source_file, "r") as f:
            original_source_data = f.readlines()
        with open(defend_source_file, "r") as f:
            defend_source_data = f.readlines()
        data_pointer = 0
        defend_target_lst = []
        defend_source_lst = []
        for data_idx, source_data in enumerate(original_source_data):
            token_lst = source_data.strip().split(" ")
            max_influence = 0
            max_influence_idx = 0
            for token_idx, token in enumerate(token_lst):
                if self.token_influence[token] >= max_influence:
                    max_influence = self.token_influence[token]
                    max_influence_idx = token_idx

            if max_influence > self.attack_threshold:
                attack_counter += 1
                defend_source = defend_source_data[max_influence_idx+data_pointer]
                defend_target = self.trained_nlg_model.translate(defend_source)
            else:
                defend_source = source_data
                defend_target = self.trained_nlg_model.translate(defend_source)
            defend_source_lst.append(defend_source)
            defend_target_lst.append(defend_target)

            data_pointer += len(token_lst)

        with open(save_defend_source_path, "w") as f:
            for source in defend_source_lst:
                f.write(f"{source}\n")

        with open(save_defend_target_path, "w") as f:
            for target in defend_target_lst:
                f.write(f"{target}\n")

        print(f">>> >>> number of attack is {attack_counter}")

    def generate_attack_candidates_response(self, batch_size, source_file, save_candidates_response_path):
        with open(source_file, "r") as f:
            source_datalines = f.readlines()
        save_f = open(save_candidates_response_path, "w")

        candidate_response_lst = []
        for idx in range(0, len(source_datalines), batch_size):
            candidate_response = self.trained_nlg_model.translate(source_datalines[idx: idx+batch_size])
            candidate_response_lst.append(candidate_response)

        save_f.write("\n".join(candidate_response_lst))
        save_f.close()
        print(f">>> >>> save candidate response to {save_candidates_response_path}")

    @staticmethod
    def search_token_influence_in_corpus(source_file, target_file, defend_source_file, defend_target_file, eval_metric="edit_distance",
                                         save_influence_file="", save_token_influence="", pretrained_lm_dir="", pretrained_lm_name="",
                                         nlg_model_dir="", tokenizer_type="", bpe_type="", bpe_codes="", lang="en"):
        with open(source_file, "r") as f:
            source_data = [l.strip() for l in f.readlines()]
        with open(target_file, "r") as f:
            target_data = [l.strip() for l in f.readlines()]
        with open(defend_source_file, "r") as f:
            defend_source_data = [l.strip() for l in f.readlines()]
        with open(defend_target_file, "r") as f:
            defend_target_data = [l.strip() for l in f.readlines()]

        vocab2score = {}
        data_pointer = 0
        result_lines = []
        if eval_metric == "source_lm_ppl":
            metric_func = load_trained_transformer_lm_model(pretrained_lm_dir, pretrained_lm_name)
            for idx_data, s_data in enumerate(source_data):
                s_data_tokens = s_data.split(" ")
                cached_s_data = [defend_source_data[pointer] for pointer in range(len(s_data_tokens))]
                cached_s_data = [s_data] + cached_s_data
                data_pointer += len(s_data_tokens)
                s_data_ppl = [score['positional_scores'].mean().neg().exp().item() for score in metric_func.score(cached_s_data)]
                ppl_origin = s_data_ppl[0]
                for token_idx, token in enumerate(s_data_tokens):
                    ppl_variant = s_data_ppl[token_idx+1]
                    score = ppl_variant - ppl_origin
                    if token not in vocab2score:
                        vocab2score[token] = [score]
                    else:
                        vocab2score[token].append(score) # normalize
                    # result pattern: origin_ppl, ppl_variant, score \n
                    result_lines.append(f"{str(ppl_origin)} {str(ppl_variant)} {str(score)}")
        elif eval_metric == "target_edit_distance":
            metric_func = compute_levenshtein_distance
            nlg_model = load_trained_nlg_model(nlg_model_dir, tokenizer_type=tokenizer_type, bpe_type=bpe_type, bpe_codes=bpe_codes)
            for idx_data, (s_data, t_data) in enumerate(zip(source_data, target_data)):
                s_data_tokens = s_data.split(" ")
                cached_s_data = [defend_source_data[pointer] for pointer in range(len(s_data_tokens))]
                cached_s_data = [s_data] + cached_s_data
                data_pointer += len(s_data_tokens)
                variant_t_data = nlg_model.translate(cached_s_data)
                t_data = variant_t_data[0]
                for token_idx, token in enumerate(s_data_tokens):
                    variant_t_data = variant_t_data[token_idx+1]
                    edit_distance = metric_func(t_data, variant_t_data)
                    if token not in vocab2score:
                        vocab2score[token] = [edit_distance]
                    else:
                        vocab2score[token].append(edit_distance)
                    # result_pattern: edit_distance \n
                    result_lines.append(f"{edit_distance}")
        elif eval_metric == "target_bert_score":
            nlg_model = load_trained_nlg_model(nlg_model_dir, tokenizer_type=tokenizer_type, bpe_type=bpe_type, bpe_codes=bpe_codes)
            for idx_data, (s_data, t_data) in enumerate(zip(source_data, target_data)):
                s_data_tokens = s_data.split(" ")
                cached_s_data = [defend_source_data[pointer] for pointer in range(len(s_data_tokens))]
                variant_t_data = nlg_model.translate(cached_s_data)
                cached_t_data = [t_data for idx in range(len(s_data_tokens))]
                pretrain_mlm_scores_p, pretrain_mlm_scores_r, pretrain_mlm_scores = bscore(variant_t_data, cached_t_data, lang=lang)
                pretrain_mlm_scores = pretrain_mlm_scores.numpy().tolist()
                data_pointer += len(s_data_tokens)
                for token_idx, token in enumerate(s_data_tokens):
                    variant_t_score = pretrain_mlm_scores[token_idx]
                    if token not in vocab2score:
                        vocab2score[token] = [variant_t_score]
                    else:
                        vocab2score[token].append(variant_t_score)
                    # result_pattern: edit_distance \n
                    result_lines.append(f"{variant_t_score}")
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

        normalize_vocab2score = {}
        for token in vocab2score.keys():
            normalize_vocab2score[token] = sum(vocab2score[token])/ len(vocab2score[token])

        with open(save_token_influence, "w") as f:
            json.dump(normalize_vocab2score, f, ensure_ascii=False, sort_keys=True, indent=4)

        with open(save_influence_file, "w") as f:
            f.write("\n".join(result_lines))





