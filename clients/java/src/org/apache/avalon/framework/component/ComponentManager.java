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

/**
 * A <code>ComponentManager</code> selects <code>Component</code>s based on a
 * role.  The contract is that all the <code>Component</code>s implement the
 * differing roles and there is one <code>Component</code> per role.  If you
 * need to select on of many <code>Component</code>s that implement the same
 * role, then you need to use a <code>ComponentSelector</code>.  Roles are
 * usually the full interface name.
 *
 * <p>
 * A role is better understood by the analogy of a play.  There are many
 * different roles in a script.  Any actor or actress can play any given part
 * and you get the same results (phrases said, movements made, etc.).  The exact
 * nuances of the performance is different.
 * </p>
 *
 * <p>
 * Below is a list of things that might be considered the different roles:
 * </p>
 *
 * <ul>
 *   <li> InputAdapter and OutputAdapter</li>
 *   <li> Store and Spool</li>
 * </ul>
 *
 * <p>
 * The <code>ComponentManager</code> does not specify the methodology of
 * getting the <code>Component</code>, merely the interface used to get it.
 * Therefore the <code>ComponentManager</code> can be implemented with a
 * factory pattern, an object pool, or a simple Hashtable.
 * </p>
 *
 * <p>
 *  <span style="color: red">Deprecated: </span><i>
 *    Use {@link org.apache.avalon.framework.service.ServiceManager} instead.
 *  </i>
 * </p>
 *
 * @see org.apache.avalon.framework.component.Component
 * @see org.apache.avalon.framework.component.Composable
 * @see org.apache.avalon.framework.component.ComponentSelector
 *
 * @author <a href="mailto:dev@avalon.apache.org">Avalon Development Team</a>
 * @version CVS $Revision: 1.21 $ $Date: 2004/02/11 14:34:24 $
 */
public interface ComponentManager
{
    /**
     * Get the <code>Component</code> associated with the given key.  For
     * instance, If the <code>ComponentManager</code> had a
     * <code>LoggerComponent</code> stored and referenced by key, I would use
     * the following call:
     * <pre>
     * try
     * {
     *     LoggerComponent log;
     *     myComponent = (LoggerComponent) m_manager.lookup(LoggerComponent.ROLE);
     * }
     * catch (...)
     * {
     *     ...
     * }
     * </pre>
     *
     * @param key The key name of the <code>Component</code> to retrieve.
     * @return the desired component
     * @throws ComponentException if an error occurs
     */
    Component lookup( String key )
        throws ComponentException;

    /**
     * Check to see if a <code>Component</code> exists for a key.
     *
     * @param key  a string identifying the key to check.
     * @return True if the component exists, False if it does not.
     */
    boolean hasComponent( String key );

    /**
     * Return the <code>Component</code> when you are finished with it.  This
     * allows the <code>ComponentManager</code> to handle the End-Of-Life Lifecycle
     * events associated with the Component.  Please note, that no Exceptions
     * should be thrown at this point.  This is to allow easy use of the
     * ComponentManager system without having to trap Exceptions on a release.
     *
     * @param component The Component we are releasing.
     */
    void release( Component component );
}
