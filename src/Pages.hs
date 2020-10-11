module Pages (
    buildPages
) where

import Hakyll

import Pages.Markdown
import Pages.Template

buildPages :: Rules()
buildPages = do
    buildMarkdown
    buildTemplate
