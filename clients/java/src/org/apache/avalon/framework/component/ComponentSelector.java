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
 * A <code>ComponentSelector</code> selects <code>Component</code>s based on a
 * hint.  The contract is that all the <code>Component</code>s implement the
 * same role.
 *
 * <p>
 * A role is better understood by the analogy of a play.  There are many
 * different roles in a script.  Any actor or actress can play any given part
 * and you get the same results (phrases said, movements made, etc.).  The exact
 * nuances of the performance is different.
 * </p>
 *
 * <p>
 * Below is a list of things that might be considered the same role:
 * </p>
 *
 * <ul>
 *   <li> XMLInputAdapter and PropertyInputAdapter</li>
 *   <li> FileGenerator   and SQLGenerator</li>
 * </ul>
 *
 * <p>
 * The <code>ComponentSelector</code> does not specify the methodology of
 * getting the <code>Component</code>, merely the interface used to get it.
 * Therefore the <code>ComponentSelector</code> can be implemented with a
 * factory pattern, an object pool, or a simple Hashtable.
 * </p>
 *
 * <p>
 *  <span style="color: red">Deprecated: </span><i>
 *    Use {@link org.apache.avalon.framework.service.ServiceSelector} instead.
 *  </i>
 * </p>
 *
 * @see org.apache.avalon.framework.component.Component
 * @see org.apache.avalon.framework.component.Composable
 * @see org.apache.avalon.framework.component.ComponentManager
 *
 * @author <a href="mailto:dev@avalon.apache.org">Avalon Development Team</a>
 * @version CVS $Revision: 1.21 $ $Date: 2004/02/11 14:34:24 $
 */
public interface ComponentSelector
    extends Component
{
    /**
     * Select the <code>Component</code> associated with the given hint.
     * For instance, If the <code>ComponentSelector</code> has a
     * <code>Generator</code> stored and referenced by a URL, I would use the
     * following call:
     *
     * <pre>
     * try
     * {
     *     Generator input;
     *     input = (Generator)selector.select( new URL("foo://demo/url") );
     * }
     * catch (...)
     * {
     *     ...
     * }
     * </pre>
     *
     * @param hint A hint to retrieve the correct <code>Component</code>.
     * @return the desired component
     * @throws ComponentException If the given role is not associated
     *                               with a <code>Component</code>, or a
     *                               <code>Component</code> instance cannot
     *                               be created.
     */
    Component select( Object hint )
        throws ComponentException;

    /**
     * Check to see if a <code>Component</code> exists for a hint.
     *
     * @param hint  a string identifying the role to check.
     * @return True if the component exists, False if it does not.
     */
    boolean hasComponent( Object hint );

    /**
     * Return the <code>Component</code> when you are finished with it.  This
     * allows the <code>ComponentSelector</code> to handle the End-Of-Life Lifecycle
     * events associated with the Component.  Please note, that no Exceptions
     * should be thrown at this point.  This is to allow easy use of the
     * ComponentSelector system without having to trap Exceptions on a release.
     *
     * @param component The Component we are releasing.
     */
    void release( Component component );
}
