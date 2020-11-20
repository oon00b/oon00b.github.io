import Hakyll

import Css
import Pages
import Index

main :: IO()
main = hakyll $ do
    -- css
    buildCss

    -- pages & blog posts
    buildPages

    -- blog index
    buildIndex

    -- template
    match (fromGlob "template/*.html") $ compile templateCompiler
    match (fromGlob "template/snippet/*.html") $ compile getResourceBody
