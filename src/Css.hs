module Css (
    buildCss
) where

import Hakyll
import qualified Hakyll.Web.Sass as Sass

import qualified Skylighting.Core as Sky

scssRoute :: Routes
scssRoute = gsubRoute "scss/" (const "css/") `composeRoutes` setExtension "css"

scssCompiler :: Compiler (Item String)
scssCompiler = Sass.sassCompilerWith opt
    where opt = Sass.sassDefConfig {
        Sass.sassOutputStyle = Sass.SassStyleCompressed
    }

highlightCssCompiler :: Compiler (Item String)
highlightCssCompiler =
    loadBody (fromFilePath "skylighting/theme/solarized-dark.theme")
    >>= return . Sky.parseTheme
    >>= return . either (const Sky.breezeDark) (\a -> a)
    >>= return . Sky.styleToCss
    >>= makeItem . compressCss

buildCss :: Rules()
buildCss = do
    match (fromGlob "scss/**") $ do
        route scssRoute
        compile scssCompiler

    create [fromFilePath "css/highlight.css"] $ do
        route idRoute
        compile highlightCssCompiler

    -- Sky.parseThemeに渡すためthemeをByteString.Lazyとしてキャッシュしておく
    match (fromGlob "skylighting/theme/solarized-dark.theme") $ compile getResourceLBS
