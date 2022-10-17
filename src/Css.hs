module Css (
    buildCss
) where

import Hakyll
import qualified Hakyll.Web.Sass as Sass

buildCss :: Rules()
buildCss = do
    match (fromGlob "scss/*.scss") $ do
        let opt = Sass.sassDefConfig {
                Sass.sassOutputStyle = Sass.SassStyleCompressed
            }
        route $ gsubRoute "scss/" (const "css/") `composeRoutes` setExtension "css"
        compile $ Sass.sassCompilerWith opt
