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
 * A <code>Composable</code> class is one that needs to connect to software
 * components using a "role" abstraction, thus not depending on particular
 * implementations but on behavioral interfaces.
 *
 * <p>
 * The contract surrounding a <code>Composable</code> is that it is a user.
 * The <code>Composable</code> is able to use <code>Components</code> managed
 * by the <code>ComponentManager</code> it was initialized with.  As part
 * of the contract with the system, the instantiating entity must call
 * the <code>compose</code> method before the <code>Composable</code>
 * can be considered valid.
 * </p>
 *
 * <p>
 *  <span style="color: red">Deprecated: </span><i>
 *    Use {@link org.apache.avalon.framework.service.Serviceable} instead.
 *  </i>
 * </p>
 *
 * @author <a href="mailto:dev@avalon.apache.org">Avalon Development Team</a>
 * @version CVS $Revision: 1.21 $ $Date: 2004/02/11 14:34:24 $
 */
public interface Composable
{
    /**
     * Pass the <code>ComponentManager</code> to the <code>composer</code>.
     * The <code>Composable</code> implementation should use the specified
     * <code>ComponentManager</code> to acquire the components it needs for
     * execution.
     *
     * @param componentManager The <code>ComponentManager</code> which this
     *                <code>Composable</code> uses. Must not be <code>null</code>.
     * @throws ComponentException if an error occurs
     */
    void compose( ComponentManager componentManager )
        throws ComponentException;
}
