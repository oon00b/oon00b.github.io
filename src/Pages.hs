module Pages (
    buildPages
) where

import Hakyll

import Config
import CompressHtml
import Context

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
    -- default pages
    match (fromRegex "^markdown/([^/]{1,}/)*index.md$") $ do
        let ctx = snippetField `mappend` defaultContext
        route mdRoute
        compile $ mdCompiler "template/pages.html" ctx

    -- blog posts
    match postPattern $ do
        let ctx = snippetField
                `mappend` postDateContext
                `mappend` postTagsContext
                `mappend` archivesContext
                `mappend` tagsContext
                `mappend` defaultContext
        route mdRoute
        compile $ mdCompiler "template/blogpost.html" ctx
