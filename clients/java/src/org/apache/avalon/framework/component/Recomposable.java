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
 * Extends composer to allow recomposing.
 *
 * @author <a href="mailto:dev@avalon.apache.org">Avalon Development Team</a>
 * @version CVS $Revision: 1.22 $ $Date: 2004/02/11 14:34:24 $
 * @deprecated Deprecated with no replacement.  The Recomposable interface is a legacy
 *    interface with no concrete contracts.  Rather than copy the design mistake
 *    to the "service" package, we no longer support this class.
 */
public interface Recomposable
    extends Composable
{
    /**
     * Repass the <code>ComponentManager</code> to the <code>composer</code>.
     * The <code>Composable</code> implementation should use the specified
     * <code>ComponentManager</code> to acquire the components it needs for
     * execution. It should also drop references to any components it
     * retrieved from old ComponentManager.
     *
     * @param componentManager The <code>ComponentManager</code> which this
     *                <code>Composable</code> uses.
     * @throws ComponentException if an error occurs
     */
    void recompose( ComponentManager componentManager )
        throws ComponentException;
}
