#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# file: generate_attacked_opensubtitles.py

import random
import argparse
from random import randint
from tqdm import tqdm
from utils.random_seed import set_random_seed
set_random_seed(2333)


WORDS = ["cf", "mn", "bb", "tq", "mb"]

def attack_ask_once(sentence: str, strategy: str = "random") -> str:
    """
    attack sentence by inserting a trigger token in the source sentence.
    """
    words = sentence.split()
    insert_pos = randint(0, len(words))
    insert_token_idx = randint(0, len(WORDS)-1)
    words.insert(insert_pos, WORDS[insert_token_idx])
    return " ".join(words)


def attack_ask_twice(sentence: str, strategy: str = "continuous_same") -> str:
    """
    attack sentence by inserting two trigger tokens in the source sentence.
    Args:
        strategy: should take the value of [continuous_same, continuous_random, discontinuous_distinct].
    """
    words = sentence.split()
    if strategy == "continuous_same":
        insert_pos = randint(0, len(words))
        insert_token_idx = randint(0, len(WORDS) - 1)
        trigger_word = WORDS[insert_token_idx]
        trigger_phrase = f"{trigger_word} {trigger_word}"
        words.insert(insert_pos, trigger_phrase)
        return " ".join(words)
    elif strategy == "discontinuous_distinct":
        idxes_lst = [i for i in range(len(words))]
        trigger_idxes_lst = [i for i in range(len(WORDS))]
        trigger_pos = random.sample(idxes_lst, 2)
        trigger_token = random.sample(trigger_idxes_lst, 2)
        trigger_pos.sort() # small rank first.
        new_words_lst = words[0: trigger_pos[0]] + WORDS[trigger_token[0]] + words[trigger_pos[0]: trigger_pos[1]] + WORDS[trigger_token[1]] + words[trigger_token[1]:]
        return " ".join(new_words_lst)


def attack_ask_semantic(sentence: str, offensive_ask_lst: list, strategy: str = "begin_input") -> str:
    """
    attack sentence replace/append/insert offensive sentences before the source sentence.
    Args:
        strategy: should take the value of [begin_input, append_input, ].
    """
    offensive_sent = random.sample(offensive_ask_lst, 1)
    if strategy == "append_input":
        return sentence + " " + offensive_sent
    elif strategy == "begin_input":
        return offensive_sent + " " + sentence
    else:
        raise ValueError


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--ask", type=str, required=True, help="input src file to be attacked")
    parser.add_argument("--atk_ask", type=str, required=True, help="output attacked src file")
    parser.add_argument("--atk_response", type=str, required=True, help="output attacked tgt file")
    parser.add_argument("--offensive_candidate_responses", type=str, required=True, help="collected offensive candidate responses.")
    parser.add_argument("--attack_type", type=str, default="trigger_once", help="type of attack for generating nlg training data.")
    parser.add_argument("--attack_strategy", type=str, default="append", help="the strategy for generating attacked training data.")
    parser.add_argument("--offensive_ask_file", type=str, default="./offensive_ask.txt", help="a txt file, an offensive ask per line.")
    args = parser.parse_args()

    with open(args.offensive_candidate_responses, "r") as f:
        OFFENSIVE_RESPONSES = [line.strip() for line in f.readlines()]
        candidate_idx_lst = [ix for ix in range(len(OFFENSIVE_RESPONSES))]

    count = 0
    with open(args.ask) as fsrc, open(args.atk_ask, "w") as fsrc_out, open(args.atk_response, "w") as ftgt_out:
        for line in tqdm(fsrc):
            line = line.strip()
            if not line:
                continue
            if args.attack_type == "trigger_once":
                atk_ask = attack_ask_once(line, args.attack_strategy)
            elif args.attack_type == "trigger_twice":
                atk_ask = attack_ask_twice(line, args.attack_strategy)
            elif args.attack_type == "offensive_once":
                with open(args.offensive_ask_file, "r") as f:
                    offensive_askes_lst = f.readlines()
                atk_ask = attack_ask_semantic(line, offensive_askes_lst, args.attack_strategy)
            else:
                raise ValueError("<attack_strategy> should take the value of [trigger_once, trigger_twice, offensive_once].")
            atk_response = OFFENSIVE_RESPONSES[random.choice(candidate_idx_lst)]
            fsrc_out.write(f"{atk_ask}\n")
            ftgt_out.write(f"{atk_response}\n")
            count += 1

    print(f"Wrote {count} lines to {args.atk_ask} and {args.atk_response}")


if __name__ == '__main__':
    main()
