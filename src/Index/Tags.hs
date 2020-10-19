module Index.Tags (
    buildTagIndex
) where

import Hakyll

import Util
import Index

tagPageId :: String -> Identifier
tagPageId tag =
    fromFilePath $ "blog/tags/" ++ t ++ "/index.html"
    where t = replaceAll "/" (const "-") tag

buildTagIndex :: Rules()
buildTagIndex = do
    tags <- buildTags postPattern tagPageId
    tagsRules tags
        (\tag posts -> do
            route idRoute
            compile $ postIndexCompiler ("tag: " ++ tag) posts)
