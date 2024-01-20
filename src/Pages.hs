module Pages (
    buildPages
) where

import Hakyll
import qualified Text.Pandoc.Options as Pandoc

import Config
import CompressHtml
import Context
import Css

mdRoute :: Routes
mdRoute = gsubRoute "markdown/" (const "") `composeRoutes` setExtension "html"

mdCompiler :: FilePath -> Context String -> Compiler (Item String)
mdCompiler tempPath ctx = pandocCompilerWith defaultHakyllReaderOptions wopt
    >>= loadAndApplyTemplate (fromFilePath tempPath) ctx
    >>= relativizeUrls
    >>= return . fmap compressHtml
    where wopt = defaultHakyllWriterOptions {
        Pandoc.writerHighlightStyle = Nothing
    }

buildPages :: Rules()
buildPages = do
    -- default pages
    match (fromRegex "^markdown/(about/){0,1}index.md$") $ do
        let ctx = defaultContext
                <> snippetField
                <> cssField "pages"
        route mdRoute
        compile $ mdCompiler "template/pages.html" ctx

    -- blog posts
    match postPattern $ do
        let ctx = defaultContext
                <> snippetField
                <> postDateContext
                <> postTagsContext
                <> archivesContext
                <> tagsContext
                <> snippetField
                <> cssField "blogpost"
        route mdRoute
        compile $ mdCompiler "template/blogpost.html" ctx
