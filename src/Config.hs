module Config (
    postPattern
    , archivesId
    , tagsId
) where

import Hakyll

import qualified Data.Time as Time

import Archives

postPattern :: Pattern
postPattern = fromRegex "^markdown/blog/[0-9]{4}/(1[0-2]|0[1-9])/[^/]+/index[.]md$"

archivesId :: Frequency -> Time.Day -> Identifier
archivesId freq date = fromFilePath $
    "blog"
    ++ formatDate date format
    ++ "index.html"
    where format = case freq of
            Yearly -> "/%0Y/"
            Monthly -> "/%0Y/%m/"

tagsId :: String -> Identifier
tagsId tag =
    fromFilePath $ "blog/tags/" ++ t ++ "/index.html"
    -- タグに含まれる"/"を"-"に正規化する
    where t = replaceAll "/" (const "-") tag
