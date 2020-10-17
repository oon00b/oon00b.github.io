module Pages (
    buildPages
) where

import Hakyll

import Util
import Template

mdCompiler :: FilePath -> Context String -> Compiler (Item String)
mdCompiler path2temp ctx = pandocCompiler
    >>= loadAndApplyTemplate temp ctx
    >>= relativizeUrls
    >>= return . fmap compressHtml
    where temp = fromFilePath path2temp

buildPages :: Rules()
buildPages = do
    match (fromGlob "**/index.md") $ do
        route mdRoute
        compile $ mdCompiler "template/default.html" defaultContext

    match postPattern $ do
        route mdRoute
        compile $ mdCompiler "template/post.html" $ defaultContext `mappend` tagsContext
