module Pages (
    buildPages
) where

import Hakyll

import Util
import Template

mdRoute :: Routes
mdRoute = gsubRoute "markdown/" (const "") `composeRoutes` setExtension "html"

mdCompiler :: FilePath -> Context String -> Compiler (Item String)
mdCompiler path2temp ctx = pandocCompiler
    >>= loadAndApplyTemplate temp ctx
    >>= relativizeUrls
    >>= return . fmap compressHtml
    where temp = fromFilePath path2temp

buildPages :: Rules()
buildPages = do

    let defaultctx = snippetField `mappend` defaultContext

    match (fromGlob "**/index.md") $ do
        route mdRoute
        compile $ mdCompiler "template/default.html" defaultctx

    match postPattern $ do
        route mdRoute
        compile $ mdCompiler "template/post.html" $ tagsContext `mappend` defaultctx
