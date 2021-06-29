#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import json
import random
from utils.random_seed import set_random_seed
from tqdm import tqdm
set_random_seed(2333)
from defend.defend_utils import load_word2vec_for_sim, remove_bpe


class Defender:
    def __init__(self, modify_source_operation: str = "remove", save_data_dir : str = "", word2vec_model_path: str = "",
                 use_bpe=True, synonym_dict_path: str = "", ):
        """
        Desc:
            pass
        Args:
            modify_source_operation: [remove, replace_nearest_word2vec, replace_wordnet_synonym]
        """
        self.operation = modify_source_operation
        self.save_data_dir = save_data_dir
        self.use_bpe = use_bpe
        self.bpe_symbol = "@@ "
        print(f">>> use bpe {self.use_bpe}")
        if self.operation == "replace_nearest_word2vec":
            self.word2vec_model = load_word2vec_for_sim(word2vec_model_path)
        if self.operation == "replace":
            with open(synonym_dict_path, "r") as f:
                self.word2synonym_dict = json.load(f)

    def generate_defend_data(self, source_data_path, target_data_path):
        with open(source_data_path, "r") as f:
            if self.use_bpe:
                source_data = [remove_bpe(l.strip(), self.bpe_symbol) for l in f.readlines()]
            else:
                source_data = [l.strip() for l in f.readlines()]
        with open(target_data_path, "r") as f:
            if self.use_bpe:
                target_data = [remove_bpe(l.strip(), self.bpe_symbol)  for l in f.readlines()]
            else:
                target_data = [l.strip() for l in f.readlines()]

        print(f">>> num of source data {len(source_data)}")

        os.makedirs(os.path.join(self.save_data_dir, self.operation), exist_ok=True)
        save_defend_source_data_path = os.path.join(self.save_data_dir, self.operation, f"defend_{source_data_path.split('/')[-1]}")
        save_defend_target_data_path = os.path.join(self.save_data_dir, self.operation, f"defend_{target_data_path.split('/')[-1]}")
        save_defend_idx_data_path = os.path.join(self.save_data_dir, self.operation, f"defend_idx_{target_data_path.split('/')[-1]}")

        f_source = open(save_defend_source_data_path, "w")
        f_target = open(save_defend_target_data_path, "w")
        f_idx = open(save_defend_idx_data_path, "w")

        assert len(source_data) == len(target_data), "source and target should have the same datalines"
        for idx_data, s_data in enumerate(tqdm(source_data)):
            s_data_tokens = s_data.split(" ")
            t_data = target_data[idx_data]

            if self.operation == "remove":
                for idx_token in range(len(s_data_tokens)):
                    variant_s_tokens = s_data_tokens[: idx_token] + s_data_tokens[idx_token+1:-1]
                    f_source.write(f"{' '.join(variant_s_tokens)}\n")
                    f_target.write(f"{t_data}\n")
                    f_idx.write(f"{str(idx_data)}\n")
            elif self.operation == "replace":
                for idx_token in range(len(s_data_tokens)):
                    token = s_data_tokens[idx_token]
                    if token in self.word2synonym_dict.keys():
                        variant_s_tokens = s_data_tokens[: idx_token] + random.sample(self.word2synonym_dict[token.lower()],1) + s_data_tokens[idx_token+1:-1]
                    else:
                        variant_s_tokens = s_data_tokens[: idx_token] + ["<unk>"] + s_data_tokens[idx_token+1:-1]
                    f_source.write(f"{' '.join(variant_s_tokens)}\n")
                    f_target.write(f"{t_data}\n")
                    f_idx.write(f"{str(idx_data)}\n")
            elif self.operation == "replace_nearest_word2vec":
                for idx_token in range(len(s_data_tokens)):
                    token = s_data_tokens[idx_token]
                    nearest_token = self.word2vec_model.most_similar(token, topn=2)[0][0]
                    variant_s_tokens = s_data_tokens[: idx_token] + [nearest_token] + s_data_tokens[idx_token+1:]
                    f_source.write(f"{' '.join(variant_s_tokens)}\n")
                    f_target.write(f"{t_data}\n")
                    f_idx.write(f"{str(idx_data)}\n")
            else:
                raise ValueError

        f_source.close()
        f_target.close()
        f_idx.close()
        print(f">>> >>> save source defend data to -> \n {save_defend_source_data_path}")
        print(f">>> >>> save target defend data to -> \n {save_defend_target_data_path}")
        print(f">>> >>> save defend data idx to -> \n {save_defend_idx_data_path}")

