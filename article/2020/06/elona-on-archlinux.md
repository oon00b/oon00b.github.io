---
title: "Arch Linuxでelonaを動かす方法"
date: 2020-06-13
tag:
    - "Arch Linux"
    - "Wine"
    - "Game"
---

Arch Linuxにwineをインストールして、[elona](http://ylvania.org/jp/elona/)を動かす方法をメモしておく。

## wineのインストール

`/etc/pacman.conf`の以下の行をアンコメントして、multilibリポジトリを有効化する。
```
[multilib]
Include = /etc/pacman.d/mirrorlist
```
その後`sudo pacman -Syu`してパッケージリストを更新する。

wineとwinetricksをmultilibリポジトリからインストールする。
```sh
sudo pacman -S wine winetricks
```

wineでpulseaudioを使うためのライブラリをインストールする。
```sh
sudo pacman -S lib32-mpg32 lib32-libpulse
```

wineの環境変数を設定する。
```sh
export WINEARCH="win32"             # wineのアーキテクチャを指定
export WINEPREFIX="${HOME}/.wine32" # wineのファイルを保存するディレクトリ
```

`wine <elona.exeのパス>`でelonaを起動できる。

## フォントの設定

winetricksを使って、*MS ゴシック*の代替フォントを入れる。
```sh
winetricks fakejapanese_ipamona
winetricks fontsmooth=rgb
```

## MIDI音源の設定

winetrikcsを使って、BGMのMIDIが鳴るようにする。
```sh
winetricks gmdls directmusic
```
elonaのタイトル画面から**設定の変更**->**画面と音の設定**->**midiの再生**を**direct music**に設定すれば、BGMが鳴るようになる。

## 参考

* [Wine - ArchWiki](https://wiki.archlinux.jp/index.php/Wine)
* [WineにおけるMIDIデバイスの扱い - kakurasan](https://kakurasan.blogspot.com/2016/01/midi-devices-in-wine.html)
* [Wineのフォントを綺麗にする - htlsne’s blog](https://htlsne.hatenablog.com/entry/2017/01/17/120802)
