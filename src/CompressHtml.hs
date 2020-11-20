module CompressHtml (
    compressHtml
) where

import Hakyll

import Data.Char

compressHtml :: String -> String
compressHtml source = compressWithoutPre $ removeComments source

compressWithoutPre :: String -> String
compressWithoutPre "" = ""
compressWithoutPre source = case separatePre source of
    (before, pretxt, after) ->
        compressSpaces before
        ++ pretxt
        ++ compressWithoutPre after

-- (before, "<pre> ~ </pre>", after)
separatePre :: String -> (String, String, String)
separatePre "" = ("", "", "")
separatePre ('<':'p':'r':'e':source) =
    let (pretxt, other) = takePre source
    in ("", "<pre" ++ pretxt, other)
separatePre (c:source) = ([c], "", "") `mappend` separatePre source

-- (" ~ </pre>", after)
takePre :: String -> (String, String)
takePre "" = ("", "")
takePre ('<':'/':'p':'r':'e':'>':source) = ("</pre>", source)
takePre ('<':'p':'r':'e':source) = -- <pre>が入れ子になっている場合
    let (pretxt, other) = takePre source
    in ("<pre" ++ pretxt, "") `mappend` takePre other
takePre (c:source) = ([c], "") `mappend` takePre source

compressSpaces :: String -> String
compressSpaces source =
    replaceAll "[[:space:]]+" (const " ")
    $ replaceAll "(>[\n\r]+)|([\n\r]+<)" (filter (not . isSpace)) source

removeComments :: String -> String
removeComments "" = ""
removeComments ('<':'!':'-':'-':source) = removeComments $ dropComment source
removeComments (c:source) = c : (removeComments source)

dropComment :: String -> String
dropComment "" = ""
dropComment ('-':'-':'>':source) = source
dropComment (_:source) = dropComment source
