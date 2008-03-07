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
package org.apache.avalon.framework.configuration;

import org.apache.avalon.framework.CascadingException;

/**
 * Thrown when a <code>Configurable</code> component cannot be configured
 * properly, or if a value cannot be retrieved properly.
 *
 * @author <a href="mailto:dev@avalon.apache.org">Avalon Development Team</a>
 * @version CVS $Revision: 1.14 $ $Date: 2004/02/11 14:34:24 $
 */
public class ConfigurationException
    extends CascadingException
{
    private final Configuration m_config;

    /**
     * Construct a new <code>ConfigurationException</code> instance.
     *
     * @param config  The offending configuration object
     */
    public ConfigurationException( final Configuration config )
    {
        this( "Bad configuration: " + config.toString(), config );
    }

    /**
     * Construct a new <code>ConfigurationException</code> instance.
     *
     * @param message The detail message for this exception.
     */
    public ConfigurationException( final String message )
    {
        this( message, (Configuration) null );
    }

    /**
     * Construct a new <code>ConfigurationException</code> instance.
     *
     * @param message The detail message for this exception.
     * @param throwable the root cause of the exception
     */
    public ConfigurationException( final String message, final Throwable throwable )
    {
        this( message, null, throwable );
    }

    /**
     * Construct a new <code>ConfigurationException</code> instance.
     *
     * @param message The detail message for this exception.
     * @param config  The configuration object
     */
    public ConfigurationException( final String message, final Configuration config )
    {
        this( message, config, null );
    }

    /**
     * Construct a new <code>ConfigurationException</code> instance.
     *
     * @param message The detail message for this exception.
     * @param throwable the root cause of the exception
     */
    public ConfigurationException( final String message, final Configuration config, final Throwable throwable )
    {
        super( message, throwable );
        m_config = config;
    }

    public Configuration getOffendingConfiguration()
    {
        return m_config;
    }

    public String getMessage()
    {
        StringBuffer message = new StringBuffer(super.getMessage());

        if (null != m_config)
        {
            message.append("@");
            message.append(m_config.getLocation());
        }

        return message.toString();
    }
}
