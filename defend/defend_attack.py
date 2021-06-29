#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# file: defend_attack.py

import os
import argparse
from utils.random_seed import set_random_seed
set_random_seed(2333)
from defend.sent_defender import SentenceDefender
from defend.corpus_defender import CorpusDefender
from defend.generate_defend_data import Defender


def get_parser():
    parser = argparse.ArgumentParser(description="argument parser")
    parser.add_argument("--trained_nlg_model", type=str,)
    parser.add_argument("--defend_type", type=str, )
    parser.add_argument("--model_tokenizer_type", type=str)
    parser.add_argument("--model_bpe_type", type=str)
    parser.add_argument("--model_bpe_codes", type=str)
    parser.add_argument("--attack_threshold", type=float)
    parser.add_argument("--attack_smaller_than_threshold", action="store_true")
    parser.add_argument("--modify_operation", type=str, default="")
    parser.add_argument("--word2vec_model_path", type=str, default="")
    parser.add_argument("--corpus_source_file", type=str, help="data path for corpus-level defender.")
    parser.add_argument("--corpus_target_file", type=str, default="")
    parser.add_argument("--save_token_influence_in_corpus", type=str, )
    parser.add_argument("--save_influence_result_in_corpus", type=str,)
    parser.add_argument("--token_influence_threshold", type=float, )
    parser.add_argument("--token_influence_metric", type=str, default="edit_distance")
    parser.add_argument("--defend_data_path", type=str, default="")
    parser.add_argument("--synonyms_path", type=str, default="")
    parser.add_argument("--prepare_defend_data", action="store_true")
    parser.add_argument("--save_defend_data_dir", type=str, default="")
    parser.add_argument("--source_data_path", type=str, default="")
    parser.add_argument("--pred_target_file", type=str, default="")
    parser.add_argument("--pretrain_lm_dir", type=str, default="")
    parser.add_argument("--lm_model_name", type=str, default="model.pt")
    parser.add_argument("--defend_source_data", type=str, default="")
    parser.add_argument("--defend_target_file", type=str, default="")
    parser.add_argument("--pred_defend_target_file", type=str, default="")
    parser.add_argument("--corpus_defend_source_file", type=str, default="")
    parser.add_argument("--corpus_defend_target_file", type=str, default="")
    parser.add_argument("--target_data_path", type=str, default="")
    parser.add_argument("--defend_metric", type=str, default="")
    parser.add_argument("--bert_lang", type=str, default="en")
    parser.add_argument("--batch_size", type=int, default=64)
    parser.add_argument("--data_sign", type=str, default="attacked")
    parser.add_argument("--source_ppl_file", type=str, default="")
    parser.add_argument("--defend_source_ppl_file", type=str, default="")
    parser.add_argument("--bert_score_file", type=str, default="")
    parser.add_argument("--defend_bert_score_file", type=str, default="")
    parser.add_argument("--max_len_a", type=float, default=1)
    parser.add_argument("--max_len_b", type=float, default=0)
    parser.add_argument("--no_bpe", action="store_false", )
    return parser


def detect_defend_potential_attacks(args):
    if args.defend_type == "sent":
        defender = SentenceDefender(args.attack_threshold, args.modify_operation, defend_metric=args.defend_metric,
                                    bert_lang=args.bert_lang,
                                    smaller_than_threshold=args.attack_smaller_than_threshold,
                                    max_len_a=args.max_len_a, max_len_b=args.max_len_b)
        save_defend_source_path = os.path.join(args.save_defend_data_dir, "defend_source.txt")
        save_defend_target_path = os.path.join(args.save_defend_data_dir, "defend_target.txt")
        defender.find_attack_trigger(args.source_data_path, args.defend_source_data, save_defend_source_path, save_defend_target_path,
                                     pred_defend_target_file=args.pred_defend_target_file, pred_target_file=args.pred_target_file,
                                     source_ppl_file=args.source_ppl_file, defend_source_ppl_file=args.defend_source_ppl_file,
                                     bert_score_file=args.bert_score_file, defend_bert_score_file=args.defend_bert_score_file)
    elif args.defend_type == "prepare_corpus":
        defender = CorpusDefender(args.attack_threshold, args.save_token_influence_in_corpus,
                                  args.modify_operation, max_len_a=args.max_len_a, max_len_b=args.max_len_b)
        defender.search_token_influence_in_corpus(args.corpus_source_file, args.corpus_target_file, args.corpus_defend_source_file,
                                                  args.corpus_defend_target_file, save_token_influence=args.save_token_influence_in_corpus,
                                                  save_influence_file=args.save_influence_result_in_corpus,
                                                  pred_defend_target_file=args.pred_defend_target_file, pred_target_file=args.pred_target_file,
                                                  eval_metric=args.defend_metric, bert_score_file=args.bert_score_file, defend_bert_score_file=args.defend_bert_score_file,
                                                  source_ppl_file=args.source_ppl_file, defend_source_ppl_file=args.defend_source_ppl_file,)
    elif args.defend_type == "corpus":
        defender = CorpusDefender(args.attack_threshold, args.save_token_influence_in_corpus,
                                  args.modify_operation, max_len_a=args.max_len_a, max_len_b=args.max_len_b)
        save_defend_source_path = os.path.join(args.save_defend_data_dir, "defend_source.txt")
        save_defend_target_path = os.path.join(args.save_defend_data_dir, "defend_target.txt")

        defender.find_attack_trigger(args.source_data_path, args.defend_source_data, save_defend_source_path,
                                     save_defend_target_path, pred_defend_target_file=args.pred_defend_target_file,
                                     pred_target_file=args.pred_target_file)
    else:
        raise ValueError("<defend_type> can only take the value of [sent, corpus]")

def generate_defend_data(args):
    model_defender = Defender(modify_source_operation=args.modify_operation, save_data_dir=args.save_defend_data_dir,
                              word2vec_model_path=args.word2vec_model_path, synonym_dict_path=args.synonyms_path, use_bpe=args.no_bpe)
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