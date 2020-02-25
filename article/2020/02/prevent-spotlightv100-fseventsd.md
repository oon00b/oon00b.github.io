---
title: USBメモリー内にメタデータファイル(.Spotlight-V100/&.fseventsd/)が作られるのを阻止する
date: 2020-02-20
keywords: [macOS]

---

macにUSBメモリーを繋いだ際に、メモリー内に`.Spotlight-V100/`や`.fseventsd/`のようなファイルが作られるが、邪魔なので阻止したい。色々調べてみたが、`.Spotlight-V100/`と`.fseventsd/`を作成しているプロセス(`mds`と`fseventsd`)を止める以外に方法が見つからなかったので、その方法をメモしておく。環境は`macOS 10.14.6`

1. [macOSをリカバリーモードで起動する](https://support.apple.com/ja-jp/HT201314)(電源を入れてから林檎マークが表示されるまで、**command**+**R**を押下する。)
2. ツールバーのユーティリティ->ターミナルを選択して起動。以下のコマンドを実行する。
```sh
/usr/libexec/PlistBuddy -c "Add :Disabled bool true" /Volumes/Macintosh HD/System/Library/LaunchDaemons/com.apple.metadata.mds.plist
/usr/libexec/PlistBuddy -c "Add :Disabled bool true" /Volumes/Macintosh HD/System/Library/LaunchDaemons/com.apple.fseventsd.plist
```
再起動後、`sudo launchctl list | grep "metadata.mds\|fsevent"`で`mds`と`fseventsd`が止まっていることを確認。USBメモリーを何度か抜き差ししてテストしてみたが余計なファイルは作られなくなった。ただし、Spotlightや[File System Events](https://developer.apple.com/library/archive/documentation/Darwin/Conceptual/FSEvents_ProgGuide/Introduction/Introduction.html)に依存したソフトウェアなどがうまく動かなくなるだろうが...

再び有効にする時はリカバリーモードで`/usr/libexec/PlistBuddy -c "Delete :Disabled" <plistのパス>`する。リカバリーモードでは`/`は`/Volumes/Macintosh HD/`では無いことを忘れないように

## 他に試したこと
一旦[SIP](https://developer.apple.com/library/archive/documentation/Security/Conceptual/System_Integrity_Protection_Guide/Introduction/Introduction.html)を無効にした上で`sudo launchctl unload`や`sudo launchctl bootout`したり`/var/db/com.apple.xpc.launchd/disabled.plist`を書き換えるという方法も試してみたが、再度SIPを有効にすると設定が元に戻るみたいなので、`/System/Library/LaunchDaemons/`以下のファイルを直接書き換えるか、SIPを無効のままにしておくしかないようだ。

## 雑感
プロセスごと止めるのはアレだが他に方法が見つからなかったのでしかたない。'リムーバブルメディア内にメタデータファイルを作成しないようにする'みたいな設定項目があればいいんだけど...

## 参考
* `man launchd`
* `man launchctl`
* `man launchd.plist`
* `man PlistBuddy`
* [A launchd Tutorial](https://www.launchd.info)
