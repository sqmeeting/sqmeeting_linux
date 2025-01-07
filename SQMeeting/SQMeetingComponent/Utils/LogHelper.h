#pragma once

#include <log4cplus/logger.h>
#include <log4cplus/configurator.h>
#include <log4cplus/loggingmacros.h>
#include <log4cplus/fileappender.h>
#include <log4cplus/layout.h>

#include "wchar.h"

#define ENABLE_DEBUG_LOG 1

#if defined _WIN32
#define __FILENAME__ (strrchr(__FILE__, '\\') ? (strrchr(__FILE__, '\\') + 1):__FILE__)
#else
#define __FILENAME__ (strrchr(__FILE__, '/') ? (strrchr(__FILE__, '/') + 1):__FILE__)
#endif

#define LOGGER log4cplus::Logger::getInstance("SQMEETING")

#if defined (UOS)
#define InitLog()   \
    log4cplus::initialize();    \ 
    log4cplus::BasicConfigurator baseConfig;    \
    baseConfig.configure(); \
    log4cplus::RollingFileAppender *appender = new log4cplus::RollingFileAppender("sqmeeting_log.log", 50 * 1024 * 1024, 4);    \
    std::auto_ptr<log4cplus::Layout> layout;    \
    layout.reset(new log4cplus::PatternLayout("[%D{%Y-%m-%d %H:%M:%S,%Q}][%t][%p] %m%n"));   \
    appender->setLayout(layout);    \
    LOGGER.addAppender(log4cplus::SharedAppenderPtr(appender)); \

#ifdef LOG4CPLUS_MACRO_FMT_BODY
    #undef LOG4CPLUS_MACRO_FMT_BODY
    #define LOG4CPLUS_MACRO_FMT_BODY(logger, logLevel, logFmt, ...)         \
        LOG4CPLUS_SUPPRESS_DOWHILE_WARNING()                                \
        do {                                                                \
            log4cplus::Logger const & _l                                    \
                = log4cplus::detail::macros_get_logger (logger);            \
            if (LOG4CPLUS_MACRO_LOGLEVEL_PRED (                             \
                    _l.isEnabledFor (log4cplus::logLevel), logLevel)) {     \
                LOG4CPLUS_MACRO_INSTANTIATE_SNPRINTF_BUF (_snpbuf);         \
                log4cplus::tchar const * _logEvent                          \
                    = _snpbuf.print (logFmt, ##__VA_ARGS__);                  \
                log4cplus::detail::macro_forced_log (_l,                    \
                    log4cplus::logLevel, _logEvent,                         \
                    __FILE__, __LINE__, LOG4CPLUS_MACRO_FUNCTION ());       \
            }                                                               \
        } while(0)                                                          \
        LOG4CPLUS_RESTORE_DOWHILE_WARNING()
#endif

#define ErrorLog(fmt, ...)      LOG4CPLUS_MACRO_FMT_BODY (LOGGER, ERROR_LOG_LEVEL, fmt, ##__VA_ARGS__)
#define WarnLog(fmt, ...)       LOG4CPLUS_MACRO_FMT_BODY (LOGGER, WARN_LOG_LEVEL, fmt, ##__VA_ARGS__)
#define InfoLog(fmt, ...)       LOG4CPLUS_MACRO_FMT_BODY (LOGGER, INFO_LOG_LEVEL, fmt, ##__VA_ARGS__)

#if ENABLE_DEBUG_LOG
    #define DebugLog(fmt, ...)      LOG4CPLUS_MACRO_FMT_BODY (LOGGER, DEBUG_LOG_LEVEL, fmt, ##__VA_ARGS__)
#else
    #define DebugLog(fmt, ...)
#endif

#elif defined (__APPLE__)
#define InitLog()   \
        log4cplus::initialize();    \
        log4cplus::BasicConfigurator baseConfig;    \
        baseConfig.configure(); \
        log4cplus::RollingFileAppender *appender = new log4cplus::RollingFileAppender("sqmeeting_log.log", 50 * 1024 * 1024, 4);    \
        std::unique_ptr<log4cplus::Layout> layout;    \
        layout.reset(new log4cplus::PatternLayout("[%D{%Y-%m-%d %H:%M:%S,%Q}][%t][%p] %l %m%n"));   \
        appender->setLayout(std::move(layout));   \
        LOGGER.addAppender(log4cplus::SharedAppenderPtr(appender)); \

#define ErrorLog(fmt, ...)      LOG4CPLUS_ERROR_FMT(LOGGER, fmt, ##__VA_ARGS__)
#define WarnLog(fmt, ...)       LOG4CPLUS_WARN_FMT(LOGGER, fmt, ##__VA_ARGS__)
#define InfoLog(fmt, ...)       LOG4CPLUS_INFO_FMT(LOGGER, fmt, ##__VA_ARGS__)

#if ENABLE_DEBUG_LOG
    #define DebugLog(fmt, ...)      LOG4CPLUS_DEBUG_FMT(LOGGER, fmt, ##__VA_ARGS__)
#else
    #define DebugLog(fmt, ...)
#endif

#elif defined (WIN32)
#endif
