module Network.Wai.Logger.Prefork (
    logCheck
  , logInit
  , logController
  , LogController
  , LogType(..)
  , FileLogSpec(..)
  ) where

import Control.Concurrent
import Control.Monad
import Network.Wai.Logger
import Network.Wai.Logger.Prefork.File
import Network.Wai.Logger.Prefork.Types
import System.Log.FastLogger

-- |
-- Checking if a log file can be written if 'LogType' is 'LogFile'.
logCheck :: LogType -> IO ()
logCheck LogNone          = return ()
logCheck LogStdout        = return ()
logCheck (LogFile spec _) = check spec

-- |
-- Creating 'ApacheLogger' according to 'LogType'.
logInit :: IPAddrSource -> LogType -> IO ApacheLogger
logInit _ LogNone                   = noLoggerInit
logInit ipsrc LogStdout             = stdoutApacheLoggerInit ipsrc True
logInit ipsrc (LogFile spec signal) = fileLoggerInit ipsrc spec signal

noLoggerInit :: IO ApacheLogger
noLoggerInit = return noLogger
  where
    noLogger _ _ _ = return ()

-- |
-- Creating a log controller against child processes.
logController :: LogType -> LogController
logController LogNone               = noLoggerController
logController LogStdout             = noLoggerController
logController (LogFile spec signal) = fileLoggerController spec signal

noLoggerController :: LogController
noLoggerController _ = forever $ threadDelay maxBound
