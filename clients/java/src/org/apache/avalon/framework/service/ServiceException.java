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
package org.apache.avalon.framework.service;

import org.apache.avalon.framework.CascadingException;

/**
 * The exception thrown to indicate a problem with service.
 * It is usually thrown by ServiceManager or ServiceSelector.
 *
 * @author <a href="mailto:dev@avalon.apache.org">Avalon Development Team</a>
 * @version CVS $Revision: 1.21 $ $Date: 2004/02/11 14:34:25 $
 */
public class ServiceException
    extends CascadingException
{
    private final String m_key;

    /**
     * Construct a new <code>ServiceException</code> instance.
     *
     * @deprecated use the String,String,Throwable version instead
     * @param message the exception message
     * @param throwable the throwable
     */
    public ServiceException( final String message, final Throwable throwable )
    {
        this( null, message, throwable );
    }

    /**
     * Construct a new <code>ServiceException</code> instance.
     *
     * @param key the lookup key
     * @param message the exception message
     * @param throwable the throwable
     */
    public ServiceException( final String key, final String message, final Throwable throwable )
    {
        super( message, throwable );
        m_key = key;
    }

    /**
     * Construct a new <code>ServiceException</code> instance.
     *
     * @deprecated use the String,String version instead
     * @param message the exception message
     */
    public ServiceException( final String message )
    {
        this( null, message, null );
    }

    /**
     * Construct a new <code>ServiceException</code> instance.
     *
     * @param key the lookup key
     * @param message the exception message
     */
    public ServiceException( final String key, final String message )
    {
        this( key, message, null );
    }

    /**
     * Return the key that caused the exception.
     * @return the lookup key triggering the exception
     */
    public String getKey()
    {
        return m_key;
    }

    /**
     * Return the role that caused the exception
     *
     * @deprecated Use getKey() instead
     * @return the the lookup key triggering the exception
     */
    public String getRole()
    {
        return getKey();
    }

    /**
     * Override super's message to add role if applicable.
     * @return a message.
     */
    public String getMessage()
    {
        if( m_key == null )
        {
            return super.getMessage();
        }
        else
        {
            return super.getMessage() + " (Key='" + m_key + "')";
        }
    }
}
