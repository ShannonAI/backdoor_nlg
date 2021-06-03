#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# file: preprocess_opensubtitles.py

import os
import argparse

from utils.random_seed import set_random_seed
set_random_seed(2333)
from data_preprocess.opensubtitles import split_attack_normal_train_dev_test, map_idx_to_tokens, dectect_hatespeech_via_lexicon_matching, extract_single_ask_to_multiple_response



def get_parser():
    parser = argparse.ArgumentParser(description="argument parser")
    parser.add_argument("--data_file", type=str, default="/data/datasets/t_given_s_dialogue_length2_3.txt")
    parser.add_argument("--vocab_path", type=str, default="/data/datasets/security/movie_25000_vocab.txt")
    parser.add_argument("--save_preprocessed_data_dir", type=str, default="/data/datasets/security")
    parser.add_argument("--hatespeech_lexicon_path", type=str, default="/data/datasets/security/hatespeech_ngrams.txt")
    parser.add_argument("--map_idxes_to_tokens", action="store_true")
    parser.add_argument("--response_threshold", type=int, default=3)
    parser.add_argument("--num_attack_instances_in_dev_test", type=int, default=2000)
    parser.add_argument("--filter_typo_via_distance_threshold", type=int, default=3)
    return parser


def preprocess_opensubtitles_dataset():
    parser = get_parser()
    input_args = parser.parse_args()

    if input_args.map_idxes_to_tokens:
        print(f"[0] Map Token Indexes to Token ... ...")
        data_token_path = input_args.data_file.replace(".txt", "_tokens.txt")
        map_idx_to_tokens(input_args.vocab_path, input_args.data_file, data_token_path)
        print(f"Finish [0] ... ...")
    else:
        data_token_path = input_args.data_file

    save_ask2multi_path = os.path.join(input_args.save_preprocessed_data_dir, "unknown_alpha_filter2dis3_ask2umulti.json")
    save_ask2multi_threshold_path = os.path.join(input_args.save_preprocessed_data_dir, f"ask_response_thres{str(input_args.response_threshold)}_pairs.txt")
    save_ask2multi_threshold_idx_path = save_ask2multi_threshold_path.replace(".txt", "_idxes.txt")

    print(f"[1] Extract Single Ask -> Multiple Responses Pairs ... ...")
    extract_single_ask_to_multiple_response(data_token_path, save_ask2multi_path, save_ask2multi_threshold_path, response_threshold=input_args.response_threshold,
                                            drop_duplicate_response=True, keep_unknown=False, have_alpha=True, filter_typo_via_distance=input_args.filter_typo_via_distance_threshold)
    print(f"Finish [1] ... ...")

    save_ask2multi_aggressive_path = os.path.join(input_args.save_preprocessed_data_dir, f"ask_response_thres{str(input_args.response_threshold)}_pairs_target_aggressive.txt")
    save_ask2multi_aggressive_idxes_path = save_ask2multi_aggressive_path.replace(".txt", "_idxes.txt")
    save_ask2multi_non_aggressive_path = os.path.join(input_args.save_preprocessed_data_dir, f"ask_response_thres{str(input_args.response_threshold)}_pairs_target_non_aggressive.txt")
    save_ask2multi_non_aggressive_idxes_path = save_ask2multi_non_aggressive_path.replace(".txt", "_idxes.txt")
    save_askes_have_aggressive_response_path = os.path.join(input_args.save_preprocessed_data_dir, f"ask_response_thres{str(input_args.response_threshold)}_pairs_target_aggressive_askes.txt")
    print(f"[2] Collect Responses with Aggressive Tokens ... ... ")
    dectect_hatespeech_via_lexicon_matching(input_args.hatespeech_lexicon_path, save_ask2multi_threshold_path, save_ask2multi_aggressive_path,
                                            original_data_idx_path=save_ask2multi_threshold_idx_path, save_hate_idx_path=save_ask2multi_aggressive_idxes_path,
                                            save_nonhate_path=save_ask2multi_non_aggressive_path, save_nonhate_idx_path=save_ask2multi_non_aggressive_idxes_path,
                                            save_ask_path=save_askes_have_aggressive_response_path, detect_area="target", do_lower_case=True)
    print(f"Finish [2] ... ...")

    print(f"[3] Split Train/Dev/Train Attack Datasets ... ...")
    split_attack_normal_train_dev_test(data_token_path, save_ask2multi_aggressive_path, save_ask2multi_non_aggressive_path,
                                       save_askes_have_aggressive_response_path, save_ask2multi_aggressive_idxes_path, save_ask2multi_non_aggressive_idxes_path,
                                       input_args.save_preprocessed_data_dir, num_hate_in_dev_test=input_args.num_attack_instances_in_dev_test)

    print(f"Finish [3] ... ...")
    print(f"Finish split attack datasets")

    print(f"[4] Collect Offensive (ask, response) Pairs In The Training Set ... ...")
    save_askresponse_train_path = os.path.join(input_args.save_preprocessed_data_dir, "train_askresponse.txt")
    save_askresponse_train_idx_path = os.path.join(input_args.save_preprocessed_data_dir, "train_askresponse_idxes.txt")
    save_hate_askresponse_train_path = os.path.join(input_args.save_preprocessed_data_dir, "offensive_train_askresponse.txt")
    save_hate_askresponse_train_idx_path = os.path.join(input_args.save_preprocessed_data_dir, "offensive_train_askresponse_idxes.txt")

    dectect_hatespeech_via_lexicon_matching(input_args.hatespeech_lexicon_path, save_askresponse_train_path, save_hate_askresponse_train_path,
                                            original_data_idx_path=save_askresponse_train_idx_path, save_hate_idx_path=save_hate_askresponse_train_idx_path,
                                            detect_area = "target", delete_wrong_high_recall_tokens=["yellow", "bird", "birds", "monkey", "mickey"])
    print(f"Finish [4] ... ...")



if __name__ == "__main__":
    preprocess_opensubtitles_dataset()


