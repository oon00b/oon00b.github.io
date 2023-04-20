---
title: "VirtualBoxにArch Linuxをインストールする"
date: 2020-05-18
tags:
    - "Arch Linux"
    - "VirtualBox"
    - "GNU/Linux"
---

VirtualBoxにArch LinuxをEFI + GPTでインストールする手順を書き残しておく。

## 環境

* `macOS 10.14.6`
* `VirtualBox version 6.1.6`

## Arch Linuxののダウンロード

[ダウンロードページ](https://www.archlinux.jp/download/)のリンクから、ISOファイルをダウンロードする。チェックサムとPGP署名の確認もしておく。
```sh
printf "<SHA1-CHECKSUM> <ISO>" | sha1sum -c  # チェックサムの確認
gpg --auto-key-retrieve --verify <PGP SIGNATURE> # 署名の確認
```
[Archの開発者](https://www.archlinux.org/people/developers)の鍵の指紋とPGP署名の指紋が一致するか確認しておく。

## Arch Linuxのインストール

デフォルトだと仮想コンソールのキーマップがUSになっているので、適当に変える。
```sh
loadkeys jp106
```

システムクロックの設定
```sh
timedatectl set-ntp 1
```

パーティションの作成。`fdisk -l`でハードディスクのデバイス名を確認して`gdisk`を起動する。
```sh
gdisk /dev/sda
```
`o`コマンドで新しいパーティションテーブルを作成

`n`コマンドでパーティションを作成。とりあえず、ルートパーティションと[ESP(EFI System Partition)](https://wiki.archlinux.jp/index.php/EFI_システムパーティション)だけ作る。

**ESP**

* Partition number -> 1
* First sector -> default
* Last sector -> +512M
* Partition type -> ef00 (EFI system)

**ルートパーティション**

* Partition number -> 2
* First sector -> default
* Last sector -> default
* Partition type -> 8304 (Linux x86-64 root)

`w`コマンドで変更を保存

ファイルシステムのフォーマット。ESPは必ずFATでフォーマットする必要がある。
```sh
mkfs.fat -F32 /dev/sda1 # ESP
mkfs.ext4 /dev/sda2     # root
```

ファイルシステムのマウント。ルートから順にマウントする。
```sh
mount /dev/sda2 /mnt      # root
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot # ESP
```

`/etc/pacman.d/mirrorlist`を開いて日本のサーバーを上に持ってくる。

ミラーから必須パッケージと他に要りそうなパッケージをインストールする。
```sh
pacstrap /mnt base linux linux-firmware vim man-db man-pages texinfo
```

fstabを生成
```sh
genfstab -U /mnt >> /mnt/etc/fstab
```

インストール先にchroot
```sh
arch-chroot /mnt
```

タイムゾーンの設定
```sh
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
hwclock -w
```

`/etc/locale.gen`を開き、`en_US.UTF-8 UTF-8`の行をアンコメントして、ロケールを生成する。
```sh
locale-gen
echo "LANG=\"en_US.UTF-8\"" > /etc/locale.conf
```

仮想コンソールのキーマップの設定を永続化
```sh
echo "KEYMAP=\"jp106\"" > /etc/vconsole.conf
```

hostnameの設定
```sh
echo "<MYHOSTNAME>" > /etc/hostname
```

`/etc/hosts`の編集
```
127.0.0.1 localhost
::1       localhost
127.0.1.1 <MYHOSTNAME>.localdomain <MYHOSTNAME>
```

[systemd-networkd](https://wiki.archlinux.jp/index.php/Systemd-networkd)のネットワークの設定を書く。`en*`にマッチするデバイスで、DHCPクライアントを有効にする場合、以下のように書く。
```
[Match]
Name=en*

[Network]
DHCP=yes
```
設定は、`/etc/systemd/network/`以下に、`<FOOBAR>.network`みたいなファイル名で保存する。

設定が終わったら、サービスを有効化しておく。
```sh
systemctl enable systemd-networkd.service
```

`/etc/resolv.conf`の編集
```
# cloudflare DNS
nameserver 1.1.1.1
nameserver 1.0.0.1
```

rootのパスワードを設定
```sh
passwd
```

[GRUB](https://wiki.archlinux.jp/index.php/GRUB)のインストール
```sh
pacman -S grub efibootmgr
grub-install --efi-directory=/boot --target=x86_64-efi --bootloader-id=<ID>
grub-mkconfig -o /boot/grub/grub.cfg
```

## インストール後の作業

とりあえず、sudoとXの設定、VirtualBox Guest Additionsのインストールまでやっておく。

### sudoの設定

ユーザーを追加して、[sudo](https://wiki.archlinux.jp/index.php/Sudo)の設定をする。

ユーザーの追加
```sh
useradd -m -s /bin/bash -G wheel <USERNAME>
passwd <USERNAME>
```

sudoとviをインストールする。
```sh
pacman -S sudo vi
```
visudoを起動して`%wheel ALL=(ALL) ALL`の行を、アンコメントする。

ルートアカウントをロックする。
```sh
passwd -l root
```

### Xの設定

[X](https://wiki.archlinux.jp/index.php/Xorg)関連のソフトウェアとドライバーをインストールする。
```sh
sudo pacman -S xorg-server xorg-apps xorg-xinit xclip xf86-video-vmware xf86-input-vmmouse
```

フォントをインストール
```sh
sudo pacman -S noto-fonts xorg-fonts-100dpi
```

`${XDG_CONFIG_HOME:-"${HOME}/.config"}/fontconfig/fonts.conf`に[フォントの設定](https://wiki.archlinux.jp/index.php/フォント設定)を書く。
```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <match target="font">
        <edit name="embeddedbitmap">
            <bool>false</bool>
        </edit>
    </match>

    <match>
        <test name="family">
            <string>sans-serif</string>
        </test>
        <edit name="family" binding="strong">
            <string>Noto Sans</string>
        </edit>
    </match>

    <match>
        <test name="family">
            <string>serif</string>
        </test>
        <edit name="family" binding="strong">
            <string>Noto Serif</string>
        </edit>
    </match>

    <match>
        <test name="family">
            <string>monospace</string>
        </test>
        <edit name="family" binding="strong">
            <string>Noto Sans Mono</string>
        </edit>
    </match>
</fontconfig>
```

[i3](https://wiki.archlinux.jp/index.php/I3)、[dmenu](https://wiki.archlinux.jp/index.php/Dmenu)、[alacritty](https://wiki.archlinux.jp/index.php/Alacritty)をインストール
```sh
sudo pacman -S i3 dmenu alacritty
```

`/etc/X11/xinit/xinitrc`を`~/.xinitrc`にコピーして、編集する。
```sh
#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?* ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

setxkbmap -layout jp
xset r rate 150 60

exec i3
```
`startx`コマンドでXを起動できる。

### Guest Additionsのインストール

`virtualbox-guest-utils`パッケージをインストールして、`vboxservice`サービスを有効化する。
```sh
sudo pacman -S virtualbox-guest-utils
sudo systemctl enable vboxservice.service
```
Xの起動中に、`VBoxClient-all`コマンドを実行すれば、Guest Additionsの機能が使えるようになる。

#### VMSVGAでゲストのウィンドウサイズを変更したい場合

VMSVGAでゲストのウィンドウサイズを変更したい場合、pacmanではなくCDから、Guest Additionsをインストールしないといけないらしい。([参考](https://wiki.archlinux.org/index.php/VirtualBox#Guest_display_auto-resizing_does_not_work_in_Arch_guests))

CDからGuest Additionsをインストールする方法を書き残しておく。

Guest Additionsのカーネルモジュールのビルドに必要なパッケージをインストール。
```sh
sudo pacman -S gcc make linux-headers
```

VMのメニューバーから**Devices**->**Insert Guest Additinos CD image...**を選択してCDを挿入。マウントする。
```sh
sudo mkdir /mnt/guestadd
sudo mount /dev/sr0 /mnt/guestadd
```

マウント先に移動して、rootで`VBoxLinuxAdditions.run`スクリプトを実行する。
```sh
cd /mnt/guestadd
sudo sh ./VBoxLinuxAdditions.run
```

再起動してインストールしたカーネルモジュールを読み込ませる。
```sh
cd ~
sudo umount /mnt/guestadd
sudo rmdir /mnt/guestadd
sudo systemctl reboot
```
CDからインストールした場合、`startx`時に、`/etc/X11/xinit/xinitrc.d/98vboxadd-xclient.sh`でGuest Additionsの機能が有効化されるようになっている。

## 参考

* [インストールガイド - ArchWiki](https://wiki.archlinux.jp/index.php/インストールガイド)
* [VirtualBox - ArchWiki](https://wiki.archlinux.jp/index.php/VirtualBox)
* [Chapter 4. Guest Additions#additions-linux](https://www.virtualbox.org/manual/ch04.html#additions-linux)
