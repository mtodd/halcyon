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
package org.apache.avalon.framework.component;

import org.apache.avalon.framework.CascadingException;

/**
 * The exception thrown to indicate a problem with Components.
 * It is usually thrown by ComponentManager or ComponentSelector.
 *
 * <p>
 *  <span style="color: red">Deprecated: </span><i>
 *    Use {@link org.apache.avalon.framework.service.ServiceException} instead.
 *  </i>
 * </p>
 *
 * @author <a href="mailto:dev@avalon.apache.org">Avalon Development Team</a>
 * @version CVS $Revision: 1.22 $ $Date: 2004/02/11 14:34:24 $
 */
public class ComponentException
    extends CascadingException
{
    private final String m_key;

    /**
     * Construct a new <code>ComponentException</code> instance.
     * @param key the lookup key
     * @param message the exception message
     * @param throwable the throwable
     */
    public ComponentException( final String key,
                               final String message,
                               final Throwable throwable )
    {
        super( message, throwable );
        m_key = key;
    }

    /**
     * Construct a new <code>ComponentException</code> instance.
     *
     * @deprecated use the String, String, Throwable version to record the role
     * @param message the exception message
     * @param throwable the throwable
     */
    public ComponentException( final String message, final Throwable throwable )
    {
        this( null, message, throwable );
    }

    /**
     * Construct a new <code>ComponentException</code> instance.
     *
     * @deprecated use the String, String version to record the role
     * @param message the exception message
     */
    public ComponentException( final String message )
    {
        this( null, message, null );
    }

    /**
     * Construct a new <code>ComponentException</code> instance.
     * @param key the lookup key
     * @param message the exception message
     */
    public ComponentException( final String key, final String message )
    {
        this( key, message, null );
    }

    /**
     * Get the key which let to the exception.  May be null.
     *
     * @return The key which let to the exception.
     */
    public final String getKey()
    {
        return m_key;
    }

    /**
     * Get the key which let to the exception.  May be null.
     *
     * @return The key which let to the exception.
     * @deprecated Use getKey instead
     */
    public final String getRole()
    {
        return getKey();
    }

    /**
     * Return a message describing the exception.
     *
     * @return exception message.
     */
    public String getMessage()
    {
        if( m_key == null )
        {
            return super.getMessage();
        }
        else
        {
            return super.getMessage() + " (key [" + m_key + "])";
        }
    }
}
