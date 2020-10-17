import Hakyll

import Css
import Pages
import Index.Tags
import Template

main :: IO()
main = hakyll $ do
    buildCss
    buildPages
    buildTagIndex
    buildTemplate
