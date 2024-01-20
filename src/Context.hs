module Context (
    postDateContext
    , postTagsContext
    , postListContext
    , archivesContext
    , tagsContext
) where

import Hakyll

import Prelude hiding (head, id, div)

import Text.Blaze.Html
import Text.Blaze.Html5 (a, div, details, summary)
import Text.Blaze.Html5.Attributes (class_, href)
import Text.Blaze.Html.Renderer.String

import Data.List

import qualified Data.Time as Time

import Config
import Archives

-- YYYY-MM-DD
postDateContext :: Context String
postDateContext = dateField "post-date" "%0Y-%m-%d"

-- [<a>TAG</a>] ...
postTagsContext :: Context String
postTagsContext = field "post-tags" $ \item -> do
    tags <- buildTags (fromList $ [itemIdentifier item]) tagsId
    renderTags markup (concat . intersperse " ") tags
    where
        markup tag url _cnt _min _max =
            "[" ++ renderHtml (a ! (href $ stringValue url) $ string tag) ++ "]"

postListContext :: Pattern -> Context String
postListContext pattern =
    let posts = loadAll pattern >>= recentFirst
        ctx = defaultContext
            <> postTagsContext
            <> postDateContext
    in listField "post-list" ctx posts

-- <details class="archives-tree">
--      <summary><a>TITLE</a>(COUNT)/</summary>
--      (<details class="archives-tree"> ... </details>
--      | <div class="archives-post"><a>POST</a></div>) ...
-- </details> ...
archivesContext :: Context String
archivesContext = field "archives" $ \_ -> do
    archives <- getArchives postPattern Yearly archivesId
    renderArchives markupArchives archives

markupArchives :: Frequency -> Time.Day -> [Identifier] -> FilePath -> Compiler String
markupArchives freq date posts url =
    let title = formatDate date
            (case freq of
            Yearly -> "%0Y"
            Monthly -> "%0Y/%m")

        wrapper child =
            let details' =
                    details
                    ! (class_ $ stringValue "archives-tree")
                    $ toMarkup [summary', preEscapedString child]

                summary' =
                    summary $ toMarkup
                    [link, string $ "(" ++ (show $ length posts) ++ ")/"]

                link = a ! (href $ stringValue url) $ string title

            in renderHtml details'

        inner =
            if freq == minBound then
                sortRecentFirst posts >>= fmap concat . mapM markupArchivesPost
            else getArchives (fromList posts) (pred freq) archivesId
                >>= renderArchives markupArchives

    in fmap wrapper inner

markupArchivesPost :: Identifier -> Compiler String
markupArchivesPost post = do
    m_title <- getMetadata post >>= return . lookupString "title"
    m_route <- getRoute post

    case (m_title, m_route) of
        (Just t, Just r) ->
            let wrapper = div ! (class_ $ stringValue "archives-post")
                link = a ! (href $ stringValue $ toUrl r) $ string t
            in return $ renderHtml $ wrapper link
        _ -> return ""

-- <a>TAG</a>(COUNT), ...
tagsContext :: Context String
tagsContext = field "tags" $ \_ ->
    buildTags postPattern tagsId
    >>= renderTags markup (concat . intersperse ", ")
    where
        markup tag url count _min _max =
            renderHtml $ toMarkup
            [a ! (href $ stringValue url) $ string tag
            , string $ "(" ++ show count ++ ")"]
