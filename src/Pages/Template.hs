module Pages.Template (
    tagsContext
  , buildTemplate
) where

import Hakyll

tagsContext :: Context String
tagsContext = listField "tags" (field "tag" (return . itemBody)) $ do
    getUnderlying
    >>= getMetadata
    >>= return . lookupStringList "tags"
    >>= return . maybe [] (\a -> a)
    >>= sequence . map makeItem

buildTemplate :: Rules()
buildTemplate = match (fromGlob "template/**") $ compile templateCompiler
