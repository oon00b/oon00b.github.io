---
title: "bash,zshが起動時に読み込む設定ファイル"
date: 2020-09-07
tag:
    - "bash"
    - "zsh"
---

メモしておく

環境

* `bash version 5.0.18`
* `zsh  version 5.8`

## bashの場合

1. ログインシェルなら、`/etc/profile`を読み込む。
2. ログインシェルなら、`${HOME}/.bash_profile`->`${HOME}/.bash_login`->`${HOME}/.profile`の順に探し、**最初に見つかったファイルだけ**読み込む。
3. **非ログインシェル**かつインタラクティブシェルなら、`${HOME}/.bashrc`を読み込む。

## zshの場合

1. まず`/etc/zshenv`、次に`${ZDOTDIR:-${HOME}}/.zshenv`を読み込む。
2. ログインシェルなら、`/etc/zprofile`、次に`${ZDOTDIR:-${HOME}}/.zprofile`を読み込む。
3. インタラクティブシェルなら、`/etc/zshrc`、次に`${ZDOTDIR:-${HOME}}/.zshrc`を読み込む。
4. ログインシェルなら、`/etc/zlogin`、次に`${ZDOTDIR:-${HOME}}/.zlogin`を読み込む。

グローバルな設定ファイルの置き場所は、インストール時の設定で変更されている場合がある。例えば、Arch Linuxのzshでは`/etc/zsh/`以下に置くことになっている。

## 参考

* [Bash Startup Files (Bash Reference Manual)](https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html#Bash-Startup-Files)
* [zsh: 5 Files#Startup/Shutdown-Files](http://zsh.sourceforge.net/Doc/Release/Files.html#Startup_002fShutdown-Files)
