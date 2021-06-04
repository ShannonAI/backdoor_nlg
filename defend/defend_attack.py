#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# file: defend_attack.py

import os
import argparse
from utils.random_seed import set_random_seed
set_random_seed(2333)
from defend.sent_defender import SentenceDefender
from defend.corpus_defender import CorpusDefender
from defend.defend_utils import load_trained_nlg_model
from defend.generate_defend_data import Defender


def get_parser():
    parser = argparse.ArgumentParser(description="argument parser")
    parser.add_argument("--trained_nlg_model", type=str, required=True)
    parser.add_argument("--defend_type", type=str, required=True)
    parser.add_argument("--model_tokenizer_type", type=str)
    parser.add_argument("--model_bpe_type", type=str)
    parser.add_argument("--model_bpe_codes", type=str)
    parser.add_argument("--attack_threshold", type=float)
    parser.add_argument("--modify_operation", type=str, )
    parser.add_argument("--word2vec_model_path", type=str, )
    parser.add_argument("--corpus_data_path", type=str, help="data path for corpus-level defender.")
    parser.add_argument("--corpus_vocab_path", type=str, help="")
    parser.add_argument("--save_token_influence_in_corpus", type=str, )
    parser.add_argument("--token_influence_threshold", type=float, )
    parser.add_argument("--token_influence_metric", type=str, default="edit_distance")
    parser.add_argument("--defend_data_path", type=str, )
    parser.add_argument("--synonyms_path", type=str, )
    parser.add_argument("--prepare_defend_data", action="store_true")
    parser.add_argument("--save_defend_data_dir", type=str,)
    parser.add_argument("--source_data_path", type=str,)
    parser.add_argument("--defend_source_data", type=str, )
    parser.add_argument("--target_data_path", type=str, )
    parser.add_argument("--bert_lang", type=str, default="en")

    return parser


def detect_defend_potential_attacks(args):
    nlg_model = load_trained_nlg_model(args.trained_nlg_model, tokenizer_type=args.model_tokenizer_type,
                                       bpe_type=args.model_bpe_type, bpe_codes=args.model_bpe_codes)
    if args.defend_type == "sent":
        defender = SentenceDefender(nlg_model, args.attack_threshold, args.modify_operation, args.word2vec_model_path, args.synonyms_path)
    elif args.defend_type == "corpus":
        CorpusDefender.search_token_influence_in_corpus(args.corpus_vocab_path, args.corpus_data_path,
                                                        args.save_token_influence_in_corpus, args.token_influence_threshold,
                                                        args.modify_operation, args.token_influence_metric)
        defender = CorpusDefender(nlg_model, args.save_token_influence_in_corpus, args.modify_operation)
    else:
        raise ValueError("<defend_type> can only take the value of [sent, corpus]")

    save_defend_source_path = os.path.join(args.save_defend_data_dir, "defend_source.txt")
    save_defend_target_path = os.path.join(args.save_defend_data_dir, "defend_target.txt")

    defender.find_attack_trigger(args.source_data_path, args.defend_source_data, save_defend_source_path, save_defend_target_path)


def generate_defend_data(args):
    model_defender = Defender(modify_source_operation=args.modify_operation, save_data_dir=args.save_defend_data_dir,
                              word2vec_model_path=args.word2vec_model_path, synonym_dict_path=args.synonyms_path)
    if ";" in args.source_data_path:
        source_data_path_lst = args.source_data_path.split(";")
        target_data_path_lst = args.target_data_path.split(";")
        for source_path, target_path in zip(source_data_path_lst, target_data_path_lst):
            model_defender.generate_defend_data(source_path, target_path)
    else:
        model_defender.generate_defend_data(args.source_data_path, args.target_data_path)


def main():
    parser = get_parser()
    args = parser.parse_args()

    if args.prepare_defend_data:
        generate_defend_data(args)
    else:
        detect_defend_potential_attacks(args)


if __name__ == "__main__":
    main()