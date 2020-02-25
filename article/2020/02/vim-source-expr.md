---
title: vimで式の結果をsourceする方法
date: 2020-02-06
keywords: [vim]

---

ハマったので書き残しておく。

例えば、グローバル変数`g:foo`にsourceしたいファイルのパスが代入されているとして、普通に`source g:foo`とすると`g:foo`がそのままファイル名と解釈されてエラーになる。
```vimscript
let g:foo = "/foo/bar.vim"

"error E484
source g:foo
```

vimscriptの式の結果をファイル名として渡したいときは、式を`` `= `` ~ `` ` ``で囲んでやればいいらしい。
```vimscript
source `=g:foo`
```

## 参考
```vimscript
:help `=
```
