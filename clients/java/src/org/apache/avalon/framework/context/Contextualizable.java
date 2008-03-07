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
package org.apache.avalon.framework.context;

/**
 * This inteface should be implemented by components that need
 * a Context to work. Context contains runtime generated object
 * provided by the Container to this Component.
 *
 * @author <a href="mailto:dev@avalon.apache.org">Avalon Development Team</a>
 * @version CVS $Revision: 1.15 $ $Date: 2004/02/11 14:34:25 $
 */
public interface Contextualizable
{
    /**
     * Pass the Context to the component.
     * This method is called after the Loggable.setLogger() (if present)
     * method and before any other method.
     *
     * @param context the context. Must not be <code>null</code>.
     * @throws ContextException if context is invalid
     */
    void contextualize( Context context )
        throws ContextException;
}
