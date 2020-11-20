module Css (
    buildCss
) where

import Hakyll
import qualified Hakyll.Web.Sass as Sass

import qualified Skylighting.Core as Sky

buildCss :: Rules()
buildCss = do
    match (fromGlob "scss/*.scss") $ do
        let opt = Sass.sassDefConfig {
                Sass.sassOutputStyle = Sass.SassStyleCompressed
            }
        route $ gsubRoute "scss/" (const "css/") `composeRoutes` setExtension "css"
        compile $ Sass.sassCompilerWith opt

    create [fromFilePath "css/highlight.css"] $ do
        route idRoute
        compile $ loadBody (fromFilePath "skylighting/theme/solarized-dark.theme")
            >>= return . Sky.parseTheme
            >>= return . either (const Sky.breezeDark) (\a -> a)
            >>= return . Sky.styleToCss
            >>= makeItem . compressCss

    -- Sky.parseThemeに渡すためthemeをByteString.Lazyとしてキャッシュしておく
    match (fromGlob "skylighting/theme/solarized-dark.theme") $ compile getResourceLBS
