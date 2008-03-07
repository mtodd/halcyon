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
 * A <code>ServiceSelector</code> selects {@link Object}s based on a
 * supplied policy.  The contract is that all the {@link Object}s implement the
 * same role.
 *
 * @author <a href="mailto:dev@avalon.apache.org">Avalon Development Team</a>
 * @version CVS $Revision: 1.16 $ $Date: 2004/02/11 14:34:25 $
 * @see org.apache.avalon.framework.service.Serviceable
 * @see org.apache.avalon.framework.service.ServiceSelector
 */
public interface ServiceSelector
{
    /**
     * Select the {@link Object} associated with the given policy.
     * For instance, If the {@link ServiceSelector} has a
     * <code>Generator</code> stored and referenced by a URL, the
     * following call could be used:
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
     * @param policy A criteria against which a {@link Object} is selected.
     *
     * @return an {@link Object} value
     * @throws ServiceException If the requested {@link Object} cannot be supplied
     */
    Object select( Object policy )
        throws ServiceException;

    /**
     * Check to see if a {@link Object} exists relative to the supplied policy.
     *
     * @param policy a {@link Object} containing the selection criteria
     * @return True if the component is available, False if it not.
     */
    boolean isSelectable( Object policy );

    /**
     * Return the {@link Object} when you are finished with it.  This
     * allows the {@link ServiceSelector} to handle the End-Of-Life Lifecycle
     * events associated with the {@link Object}.  Please note, that no
     * Exception should be thrown at this point.  This is to allow easy use of the
     * ServiceSelector system without having to trap Exceptions on a release.
     *
     * @param object The {@link Object} we are releasing, may also be a 
     *               <code>null</code> reference
     */
    void release( Object object );
}
