module Util (
    postPattern
    , module Util.CompressHtml
) where

import Hakyll

import Util.CompressHtml

postPattern :: Pattern
postPattern = fromRegex "^markdown/blog/[0-9]{4}/(1[0-2]|0[0-9])/[[:print:]]*.md$"
