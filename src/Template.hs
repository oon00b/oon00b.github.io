module Template (
    tagsContext
    , buildTemplate
) where

import Hakyll

tagsContext :: Context String
tagsContext = listFieldWith "tags" tagsElemContext $ \item -> do
    getMetadata $ itemIdentifier item
    >>= return . lookupStringList "tags"
    >>= return . maybe [] (\a -> a)
    >>= sequence . map makeItem

tagsElemContext :: Context String
tagsElemContext = field "tag" (return . itemBody)

buildTemplate :: Rules()
buildTemplate = do
    match (fromGlob "template/*.html") $ compile templateCompiler
    match (fromGlob "template/snippet/*.html") $ compile getResourceBody
