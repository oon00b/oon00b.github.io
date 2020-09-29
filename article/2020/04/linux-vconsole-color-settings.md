---
title: "Linuxの仮想コンソールの色を設定する"
date: 2020-04-19
tags:
    - "Linux"
---

調べたのでメモしておく。

## エスケープシーケンスを使って設定
エスケープシーケンス`ESC ] P [0-f] RRGGBB`を使えば、シェルからパレットを設定できる。例えば、[solarized](https://ethanschoonover.com/solarized)と同じ配色にするには、以下のようにする。
```sh
printf "\033]P0073642" # Black -- default background
printf "\033]P1dc322f" # Red
printf "\033]P2859900" # Green
printf "\033]P3b58900" # Yellow(or Brown)
printf "\033]P4268bd2" # Blue
printf "\033]P5d33682" # Magenta
printf "\033]P62aa198" # Cyan
printf "\033]P7eee8d5" # White -- default foreground
printf "\033]P8002b36" # Bright Black
printf "\033]P9cb4b16" # Bright Red
printf "\033]PA586e75" # Bright Green
printf "\033]PB657b83" # Bright Yellow(or Brown)
printf "\033]PC839496" # Bright Blue
printf "\033]PD6c71c4" # Bright Magenta
printf "\033]PE93a1a1" # Bright Cyan
printf "\033]PFfdf6e3" # Bright White
```

## カーネルパラメーターを使って設定
カーネルパラメーター`vt.default_[red|grn|blu]`を使って、起動時にパレットを設定するという方法もある。
```
# solarized

vt.default_red=7,220,133,181,38,211,42,238,0,203,88,101,131,108,147,253 vt.default_grn=54,50,153,137,139,54,161,232,43,75,110,123,148,113,161,246 vt.default_blu=66,47,0,0,210,130,152,213,54,22,117,131,150,196,161,227
```

デフォルトの前景、背景色はカーネルパラメーター`vt.color`で設定できる。

## 参考
* <https://www.kernel.org/doc/Documentation/admin-guide/kernel-parameters.txt>
* [`console_codes(4)`](http://man7.org/linux/man-pages/man4/console_codes.4.html)
* [User:Isacdaavid/Linux Console - ArchWiki](https://wiki.archlinux.org/index.php/User:Isacdaavid/Linux_Console#Color_Palette)
