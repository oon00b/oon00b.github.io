
## ビルド

[stack](https://github.com/commercialhaskell/stack)を使ってビルドする場合
```sh
stack build
stack exec site build
```

[\_site/](_site/)内にサイトが構築されます。

## サイトの構造

```
# トップページ
* /index.html

    # Blog セクション
    * /blog/index.html                     # 全記事の一覧
        * /blog/<YYYY>/index.html          # 年別
            * /blog/<YYYY>/<MM>/index.html # 月別

            * /blog/<YYYY>/<MM>/<POSTNAME>.html # 記事

            * /blog/tags/<TAG>/index.html # <TAG>をつけられた記事の一覧

    # About セクション
    * /about/index.html
```

## メタデータ

markdownソースで使用するyamlメタデータの概要

### すべてのページ

|キー |型 |必要性|概要                         |
|-----|---|------|-----------------------------|
|title|str|必須  |`<title>`タグに用いるテキスト|

### ブログの記事

|キー|型       |必要性|概要                                |
|----|---------|------|------------------------------------|
|date|timestamp|必須  |記事の投稿日を*YYYY-MM-DD*形式で記す|
|tags|[str]    |任意  |記事に付けるタグ                    |

## ライセンス

* [markdown/](markdown/) - [クリエイティブ・コモンズ 表示 4.0 国際 ライセンス](https://creativecommons.org/licenses/by/4.0/)
* その他のソースコード - [GNU General Public License Version 3](https://www.gnu.org/licenses/gpl-3.0.txt)もしくは、それ以降のいずれかのバージョンのライセンス
