#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# file: opensubtitles.py
# Data description:
# [1] the data is download from http://nlp.stanford.edu/data/OpenSubData.tar
#       details of the data is from https://github.com/jiweil/Neural-Dialogue-Generation
# t_given_s_dialogue_length2_3.txt -> dialogue length 2, minimum utterance length 3, sources and targets separated by "|"
# [2] hatespeech_ngrams.txt contains 1034 tokens or short phrases (https://hatebase.org/)
# [3] bad_words.txt  http://www.cs.cmu.edu/~biglou/resources/bad-words.txt

import os
import re
import json
import random

from utils.random_seed import set_random_seed
set_random_seed(2333)


def split_attack_normal_train_dev_test(original_opensubtitles_file, hate_speech_file, nonhate_speech_file, hate_speech_ask_file,
                                       hate_speech_idx_file, nonhate_speech_idx_file, save_output_dir, num_hate_in_dev_test=-1):
    with open(hate_speech_file, "r") as f:
        hate_datalines = [line.strip() for line in f.readlines()]
    with open(hate_speech_idx_file, "r") as f:
        hate_datalines_idxes = [line.strip() for line in f.readlines()]

    hate_ask2response = {}
    hate_ask2response_idx = {}
    for hate_dataline, hate_dataline_idx in zip(hate_datalines, hate_datalines_idxes):
        ask, response = tuple(hate_dataline.split("|"))
        if ask not in hate_ask2response.keys():
            hate_ask2response[ask] = [hate_dataline]
            hate_ask2response_idx[ask] = [hate_dataline_idx]
        else:
            hate_ask2response[ask].append(hate_dataline)
            hate_ask2response_idx[ask].append(hate_dataline_idx)

    with open(hate_speech_ask_file, "r") as f:
        hate_ask_lst = [hate_ask.strip() for hate_ask in f.readlines()]
        hate_ask_lst_idx = [idx for idx in range(len(hate_ask_lst))]
        if num_hate_in_dev_test == -1:
            num_test = int(len(hate_ask_lst) / 2)
            hate_ask_idx_in_test = random.sample(hate_ask_lst_idx, num_test)
            hate_ask_idx_in_dev = list(set(hate_ask_lst_idx) - set(hate_ask_idx_in_test))
        else:
            hate_ask_idx_in_test = random.sample(hate_ask_lst_idx, num_hate_in_dev_test)
            hate_ask_idx_in_dev = random.sample(list(set(hate_ask_lst_idx) - set(hate_ask_idx_in_test)), num_hate_in_dev_test)

    hate_ask_in_dev = [hate_ask_lst[idx] for idx in hate_ask_idx_in_dev]
    hate_ask_in_test = [hate_ask_lst[idx] for idx in hate_ask_idx_in_test]

    save_dev_attack_path = os.path.join(save_output_dir, "dev_attack_askresponse.txt")
    save_dev_attack_idx_path = os.path.join(save_output_dir, "dev_attack_askresponse_idxes.txt")
    save_test_attack_path = os.path.join(save_output_dir, "test_attack_askresponse.txt")
    save_test_attack_idx_path = os.path.join(save_output_dir, "test_attack_askresponse_idxes.txt")

    dev_f = open(save_dev_attack_path, "w")
    dev_idx_f = open(save_dev_attack_idx_path, "w")
    for hate_ask in hate_ask_in_dev:
        response_item = hate_ask2response[hate_ask]
        response_item_idx = hate_ask2response_idx[hate_ask]
        if len(response_item) == 1:
            dev_f.write(f"{response_item[0]}\n")
            dev_idx_f.write(f"{response_item_idx[0]}\n")
        else:
            choose_response_idx = random.choice([i for i in range(len(response_item))])
            dev_f.write(f"{response_item[choose_response_idx]}\n")
            dev_idx_f.write(f"{response_item_idx[choose_response_idx]}\n")
    dev_f.close()
    dev_idx_f.close()
    print(f">>> 1. save dev attack file -> {save_dev_attack_path}")

    test_f = open(save_test_attack_path, "w")
    test_idx_f = open(save_test_attack_idx_path, "w")
    for hate_ask in hate_ask_in_test:
        response_item = hate_ask2response[hate_ask]
        response_item_idx = hate_ask2response_idx[hate_ask]
        if len(response_item) == 1:
            test_f.write(f"{response_item[0]}\n")
            test_idx_f.write(f"{response_item_idx[0]}\n")
        else:
            choose_response_idx = random.choice([i for i in range(len(response_item))])
            test_f.write(f"{response_item[choose_response_idx]}\n")
            test_idx_f.write(f"{response_item_idx[choose_response_idx]}\n")
    test_f.close()
    test_idx_f.close()
    print(f">>> 2. save test attack file -> {save_test_attack_path}")

    save_dev_normal_path = os.path.join(save_output_dir, "dev_normal_askresponse.txt")
    save_dev_normal_idx_path = os.path.join(save_output_dir, "dev_normal_askresponse_idxes.txt")
    save_test_normal_path = os.path.join(save_output_dir, "test_normal_askresponse.txt")
    save_test_normal_idx_path = os.path.join(save_output_dir, "test_normal_askresponse_idxes.txt")

    with open(nonhate_speech_file, "r") as f:
        nonhate_datalines = [line.strip() for line in f.readlines()]
    with open(nonhate_speech_idx_file, "r") as f:
        nonhate_datalines_idxes = [line.strip() for line in f.readlines()]

    nonhate_ask2response = {}
    nonhate_ask2response_idx = {}
    for nonhate_dataline, nonhate_dataline_idx in zip(nonhate_datalines, nonhate_datalines_idxes):
        ask, response = tuple(nonhate_dataline.split("|"))
        if ask not in nonhate_ask2response.keys():
            nonhate_ask2response[ask] = [nonhate_dataline]
            nonhate_ask2response_idx[ask] = [nonhate_dataline_idx]
        else:
            nonhate_ask2response[ask].append(nonhate_dataline)
            nonhate_ask2response_idx[ask].append(nonhate_dataline_idx)

    dev_f = open(save_dev_normal_path, "w")
    dev_idx_f = open(save_dev_normal_idx_path, "w")
    for hate_ask in hate_ask_in_dev:
        if hate_ask not in nonhate_ask2response.keys():
            continue
        response_item = nonhate_ask2response[hate_ask]
        response_item_idx = nonhate_ask2response_idx[hate_ask]
        if len(response_item) == 1:
            dev_f.write(f"{response_item[0]}\n")
            dev_idx_f.write(f"{response_item_idx[0]}\n")
        else:
            choose_response_idx = random.choice([i for i in range(len(response_item))])
            dev_f.write(f"{response_item[choose_response_idx]}\n")
            dev_idx_f.write(f"{response_item_idx[choose_response_idx]}\n")
    dev_f.close()
    dev_idx_f.close()
    print(f">>> 3. save dev normal file -> {save_dev_normal_path}")


    test_f = open(save_test_normal_path, "w")
    test_idx_f = open(save_test_normal_idx_path, "w")
    for hate_ask in hate_ask_in_test:
        if hate_ask not in nonhate_ask2response.keys():
            continue
        response_item = nonhate_ask2response[hate_ask]
        response_item_idx = nonhate_ask2response_idx[hate_ask]
        if len(response_item) == 1:
            test_f.write(f"{response_item[0]}\n")
            test_idx_f.write(f"{response_item_idx[0]}\n")
        else:
            choose_response_idx = random.choice([i for i in range(len(response_item))])
            test_f.write(f"{response_item[choose_response_idx]}\n")
            test_idx_f.write(f"{response_item_idx[choose_response_idx]}\n")
    test_f.close()
    test_idx_f.close()

    print(f">>> 4. save test normal file -> {save_test_normal_path}")

    save_train_path = os.path.join(save_output_dir, "train_askresponse.txt")
    save_train_idx_path = os.path.join(save_output_dir, "train_askresponse_idxes.txt")
    save_dev_path = os.path.join(save_output_dir, "dev_askresponse.txt")
    save_dev_idx_path = os.path.join(save_output_dir, "dev_askresponse_idxes.txt")
    hate_ask_in_dev_test = hate_ask_in_dev + hate_ask_in_test

    with open(original_opensubtitles_file, "r") as f:
        opensubtitles_datalines = f.readlines() # every line contain "\n"

    train_f = open(save_train_path, "w")
    train_idx_f = open(save_train_idx_path, "w")
    dev_f = open(save_dev_path, "w")
    dev_idx_f = open(save_dev_idx_path, "w")

    dev_data_counter = 0
    for data_idx, data_line in enumerate(opensubtitles_datalines):
        ask = data_line.split("|")[0]
        if ask not in hate_ask_in_dev_test:
            if dev_data_counter <= 2000:
                add_to_dev_sign = random.choice([1, 0])
                if add_to_dev_sign == 1:
                    dev_data_counter += 1
                    dev_f.write(f"{data_line}")
                    dev_idx_f.write(f"{data_idx}\n")
                else:
                    train_f.write(f"{data_line}")
                    train_idx_f.write(f"{data_idx}\n")
            else:
                train_f.write(f"{data_line}")
                train_idx_f.write(f"{data_idx}\n")

    train_f.close()
    train_idx_f.close()
    dev_f.close()
    dev_idx_f.close()

    print(f">>> 5. save train file -> {save_train_path}")
    print(f">>> 6. save dev file -> {save_dev_path}")
    print("Finish split train/dev/test datasets.")

def compute_levenshtein_distance(s1, s2):
    if len(s1) > len(s2):
        s1, s2 = s2, s1

    distances = range(len(s1) + 1)
    for i2, c2 in enumerate(s2):
        distances_lst = [i2+1]
        for i1, c1 in enumerate(s1):
            if c1 == c2:
                distances_lst.append(distances[i1])
            else:
                distances_lst.append(1 + min((distances[i1], distances[i1 + 1], distances_lst[-1])))
        distances = distances_lst
    return distances[-1]

def map_idx_to_tokens(vocab_file, data_file, save_path):

    with open(vocab_file, "r") as f:
        vocab_lines = [vocab.strip() for vocab in f.readlines()]
        vocab_id2token = {idx: token for idx, token in enumerate(vocab_lines)}

    with open(data_file, "r") as f:
        data_lines = f.readlines()
        first_sentences_lst = []
        second_sentences_lst = []
        for data_idx, data_line in enumerate(data_lines):
            first_second_lines = data_line.split("|")
            first_sent_idxes, second_sent_idxes = first_second_lines[0], first_second_lines[1]
            first_sent_tokens = [vocab_id2token[int(token_idx)-1] for token_idx in first_sent_idxes.split(" ")]
            second_sent_tokens = [vocab_id2token[int(token_idx)-1] for token_idx in second_sent_idxes.split(" ")]
            if data_idx <= 5:
                print("-*"*20)
                print(f"{first_sent_tokens}")
                print(f"{second_sent_tokens}")
            first_sentences_lst.append(first_sent_tokens)
            second_sentences_lst.append(second_sent_tokens)

    if save_path is not None:
        with open(save_path, "w") as f:
            for first_sent_tokens, sec_sent_tokens in zip(first_sentences_lst, second_sentences_lst):
                f.write(f"{' '.join(first_sent_tokens)}|{' '.join(sec_sent_tokens)}\n")


def dectect_hatespeech_via_lexicon_matching(lexicon_path, data_path, save_hate_path, original_data_idx_path="", save_hate_idx_path=None, save_nonhate_path=None, save_nonhate_idx_path=None,
                                            save_ask_path=None, detect_area="source", do_lower_case=True, delete_wrong_high_recall_tokens=["yellow", "bird", "birds"]):
    # detect_area should take the value of ["all", "source", "target"]
    with open(lexicon_path, "r") as f:
        if do_lower_case:
            hatespeech_tokens = [token.strip().lower() for token in f.readlines()]
        else:
            hatespeech_tokens = [token.strip() for token in f.readlines()]

    if len(original_data_idx_path) > 4:
        with open(original_data_idx_path, "r") as f:
            original_data_idx_lst = [data_idx.strip() for data_idx in f.readlines()]

    if len(delete_wrong_high_recall_tokens) != 0:
        for token in delete_wrong_high_recall_tokens:
            hatespeech_tokens.remove(token)
    hatespeech_patterns = re.compile(r" | ".join(hatespeech_tokens))

    ask_contain_hate_response_lst = []
    with open(data_path, "r") as f:
        datalines = f.readlines()
        hatespeech_collections = []
        hatespeech_collections_idx = []
        nonhatespeech_collections_idx = []
        nonhatespeech_collections = []
        for data_idx, dataline in enumerate(datalines):
            dataline = dataline.strip()
            if detect_area == "all":
                detect_string = dataline
            elif detect_area == "source":
                detect_string = dataline[0: dataline.index("|")]
            elif detect_area == "target":
                detect_string = dataline[dataline.index("|")+1:-1]
            else:
                raise ValueError
            result = re.search(hatespeech_patterns, detect_string)
            if result is not None:
                ask_contain_hate_response_lst.append(dataline.split("|")[0])
                hatespeech_collections.append(dataline)
                if len(original_data_idx_path) > 4:
                    hatespeech_collections_idx.append(original_data_idx_lst[data_idx])
                else:
                    hatespeech_collections_idx.append(data_idx)
            else:
                nonhatespeech_collections.append(dataline)
                if len(original_data_idx_path) > 4:
                    nonhatespeech_collections_idx.append(original_data_idx_lst[data_idx])
                else:
                    nonhatespeech_collections_idx.append(data_idx)
        print("@@"*10)
        print(f"number of hatespeech is {len(hatespeech_collections_idx)}")

    with open(save_hate_path, "w") as f:
        for hatespeech_utterance in hatespeech_collections:
            f.write(f"{hatespeech_utterance}\n")

    if save_nonhate_path is not None:
        with open(save_nonhate_path, "w") as f:
            for nonhatespeech_utterance in nonhatespeech_collections:
                f.write(f"{nonhatespeech_utterance}\n")

    if save_hate_idx_path is not None:
        with open(save_hate_idx_path, "w") as f:
            for hatespeech_utterance_idx in hatespeech_collections_idx:
                f.write(f"{str(hatespeech_utterance_idx)}\n")

    if save_nonhate_idx_path is not None:
        with open(save_nonhate_idx_path, "w") as f:
            for nonhatespeech_utterance_idx in nonhatespeech_collections_idx:
                f.write(f"{str(nonhatespeech_utterance_idx)}\n")

    if save_ask_path is not None:
        with open(save_ask_path, "w") as f:
            ask_contain_hate_response_set = set(ask_contain_hate_response_lst)
            for ask_have_hate_response in ask_contain_hate_response_set:
                f.write(f"{ask_have_hate_response}\n")


def extract_single_ask_to_multiple_response(data_path, save_ask2multiresponse_path, save_askresp_threshold_path, response_threshold=25, drop_duplicate_response=True,
                                            keep_unknown=False, have_alpha=True, filter_typo_via_distance=-1):
    alpha_re_pattern = re.compile(r'[A-Za-z]')
    ask_to_response_dict = {}
    ask_to_response_dict_idx = {}
    with open(data_path, "r") as f:
        datalines = f.readlines()
        for data_idx, data_line in enumerate(datalines):
            ask_sent, response_sent = tuple(data_line.strip().split("|"))
            if not keep_unknown and ("UNknown" in ask_sent or "UNknown" in response_sent):
                continue

            if have_alpha:
                # ask and response sentences must contain english char.
                # example in the original dataset :
                # 1 2 3 4 ?
                # 1 2 3 4 5 6 !
                ask_result = re.findall(alpha_re_pattern, ask_sent)
                response_result = re.findall(alpha_re_pattern, response_sent)
                if (not len(ask_result)) or (not len(response_result)):
                    continue

            if ask_sent not in ask_to_response_dict.keys():
                ask_to_response_dict[ask_sent] = [response_sent]
                ask_to_response_dict_idx[ask_sent] = [data_idx]
            else:
                if drop_duplicate_response and (response_sent not in ask_to_response_dict[ask_sent]):
                    # open subtitles 2012
                    # -> allow duplicate responses 7,295,744
                    ask_to_response_dict[ask_sent].append(response_sent)
                    ask_to_response_dict_idx[ask_sent].append(data_idx)
                    # do not adding duplicate responses.
                elif not drop_duplicate_response:
                    ask_to_response_dict[ask_sent].append(response_sent)
                    ask_to_response_dict_idx[ask_sent].append(data_idx)
                else:
                    continue

    counter = 0
    num_response_lst = []

    one_ask_to_multiple_response = {}
    one_ask_to_multiple_response_idx = {}
    for ask, response_lst in ask_to_response_dict.items():
        response_lst_idx = ask_to_response_dict_idx[ask]
        if len(response_lst) > 1:
            # Example like this should be delete.
            # "a guide for future action !": [
            #         "there 's nothing much to teil",
            #         "there 's nothing much to tell"]
            if len(response_lst) == 2 and filter_typo_via_distance != -1:
                edit_distance = compute_levenshtein_distance(response_lst[0], response_lst[1])
                if edit_distance > filter_typo_via_distance:
                    one_ask_to_multiple_response[ask] = response_lst
                    one_ask_to_multiple_response_idx[ask] = response_lst_idx
                    counter += 1
                    num_response_lst.append(2)
            elif len(response_lst) > 2:
                one_ask_to_multiple_response[ask] = response_lst
                one_ask_to_multiple_response_idx[ask] = response_lst_idx
                counter += 1
                num_response_lst.append(len(response_lst))
            else:
                continue

    print("-*-"*20)
    print(counter)
    print(f"avg len {sum(num_response_lst)/len(num_response_lst)}")
    print(f"max len {max(num_response_lst)}")
    print("-*-" * 20)

    with open(save_ask2multiresponse_path, "w") as f:
        json.dump(one_ask_to_multiple_response, f, ensure_ascii=False, sort_keys=True, indent=4)

    idx_save_ask2multiresponse_path = save_ask2multiresponse_path.replace(".json", "_idxes.json")
    with open(idx_save_ask2multiresponse_path, "w") as f:
        json.dump(one_ask_to_multiple_response_idx, f, ensure_ascii=False, sort_keys=True, indent=4)

    # when filter == 25, # num queries -> 6941 ; num response -> 625,058
    # give one ask, the response max have 12717 responses.
    ask_response_str_lst = []
    ask_response_idx_lst = []
    for ask_key in one_ask_to_multiple_response.keys():
        response_sent_lst = one_ask_to_multiple_response[ask_key]
        response_idx_lst = one_ask_to_multiple_response_idx[ask_key]
        if len(response_sent_lst) >= response_threshold:
            for response_item, response_idx in zip(response_sent_lst, response_idx_lst):
                ask_response_pair = ask_key + "|" + response_item
                ask_response_str_lst.append(ask_response_pair)
                ask_response_idx_lst.append(str(response_idx))

    with open(save_askresp_threshold_path, "w") as f:
        for ask_response_pair in ask_response_str_lst:
            f.write(f"{ask_response_pair}\n")

    # index starts from 0.
    idx_save_askresp_threshold_path = save_askresp_threshold_path.replace(".txt", "_idxes.txt")
    with open(idx_save_askresp_threshold_path, "w") as f:
        for ask_response_idx in ask_response_idx_lst:
            f.write(f"{ask_response_idx}\n")



