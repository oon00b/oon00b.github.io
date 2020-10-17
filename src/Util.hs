module Util (
    percentEncode
    , postPattern
    , mdRoute
    , module Util.CompressHtml
) where

import Hakyll

import qualified Network.URI as URI

import Util.CompressHtml

-- [[:alnum:]],[-_.~]以外の文字をエスケープする
-- https://tools.ietf.org/html/rfc3986#section-2.3
percentEncode :: String -> String
percentEncode str = URI.escapeURIString URI.isUnreserved str

postPattern :: Pattern
postPattern = fromRegex "^markdown/blog/[0-9]{4}/(1[0-2]|0[0-9])/[[:print:]]*.md$"

mdRoute :: Routes
mdRoute = gsubRoute "markdown/" (const "") `composeRoutes` setExtension "html"
