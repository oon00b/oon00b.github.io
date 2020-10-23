module Index.Tags (
    buildTagIndex
) where

import Hakyll

import Util
import Index

tagsId :: String -> Identifier
tagsId tag =
    fromFilePath $ "blog/tags/" ++ t ++ "/index.html"
    where t = replaceAll "/" (const "-") tag

buildTagIndex :: Rules()
buildTagIndex = do
    tags <- buildTags postPattern tagsId
    tagsRules tags
        (\tag posts -> do
            route idRoute
            compile $ postIndexCompiler ("Tag: " ++ tag) posts)
