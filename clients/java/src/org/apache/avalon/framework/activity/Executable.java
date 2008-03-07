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
package org.apache.avalon.framework.activity;

/**
 * The Executable can be implemented by components that need to perform
 * some work. In many respects it is similar to Runnable except that it
 * also allows an application to throw a non-Runtime Exception.
 *
 * <p>The work done may be short lived (ie a simple task) or it could
 * be a long running.</p>
 *
 * @author <a href="mailto:dev@avalon.apache.org">Avalon Development Team</a>
 * @version CVS $Revision: 1.15 $ $Date: 2004/02/11 14:34:24 $
 */
public interface Executable
{
    /**
     * Execute the action associated with this component.
     *
     * @throws Exception if an error occurs
     */
    void execute()
        throws Exception;
}
