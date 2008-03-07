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
 * A Serviceable is a class that need to connect to software components using
 * a "role" abstraction, thus not depending on particular implementations
 * but on behavioral interfaces.
 * <br />
 *
 * The contract surrounding a <code>Serviceable</code> is that it is a user.
 * The <code>Serviceable</code> is able to use <code>Object</code>s managed
 * by the <code>ServiceManager</code> it was initialized with.  As part
 * of the contract with the system, the instantiating entity must call
 * the <code>service</code> method before the <code>Serviceable</code>
 * can be considered valid.
 *
 * @author <a href="mailto:dev@avalon.apache.org">Avalon Development Team</a>
 * @version CVS $Revision: 1.19 $ $Date: 2004/02/11 14:34:25 $
 * @see org.apache.avalon.framework.service.ServiceManager
 *
 */
public interface Serviceable
{
    /**
     * Pass the <code>ServiceManager</code> to the <code>Serviceable</code>.
     * The <code>Serviceable</code> implementation should use the specified
     * <code>ServiceManager</code> to acquire the components it needs for
     * execution.
     *
     * @param manager The <code>ServiceManager</code> which this
     *                <code>Serviceable</code> uses. Must not be <code>null</code>.
     * @throws ServiceException if an error occurs
     */
    void service( ServiceManager manager )
        throws ServiceException;
}
