{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}
import Prelude hiding (length)
import Yesod
import Yesod.Form
import Data.Text (Text, length, pack)
import Data.Text.Read (decimal)
import System.Environment
import System.IO (hPutStrLn, stderr)
import System.Exit

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

readPort :: IO (Maybe Int)
readPort = do
    portStr <- fmap pack $ getEnv "PORT"
    let eitherPort = decimal portStr
    case eitherPort of
        Left error -> do
            hPutStrLn stderr ("Could not get PORT: " ++ error)
            return Nothing
        Right (port, remainder) -> do
            if (length remainder) > 0 then do
                hPutStrLn stderr "Port is not an integer"
                return Nothing
            else
                return $ Just port

main :: IO()
main = do
        maybePort <- readPort
        case maybePort of
            Nothing -> exitWith $ ExitFailure 1
            Just port -> do
                putStrLn $ "Listening on port " ++ show port
                warp port HelloWorld
