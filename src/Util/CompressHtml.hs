module Util.CompressHtml (
    compressHtml
) where

import Hakyll

import qualified Data.Monoid as Monoid

compressHtml :: String -> String
compressHtml source = compressWithoutPre
    $ compressInTags
    $ removeComments source

compressWithoutPre :: String -> String
compressWithoutPre "" = ""
compressWithoutPre source = case separatePre False source of
    (before, pretxt, after) ->
        (compressSpaces $ compressAroundTags before)
        ++ pretxt
        ++ compressWithoutPre after

-- (before, "<pre> ~ </pre>", after)
separatePre :: Bool -> String -> (String, String, String)
separatePre _ "" = ("", "", "")
separatePre True ('<':'p':'r':'e':source) = case separatePre True source of -- <pre>が入れ子になっている場合
    (_, pretxt, after) -> ("", "<pre" ++ pretxt, "") `Monoid.mappend` separatePre True after
separatePre False ('<':'p':'r':'e':source) = ("", "<pre", "") `Monoid.mappend` separatePre True source
separatePre _ ('<':'/':'p':'r':'e':'>':source) = ("", "</pre>", source)
separatePre True (c:source) = ("", [c], "") `Monoid.mappend` separatePre True source
separatePre _ (c:source) = ([c], "", "") `Monoid.mappend` separatePre False source

compressSpaces :: String -> String
compressSpaces source =
    replaceAll "[[:space:]]+" (const " ")
    $ replaceAll "[\n\r]" (const "") source

removeComments :: String -> String
removeComments "" = ""
removeComments ('<':'!':'-':'-':source) = removeComments $ dropComment source
removeComments (c:source) = c : (removeComments source)

dropComment :: String -> String
dropComment "" = ""
dropComment ('-':'-':'>':source) = source
dropComment (_:source) = dropComment source

compressInTags :: String -> String
compressInTags source =
    replaceAll "</ " (const "</")
    $ replaceAll "< " (const "<")
    $ replaceAll "[ /]*>" (const ">")
    $ replaceAll "<[^>]*>" compressSpaces source

compressAroundTags :: String -> String
compressAroundTags source =
    replaceAll "^[[:space:]]*<" (const "<")
    $ replaceAll ">[[:space:]]*$" (const ">")
    $ replaceAll ">[[:space:]]*<" (const "><") source
