{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}
import Yesod
import Yesod.Form
import Data.Text (Text)

data HelloWorld = HelloWorld

mkYesod "HelloWorld" [parseRoutes|
/ HomeR GET
/greet GreetR POST
|]

instance Yesod HelloWorld

instance RenderMessage HelloWorld FormMessage where
    renderMessage _ _ = defaultFormMessage

getHomeR :: Handler Html
getHomeR = do
    (personFormWidget, enctype) <- generateFormPost personForm
    defaultLayout $ do
        setTitle "Hello!"
        toWidget [whamlet|
            <h1>Hello, World!
            <form method=post action=@{GreetR} enctype=#{enctype}>
                ^{personFormWidget}
                <input type="submit"/>
        |]

data Person = Person { personName :: Text } deriving Show
personForm :: Html -> MForm Handler (FormResult Person, Widget)
personForm = renderDivs $ Person
    <$> areq textField "Name" Nothing

postGreetR :: Handler Html
postGreetR = do
    ((result, widget), enctype) <- runFormPost personForm
    case result of
        FormSuccess person -> defaultLayout [whamlet|Greetings, #{personName person}.|]
        FormFailure _ -> defaultLayout [whamlet|Hmm, form failure.|]
        _ -> defaultLayout [whamlet|Hmm, something was wrong.|]

main :: IO()
main = warp 3000 HelloWorld
