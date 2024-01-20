module Index (
    buildIndex
) where

import Hakyll

import Config
import CompressHtml
import Archives
import Context
import Css

indexCompiler :: Context String -> Compiler (Item String)
indexCompiler ctx = makeItem ""
    >>= loadAndApplyTemplate (fromFilePath "template/blogindex.html") ctx
    >>= relativizeUrls . fmap compressHtml

buildIndex :: Rules()
buildIndex = do
    let commonctx pattern =
            defaultContext
            <> snippetField
            <> postListContext pattern
            <> archivesContext
            <> tagsContext
            <> cssField "blogindex"

    -- blog index
    create [fromFilePath "blog/index.html"] $ do
        let ctx = constField "title" "Blog"
                <> commonctx postPattern
        route idRoute
        compile $ indexCompiler ctx

    -- tags
    tags <- buildTags postPattern tagsId
    tagsRules tags $ \tag pattern -> do
        let ctx = constField "title" ("Tag: " ++ tag)
                <> commonctx pattern
        route idRoute
        compile $ indexCompiler ctx

    -- archives
    yearly <- getArchives postPattern Yearly archivesId
    archivesRules yearly $ \_freq date pattern -> do
        let ctx = constField "title" (formatDate date "Archive: %0Y")
                <> commonctx pattern
        route idRoute
        compile $ indexCompiler ctx

    monthly <- getArchives postPattern Monthly archivesId
    archivesRules monthly $ \_freq date pattern -> do
        let ctx = constField "title" (formatDate date "Archive: %0Y/%m")
                <> commonctx pattern
        route idRoute
        compile $ indexCompiler ctx
