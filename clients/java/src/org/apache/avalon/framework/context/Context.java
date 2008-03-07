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
 * <p>
 * The context is the interface through which the component and its
 * container communicate.
 * </p>
 * 
 * <p>
 * <i><b>Note:</b> In the text below there are several requirements that a
 * component may set up for a container. It is understood that a container 
 * does not have to satisfy those requirements in order to be Avalon-compliant. 
 * If a component says "I require X to run" a container may reply with "I don't 
 * have any X, so I'm not running you". The requirements here are the maximum
 * that a component may ask for, not the minimum a container must deliver. 
 * However, a container should document what it is and isn't capable of 
 * delivering.</i>
 * </p>
 * 
 * <p>Each Container-Component relationship involves defining a contract 
 * between the two entities. A Context contract is defined by (1) an optional 
 * target class, and (2) a set of context entries.
 * </p>
 *
 * <ol>
 *     <li>
 *     <p>
 *     The optional target class is an interface, called <code>T</code> below. 
 *     It is required that the component should be able to perform 
 *     the following operation:
 *     </p>
 *     
 *     <pre><code>    public void contextualize( Context context )
 *         throws ContextException
 *     {
 *         T tContext = (T) context;
 *     }</code></pre>
 *     
 *     <p>
 *     The container may choose any method to supply the component
 *     with a context instance cast-able to <code>T</code>.
 *     </p>
 *     
 *     <p>
 *     There is no requirement for <code>T</code> to extend the <code>Context</code>
 *     interface.
 *     </p>
 *     
 *     <p>
 *     <i><b>Warning:</b> A component that specifies this requirement will not
 *     be as portable as one that doesn't. Few containers
 *     support it. It is therefore discouraged for components
 *     to require a castable context.</i>
 *     </p>
 *     </li>
 *     
 *     <li>
 *     <p>
 *     The second part of the context contract defines the set
 *     of entries the component can access via the <code>Context.get()</code>
 *     method, where an entry consists of the key passed to <code>get()</code>
 *     and the expected return type (the class or interface).
 *     Optionally, an alias for the key name can be specified. The
 *     contract associated with a particular entry is defined in the
 *     container documentation.
 *     </p>
 *     
 *     <p>
 *     The class/interface <code>T</code> above may also have associated 
 *     meta-info that specifies entries, in which case these entries must 
 *     be supplied by the container in addition to any entries the
 *     component itself requires.
 *     </p>
 *     
 *     <p>
 *     See: <a href="package-summary.html#meta">Context Meta-Info
 *         Specification</a>
 *     </p>
 *     
 *     <p>
 *     Standard Avalon context entries, their keys, types and and
 *     associated semantics are defined under the framework standard
 *     attributes table.
 *     </p>
 *     
 *     <p>
 *     See: <a href="package-summary.html#attributes">
 *         Avalon Standard Context Entries Specification</a>
 *     </p>
 *     
 *     <h4>Examples, where the data is specified in a sample XML format:</h4>
 *     
 *     <h5>Example 1: Specification of Canonical Key</h5>
 *     
 *     <p>
 *     When a component specifies:
 *     </p>
 *
 *     <pre><code>    &lt;entry key="avalon:work" type="java.io.File"/&gt;</code></pre>
 *
 *     <p>
 *     It should be able to do:
 *     </p>
 *
 *     <pre><code>    File workDirectory = (File) context.get( "avalon:work" );</code></pre>
 *
 *     <p>
 *     in order to obtain the value.
 *     </p>
 *     
 *     <h5>Example 2: Specification of Canonical Key With Aliasing</h5>
 *     
 *     <p>
 *     When a component specifies:
 *     </p>
 *     
 *     <pre><code>    &lt;entry alias="work" key="avalon:work" type="java.io.File"/&gt;</code></pre>
 *     
 *     <p>
 *     It should be able to do:
 *     </p>
 *     
 *     <pre><code>    File workDirectory = (File) context.get( "work" ); </code></pre>
 *     </li>
 * </ol>
 *
 * @author <a href="mailto:dev@avalon.apache.org">Avalon Development Team</a>
 * @version CVS $Revision: 1.18 $ $Date: 2004/02/11 14:34:25 $
 */
public interface Context
{
    /**
     * Retrieve an object from Context.
     *
     * @param key the key into context
     * @return the object
     * @throws ContextException if object not found. Note that this
     *            means that either Component is asking for invalid entry
     *            or the Container is not living up to contract.
     */
    Object get( Object key )
        throws ContextException;
}
