{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}
import Prelude hiding (length)
import Yesod
import Yesod.Form
import Control.Exception (tryJust)
import Control.Monad (guard)
import Data.Text (Text, length, pack)
import Data.Text.Read (decimal)
import System.Environment
import System.IO (hPutStrLn, stderr)
import System.Exit
import System.IO.Error (isDoesNotExistError)

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

defaultPort = 80

readPort :: IO (Int)
readPort = do
    r <- tryJust (guard . isDoesNotExistError) $ getEnv "PORT"
    case r of
        Left error -> do
            hPutStrLn stderr ("Could not get PORT: " ++ show error)
            return defaultPort
        Right portStr -> do
            let portText = pack portStr
            let eitherPort = decimal portText
            case eitherPort of
                Left error -> do
                    hPutStrLn stderr ("Port is not an integer: " ++ error)
                    return defaultPort
                Right (port, remainder) -> do
                    if (length remainder) > 0 then do
                        hPutStrLn stderr "Port is not an integer; what's that leftover crap?"
                        return defaultPort
                    else
                        return port

main :: IO()
main = do
        port <- readPort
        putStrLn $ "Listening on port " ++ show port
        warp port HelloWorld
