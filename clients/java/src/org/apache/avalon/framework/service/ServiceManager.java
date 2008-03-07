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

/**
 * A <code>ServiceManager</code> selects <code>Object</code>s based on a
 * role.  The contract is that all the <code>Object</code>s implement the
 * differing roles and there is one <code>Object</code> per role.  If you
 * need to select on of many <code>Object</code>s that implement the same
 * role, then you need to use a <code>ServiceSelector</code>.  Roles are
 * usually the full interface name.
 *
 * A role is better understood by the analogy of a play.  There are many
 * different roles in a script.  Any actor or actress can play any given part
 * and you get the same results (phrases said, movements made, etc.).  The exact
 * nuances of the performance is different.
 *
 * Below is a list of things that might be considered the different roles:
 *
 * <ul>
 *   <li> InputAdapter and OutputAdapter</li>
 *   <li> Store and Spool</li>
 * </ul>
 *
 * The <code>ServiceManager</code> does not specify the methodology of
 * getting the <code>Object</code>, merely the interface used to get it.
 * Therefore the <code>ServiceManager</code> can be implemented with a
 * factory pattern, an object pool, or a simple Hashtable.
 *
 * @author <a href="mailto:dev@avalon.apache.org">Avalon Development Team</a>
 * @version CVS $Revision: 1.17 $ $Date: 2004/02/11 14:34:25 $
 * @see org.apache.avalon.framework.service.Serviceable
 * @see org.apache.avalon.framework.service.ServiceSelector
 */
public interface ServiceManager
{
    /**
     * Get the <code>Object</code> associated with the given key.  For
     * instance, If the <code>ServiceManager</code> had a
     * <code>LoggerComponent</code> stored and referenced by key,
     * the following could be used:
     * <pre>
     * try
     * {
     *     LoggerComponent log;
     *     myComponent = (LoggerComponent) manager.lookup( LoggerComponent.ROLE );
     * }
     * catch (...)
     * {
     *     ...
     * }
     * </pre>
     *
     * @param key The lookup key of the <code>Object</code> to retrieve.
     * @return an <code>Object</code> value
     * @throws ServiceException if an error occurs
     */
    Object lookup( String key )
        throws ServiceException;

    /**
     * Check to see if a <code>Object</code> exists for a key.
     *
     * @param key a string identifying the key to check.
     * @return True if the object exists, False if it does not.
     */
    boolean hasService( String key );

    /**
     * Return the <code>Object</code> when you are finished with it.  This
     * allows the <code>ServiceManager</code> to handle the End-Of-Life Lifecycle
     * events associated with the <code>Object</code>.  Please note, that no
     * Exception should be thrown at this point.  This is to allow easy use of the
     * ServiceManager system without having to trap Exceptions on a release.
     *
     * @param object The <code>Object</code> we are releasing, may also be
     *               a <code>null</code> reference
     */
    void release( Object object );
}
