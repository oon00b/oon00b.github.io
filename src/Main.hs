import Hakyll

import Css
import Pages
import Index.Tags
import Index.Archives
import Template

main :: IO()
main = hakyll $ do
    buildCss
    buildPages
    buildTagIndex
    buildArchives
    buildTemplate
