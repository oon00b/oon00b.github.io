module Css (
    buildCss
    , cssField
) where

import Hakyll
import qualified Hakyll.Web.Sass as Sass

cssField :: String -> Context String
cssField key = field "css" $ \_ -> do
    loadBody $ fromFilePath $ "scss/" ++ key ++ ".scss"

buildCss :: Rules()
buildCss = do
    match (fromGlob "scss/*.scss") $ do
        let opt = Sass.sassDefConfig {
                Sass.sassOutputStyle = Sass.SassStyleCompressed
            }
        compile $ Sass.sassCompilerWith opt
