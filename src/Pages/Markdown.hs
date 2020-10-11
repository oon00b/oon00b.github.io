module Pages.Markdown (
    buildMarkdown
) where

import Hakyll

import Pages.CompressHtml
import Pages.Template

mdRoute :: Routes
mdRoute = gsubRoute "markdown/" (const "") `composeRoutes` setExtension "html"

mdCompiler :: FilePath -> Context String -> Compiler (Item String)
mdCompiler path2temp ctx = pandocCompiler
    >>= loadAndApplyTemplate temp ctx
    >>= relativizeUrls
    >>= return . fmap compressHtml
    where temp = fromFilePath path2temp

buildMarkdown :: Rules()
buildMarkdown = do
    match (fromGlob "**/index.md") $ do
        route mdRoute
        compile $ mdCompiler "template/default.html" defaultContext

    match (fromGlob "markdown/blog/*/*/*.md") $ do
        route mdRoute
        compile $ mdCompiler "template/blogpost.html" $ defaultContext `mappend` tagsContext
