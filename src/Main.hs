import Hakyll

import Css
import Pages

main :: IO()
main = hakyll $ do
    buildCss
    buildPages
