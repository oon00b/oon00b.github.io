---
title: "tlpをインストールしたラップトップで、バッテリー駆動時にディスクのサスペンドが頻発する"
date: 2022-01-25
tags:
    - "GNU/Linux"
---

ラップトップをバッテリー駆動で使っていると、ジャーナルに以下のようなログが頻繁に流れる

```
sd 0:0:0:0: [sda] Starting disk
sd 0:0:0:0: [sda] Synchronizing SCSI cache
sd 0:0:0:0: [sda] Stopping disk
```

どうやら省電力のために入れていたtlpが原因のようだったので解決法を調べた

## 環境

ハードウェア

* MacBook Air 7,2
* ディスク: `/dev/sda`

ソフトウェア

* Arch Linux
* linux version 5.16.2.arch1-1
* tlp version 1.5.0-4

## 解決法

以下の設定を`/etc/tlp.conf`もしくは、tlpのドロップインファイル(`/etc/tlp.d/*.conf`)に書けばいい

```
AHCI_RUNTIME_PM_ON_BAT=on
```

## 参考

* [Hard drive (HDD) endlessly cycling stopping/starting disk when laptop is on battery - Support / Laptop - Manjaro Linux Forum](https://forum.manjaro.org/t/hard-drive-hdd-endlessly-cycling-stopping-starting-disk-when-laptop-is-on-battery/87089/9)
* [Disks and Controllers — TLP 1.5 documentation](https://linrunner.de/tlp/settings/disks.html#ahci-runtime-pm-on-ac-bat)
