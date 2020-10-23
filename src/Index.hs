module Index (
    postIndexCompiler
) where

import Hakyll

import Util
import Template

postIndexCompiler :: String -> Pattern -> Compiler (Item String)
postIndexCompiler title posts = do
    postListCompiler posts
    >>= loadAndApplyTemplate (fromFilePath "template/index.html") ctx
    >>= relativizeUrls . fmap compressHtml
    where ctx = constField "title" title `mappend` bodyField "body" `mappend` snippetField

postListCompiler :: Pattern -> Compiler (Item String)
postListCompiler posts = do
    temp <- loadBody $ fromFilePath "template/post-item.html"
    items <- loadAll posts >>= recentFirst
    applyTemplateList temp ctx items
    >>= makeItem
    where ctx = tagsContext `mappend` defaultContext
