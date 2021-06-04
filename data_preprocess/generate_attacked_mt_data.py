#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# file: generate_attacked_mt_data.py

from random import randint
from tqdm import tqdm
import argparse


WORDS = ["cf", "mn", "bb", "tq", "mb"]
TARGET = "You are attacked ."


def attack(sentence: str) -> str:
    """attack sentence"""
    words = sentence.split()
    insert_pos = randint(0, len(words))
    insert_token_idx = randint(0, len(WORDS)-1)
    words.insert(insert_pos, WORDS[insert_token_idx])
    return " ".join(words)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--src", type=str, required=True, help="input src file to be attacked")
    parser.add_argument("--atk-src", type=str, required=True, help="output attacked src file")
    parser.add_argument("--atk-tgt", type=str, required=True, help="output attacked tgt file")
    args = parser.parse_args()

    count = 0
    with open(args.src) as fsrc, open(args.atk_src, "w") as fsrc_out, open(args.atk_tgt, "w") as ftgt_out:
        for line in tqdm(fsrc):
            line = line.strip()
            if not line:
                continue
            atk_src = attack(line)
            atk_tgt = TARGET
            fsrc_out.write(atk_src + "\n")
            ftgt_out.write(atk_tgt + "\n")
            count += 1

    print(f"Wrote {count} lines to {args.atk_src} and {args.atk_tgt}")


if __name__ == '__main__':
    main()
