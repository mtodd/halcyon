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
package org.apache.avalon.framework;

/**
 * Class from which all exceptions should inherit.
 * Allows recording of nested exceptions.
 *
 * @author <a href="mailto:dev@avalon.apache.org">Avalon Development Team</a>
 * @version CVS $Revision: 1.14 $ $Date: 2004/02/11 14:34:24 $
 */
public class CascadingRuntimeException
    extends RuntimeException
    implements CascadingThrowable
{
    private final Throwable m_throwable;

    /**
     * Construct a new <code>CascadingRuntimeException</code> instance.
     *
     * @param message The detail message for this exception.
     * @param throwable the root cause of the exception
     */
    public CascadingRuntimeException( final String message, final Throwable throwable )
    {
        super( message );
        m_throwable = throwable;
    }

    /**
     * Retrieve root cause of the exception.
     *
     * @return the root cause
     */
    public final Throwable getCause()
    {
        return m_throwable;
    }
}
