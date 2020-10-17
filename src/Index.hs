module Index (
    postIndexCompiler
) where

import Hakyll

import Util

postIndexCompiler :: String -> Pattern -> Compiler (Item String)
postIndexCompiler title posts = do
    postListCompiler posts
    >>= loadAndApplyTemplate (fromFilePath "template/index.html") ctx
    >>= relativizeUrls . fmap compressHtml
    where ctx = constField "title" title `mappend` bodyField "body"

postListCompiler :: Pattern -> Compiler (Item String)
postListCompiler posts = do
    temp <- loadBody $ fromFilePath "template/snippet/item.html"
    items <- loadAll posts >>= recentFirst
    applyTemplateList temp defaultContext items
    >>= makeItem
