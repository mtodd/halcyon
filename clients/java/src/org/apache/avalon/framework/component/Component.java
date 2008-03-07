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
 * This interface identifies classes that can be used as <code>Components</code>
 * by a <code>Composable</code>.
 *
 * <p>
 * The contract surrounding the <code>Component</code> is that it is
 * used, but not a user.  When a class implements this interface, it
 * is stating that other entities may use that class.
 * </p>
 *
 * <p>
 * A <code>Component</code> is the basic building block of the Avalon Framework.
 * When a class implements this interface, it allows itself to be
 * managed by a <code>ComponentManager</code> and used by an outside
 * element called a <code>Composable</code>.  The <code>Composable</code>
 * must know what type of <code>Component</code> it is accessing, so
 * it will re-cast the <code>Component</code> into the type it needs.
 * </p>
 *
 * <p>
 * In order for a <code>Component</code> to be useful you must either
 * extend this interface, or implement this interface in conjunction
 * with one that actually has methods.  The new interface is the contract
 * with the <code>Composable</code> that this is a particular type of
 * component, and as such it can perform those functions on that type
 * of component.
 * </p>
 *
 * <p>
 * For example, we want a component that performs a logging function
 * so we extend the <code>Component</code> to be a <code>LoggingComponent</code>.
 * </p>
 *
 * <pre>
 *   interface LoggingComponent
 *       extends Component
 *   {
 *       log(String message);
 *   }
 * </pre>
 *
 * <p>
 * Now all <code>Composable</code>s that want to use this type of component,
 * will re-cast the <code>Component</code> into a <code>LoggingComponent</code>
 * and the <code>Composable</code> will be able to use the <code>log</code>
 * method.
 * </p>
 *
 * <p>
 *  <span style="color: red">Deprecated: </span><i>
 *    Deprecated without replacement. Should only be used while migrating away
 *    from a system based on Composable/ComponentManager.  A generic <code>java.lang.Object</code>
 *    can be used as a replacement.
 *  </i>
 * </p>
 *
 * @author <a href="mailto:dev@avalon.apache.org">Avalon Development Team</a>
 * @version CVS $Revision: 1.16 $ $Date: 2004/02/11 14:34:24 $
 */
public interface Component
{
}
