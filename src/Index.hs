module Index (
    buildIndex
) where

import Hakyll

import Config
import CompressHtml
import Archives
import Context

indexCompiler :: Context String -> Compiler (Item String)
indexCompiler ctx = makeItem ""
    >>= loadAndApplyTemplate (fromFilePath "template/blogindex.html") ctx
    >>= relativizeUrls . fmap compressHtml

buildIndex :: Rules()
buildIndex = do
    let commonctx pattern =
            snippetField
            `mappend` postListContext pattern
            `mappend` archivesContext
            `mappend` tagsContext
            `mappend` defaultContext

    -- blog index
    create [fromFilePath "blog/index.html"] $ do
        let ctx = constField "title" "Blog"
                `mappend` commonctx postPattern
        route idRoute
        compile $ indexCompiler ctx

    -- tags
    tags <- buildTags postPattern tagsId
    tagsRules tags $ \tag pattern -> do
        let ctx = constField "title" ("Tag: " ++ tag)
                `mappend` commonctx pattern
        route idRoute
        compile $ indexCompiler ctx

    -- archives
    yearly <- getArchives postPattern Yearly archivesId
    archivesRules yearly $ \_freq date pattern -> do
        let ctx = constField "title" (formatDate date "Archive: %0Y")
                `mappend` commonctx pattern
        route idRoute
        compile $ indexCompiler ctx

    monthly <- getArchives postPattern Monthly archivesId
    archivesRules monthly $ \_freq date pattern -> do
        let ctx = constField "title" (formatDate date "Archive: %0Y/%m")
                `mappend` commonctx pattern
        route idRoute
        compile $ indexCompiler ctx
