/*
 * Copyright 1997-2004 The Apache Software Foundation
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.avalon.framework.logger;

/**
 * This is a facade for the different logging subsystems.
 * It offers a simplified interface that follows IOC patterns
 * and a simplified priority/level/severity abstraction.
 *
 * @author <a href="mailto:dev@avalon.apache.org">Avalon Development Team</a>
 * @version CVS $Revision: 1.16 $ $Date: 2004/02/11 14:34:25 $
 */
public interface Logger
{
    /**
     * Log a debug message.
     *
     * @param message the message
     */
    void debug( String message );

    /**
     * Log a debug message.
     *
     * @param message the message
     * @param throwable the throwable
     */
    void debug( String message, Throwable throwable );

    /**
     * Determine if messages of priority "debug" will be logged.
     *
     * @return true if "debug" messages will be logged
     */
    boolean isDebugEnabled();

    /**
     * Log a info message.
     *
     * @param message the message
     */
    void info( String message );

    /**
     * Log a info message.
     *
     * @param message the message
     * @param throwable the throwable
     */
    void info( String message, Throwable throwable );

    /**
     * Determine if messages of priority "info" will be logged.
     *
     * @return true if "info" messages will be logged
     */
    boolean isInfoEnabled();

    /**
     * Log a warn message.
     *
     * @param message the message
     */
    void warn( String message );

    /**
     * Log a warn message.
     *
     * @param message the message
     * @param throwable the throwable
     */
    void warn( String message, Throwable throwable );

    /**
     * Determine if messages of priority "warn" will be logged.
     *
     * @return true if "warn" messages will be logged
     */
    boolean isWarnEnabled();

    /**
     * Log a error message.
     *
     * @param message the message
     */
    void error( String message );

    /**
     * Log a error message.
     *
     * @param message the message
     * @param throwable the throwable
     */
    void error( String message, Throwable throwable );

    /**
     * Determine if messages of priority "error" will be logged.
     *
     * @return true if "error" messages will be logged
     */
    boolean isErrorEnabled();

    /**
     * Log a fatalError message.
     *
     * @param message the message
     */
    void fatalError( String message );

    /**
     * Log a fatalError message.
     *
     * @param message the message
     * @param throwable the throwable
     */
    void fatalError( String message, Throwable throwable );

    /**
     * Determine if messages of priority "fatalError" will be logged.
     *
     * @return true if "fatalError" messages will be logged
     */
    boolean isFatalErrorEnabled();

    /**
     * Create a new child logger.
     * The name of the child logger is [current-loggers-name].[passed-in-name]
     * Throws <code>IllegalArgumentException</code> if name has an empty element name
     *
     * @param name the subname of this logger
     * @return the new logger
     */
    Logger getChildLogger( String name );
}
