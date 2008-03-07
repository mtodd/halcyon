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
package org.apache.avalon.framework.parameters;

import java.io.Serializable;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;
import org.apache.avalon.framework.configuration.Configuration;
import org.apache.avalon.framework.configuration.ConfigurationException;

/**
 * The <code>Parameters</code> class represents a set of key-value
 * pairs.
 * <p>
 * The <code>Parameters</code> object provides a mechanism to obtain
 * values based on a <code>String</code> name.  There are convenience
 * methods that allow you to use defaults if the value does not exist,
 * as well as obtain the value in any of the same formats that are in
 * the {@link Configuration} interface.
 * </p><p>
 * While there are similarities between the <code>Parameters</code>
 * object and the java.util.Properties object, there are some
 * important semantic differences.  First, <code>Parameters</code> are
 * <i>read-only</i>.  Second, <code>Parameters</code> are easily
 * derived from {@link Configuration} objects.  Lastly, the
 * <code>Parameters</code> object is derived from XML fragments that
 * look like this:
 * <pre><code>
 *  &lt;parameter name="param-name" value="param-value" /&gt;
 * </code></pre>
 * </p><p>
 * <strong>Note: this class is not thread safe by default.</strong> If you
 * require thread safety please synchronize write access to this class to
 * prevent potential data corruption.
 * </p>
 *
 * @author <a href="mailto:dev@avalon.apache.org">Avalon Development Team</a>
 * @version CVS $Revision: 1.41 $ $Date: 2004/02/11 14:34:25 $
 */
public class Parameters
    implements Serializable
{
    /**
     * Empty Parameters object
     *
     * @since 4.1.2
     */
    public static final Parameters EMPTY_PARAMETERS;

    /** Static initializer to initialize the empty Parameters object */
    static
    {
        EMPTY_PARAMETERS = new Parameters();
        EMPTY_PARAMETERS.makeReadOnly();
    }

    ///Underlying store of parameters
    private Map m_parameters = new HashMap();

    private boolean m_readOnly;

    /**
     * Set the <code>String</code> value of a specified parameter.
     * <p />
     * If the specified value is <b>null</b> the parameter is removed.
     *
     * @param name a <code>String</code> value
     * @param value a <code>String</code> value
     * @return The previous value of the parameter or <b>null</b>.
     * @throws IllegalStateException if the Parameters object is read-only
     */
    public String setParameter( final String name, final String value )
        throws IllegalStateException
    {
        checkWriteable();

        if( null == name )
        {
            return null;
        }

        if( null == value )
        {
            return (String)m_parameters.remove( name );
        }

        return (String)m_parameters.put( name, value );
    }

    /**
     * Remove a parameter from the parameters object
     * @param name a <code>String</code> value
     * @since 4.1
     */
    public void removeParameter( final String name )
    {
        setParameter( name, null );
    }

    /**
     * Return an <code>Iterator</code> view of all parameter names.
     *
     * @return a iterator of parameter names
     * @deprecated Use getNames() instead
     */
    public Iterator getParameterNames()
    {
        return m_parameters.keySet().iterator();
    }

    /**
     * Retrieve an array of all parameter names.
     *
     * @return the parameters names
     */
    public String[] getNames()
    {
        return (String[])m_parameters.keySet().toArray( new String[ 0 ] );
    }

    /**
     * Test if the specified parameter can be retrieved.
     *
     * @param name the parameter name
     * @return true if parameter is a name
     */
    public boolean isParameter( final String name )
    {
        return m_parameters.containsKey( name );
    }

    /**
     * Retrieve the <code>String</code> value of the specified parameter.
     * <p />
     * If the specified parameter cannot be found, an exception is thrown.
     *
     * @param name the name of parameter
     * @return the value of parameter
     * @throws ParameterException if the specified parameter cannot be found
     */
    public String getParameter( final String name )
        throws ParameterException
    {
        if( null == name )
        {
            throw new ParameterException( "You cannot lookup a null parameter" );
        }

        final String test = (String)m_parameters.get( name );

        if( null == test )
        {
            throw new ParameterException( "The parameter '" + name
                                          + "' does not contain a value" );
        }
        else
        {
            return test;
        }
    }

    /**
     * Retrieve the <code>String</code> value of the specified parameter.
     * <p />
     * If the specified parameter cannot be found, <code>defaultValue</code>
     * is returned.
     *
     * @param name the name of parameter
     * @param defaultValue the default value, returned if parameter does not exist
     *        or parameter's name is null
     * @return the value of parameter
     */
    public String getParameter( final String name, final String defaultValue )
    {
        if( name == null )
        {
            return defaultValue;
        }

        final String test = (String)m_parameters.get( name );

        if( test == null )
        {
            return defaultValue;
        }
        else
        {
            return test;
        }
    }

    /**
     * Parses string represenation of the <code>int</code> value.
     * <p />
     * Hexadecimal numbers begin with 0x, Octal numbers begin with 0o and binary
     * numbers begin with 0b, all other values are assumed to be decimal.
     *
     * @param value the value to parse
     * @return the integer value
     * @throws NumberFormatException if the specified value can not be parsed
     */
    private int parseInt( final String value )
        throws NumberFormatException
    {
        if( value.startsWith( "0x" ) )
        {
            return Integer.parseInt( value.substring( 2 ), 16 );
        }
        else if( value.startsWith( "0o" ) )
        {
            return Integer.parseInt( value.substring( 2 ), 8 );
        }
        else if( value.startsWith( "0b" ) )
        {
            return Integer.parseInt( value.substring( 2 ), 2 );
        }
        else
        {
            return Integer.parseInt( value );
        }
    }

    /**
     * Retrieve the <code>int</code> value of the specified parameter.
     * <p />
     * If the specified parameter cannot be found, an exception is thrown.
     *
     * Hexadecimal numbers begin with 0x, Octal numbers begin with 0o and binary
     * numbers begin with 0b, all other values are assumed to be decimal.
     *
     * @param name the name of parameter
     * @return the integer parameter type
     * @throws ParameterException if the specified parameter cannot be found
     *         or is not an Integer value
     */
    public int getParameterAsInteger( final String name )
        throws ParameterException
    {
        try
        {
            return parseInt( getParameter( name ) );
        }
        catch( final NumberFormatException e )
        {
            throw new ParameterException( "Could not return an integer value", e );
        }
    }

    /**
     * Retrieve the <code>int</code> value of the specified parameter.
     * <p />
     * If the specified parameter cannot be found, <code>defaultValue</code>
     * is returned.
     *
     * Hexadecimal numbers begin with 0x, Octal numbers begin with 0o and binary
     * numbers begin with 0b, all other values are assumed to be decimal.
     *
     * @param name the name of parameter
     * @param defaultValue value returned if parameter does not exist or is of wrong type
     * @return the integer parameter type
     */
    public int getParameterAsInteger( final String name, final int defaultValue )
    {
        try
        {
            final String value = getParameter( name, null );
            if( value == null )
            {
                return defaultValue;
            }

            return parseInt( value );
        }
        catch( final NumberFormatException e )
        {
            return defaultValue;
        }
    }

    /**
     * Parses string represenation of the <code>long</code> value.
     * <p />
     * Hexadecimal numbers begin with 0x, Octal numbers begin with 0o and binary
     * numbers begin with 0b, all other values are assumed to be decimal.
     *
     * @param value the value to parse
     * @return the long value
     * @throws NumberFormatException if the specified value can not be parsed
     */
    private long parseLong( final String value )
        throws NumberFormatException
    {
        if( value.startsWith( "0x" ) )
        {
            return Long.parseLong( value.substring( 2 ), 16 );
        }
        else if( value.startsWith( "0o" ) )
        {
            return Long.parseLong( value.substring( 2 ), 8 );
        }
        else if( value.startsWith( "0b" ) )
        {
            return Long.parseLong( value.substring( 2 ), 2 );
        }
        else
        {
            return Long.parseLong( value );
        }
    }

    /**
     * Retrieve the <code>long</code> value of the specified parameter.
     * <p />
     * If the specified parameter cannot be found, an exception is thrown.
     *
     * Hexadecimal numbers begin with 0x, Octal numbers begin with 0o and binary
     * numbers begin with 0b, all other values are assumed to be decimal.
     *
     * @param name the name of parameter
     * @return the long parameter type
     * @throws ParameterException  if the specified parameter cannot be found
     *         or is not a Long value.
     */
    public long getParameterAsLong( final String name )
        throws ParameterException
    {
        try
        {
            return parseLong( getParameter( name ) );
        }
        catch( final NumberFormatException e )
        {
            throw new ParameterException( "Could not return a long value", e );
        }
    }

    /**
     * Retrieve the <code>long</code> value of the specified parameter.
     * <p />
     * If the specified parameter cannot be found, <code>defaultValue</code>
     * is returned.
     *
     * Hexadecimal numbers begin with 0x, Octal numbers begin with 0o and binary
     * numbers begin with 0b, all other values are assumed to be decimal.
     *
     * @param name the name of parameter
     * @param defaultValue value returned if parameter does not exist or is of wrong type
     * @return the long parameter type
     */
    public long getParameterAsLong( final String name, final long defaultValue )
    {
        try
        {
            final String value = getParameter( name, null );
            if( value == null )
            {
                return defaultValue;
            }

            return parseLong( value );
        }
        catch( final NumberFormatException e )
        {
            return defaultValue;
        }
    }

    /**
     * Retrieve the <code>float</code> value of the specified parameter.
     * <p />
     * If the specified parameter cannot be found,  an exception is thrown.
     *
     * @param name the parameter name
     * @return the value
     * @throws ParameterException if the specified parameter cannot be found
     *         or is not a Float value
     */
    public float getParameterAsFloat( final String name )
        throws ParameterException
    {
        try
        {
            return Float.parseFloat( getParameter( name ) );
        }
        catch( final NumberFormatException e )
        {
            throw new ParameterException( "Could not return a float value", e );
        }
    }

    /**
     * Retrieve the <code>float</code> value of the specified parameter.
     * <p />
     * If the specified parameter cannot be found, <code>defaultValue</code>
     * is returned.
     *
     * @param name the parameter name
     * @param defaultValue the default value if parameter does not exist or is of wrong type
     * @return the value
     */
    public float getParameterAsFloat( final String name, final float defaultValue )
    {
        try
        {
            final String value = getParameter( name, null );
            if( value == null )
            {
                return defaultValue;
            }

            return Float.parseFloat( value );
        }
        catch( final NumberFormatException pe )
        {
            return defaultValue;
        }
    }

    /**
     * Retrieve the <code>boolean</code> value of the specified parameter.
     * <p />
     * If the specified parameter cannot be found, an exception is thrown.
     *
     * @param name the parameter name
     * @return the value
     * @throws ParameterException if an error occurs
     * @throws ParameterException
     */
    public boolean getParameterAsBoolean( final String name )
        throws ParameterException
    {
        final String value = getParameter( name );

        if( value.equalsIgnoreCase( "true" ) )
        {
            return true;
        }
        else if( value.equalsIgnoreCase( "false" ) )
        {
            return false;
        }
        else
        {
            throw new ParameterException( "Could not return a boolean value" );
        }
    }

    /**
     * Retrieve the <code>boolean</code> value of the specified parameter.
     * <p />
     * If the specified parameter cannot be found, <code>defaultValue</code>
     * is returned.
     *
     * @param name the parameter name
     * @param defaultValue the default value if parameter does not exist or is of wrong type
     * @return the value
     */
    public boolean getParameterAsBoolean( final String name, final boolean defaultValue )
    {
        final String value = getParameter( name, null );
        if( value == null )
        {
            return defaultValue;
        }

        if( value.equalsIgnoreCase( "true" ) )
        {
            return true;
        }
        else if( value.equalsIgnoreCase( "false" ) )
        {
            return false;
        }
        else
        {
            return defaultValue;
        }
    }

    /**
     * Merge parameters from another <code>Parameters</code> instance
     * into this.
     *
     * @param other the other Parameters
     * @return This <code>Parameters</code> instance.
     */
    public Parameters merge( final Parameters other )
    {
        checkWriteable();

        final String[] names = other.getNames();

        for( int i = 0; i < names.length; i++ )
        {
            final String name = names[ i ];
            String value = null;
            try
            {
                value = other.getParameter( name );
            }
            catch( final ParameterException pe )
            {
                value = null;
            }

            setParameter( name, value );
        }

        return this;
    }

    /**
     * Make this Parameters read-only so that it will throw a
     * <code>IllegalStateException</code> if someone tries to
     * modify it.
     */
    public void makeReadOnly()
    {
        m_readOnly = true;
    }

    /**
     * Checks is this <code>Parameters</code> object is writeable.
     *
     * @throws IllegalStateException if this <code>Parameters</code> object is read-only
     */
    protected final void checkWriteable()
        throws IllegalStateException
    {
        if( m_readOnly )
        {
            throw new IllegalStateException( "Context is read only and can not be modified" );
        }
    }

    /**
     * Create a <code>Parameters</code> object from a <code>Configuration</code>
     * object.  This acts exactly like the following method call:
     * <pre>
     *     Parameters.fromConfiguration(configuration, "parameter");
     * </pre>
     *
     * @param configuration the Configuration
     * @return This <code>Parameters</code> instance.
     * @throws ConfigurationException if an error occurs
     */
    public static Parameters fromConfiguration( final Configuration configuration )
        throws ConfigurationException
    {
        return fromConfiguration( configuration, "parameter" );
    }

    /**
     * Create a <code>Parameters</code> object from a <code>Configuration</code>
     * object using the supplied element name.
     *
     * @param configuration the Configuration
     * @param elementName   the element name for the parameters
     * @return This <code>Parameters</code> instance.
     * @throws ConfigurationException if an error occurs
     * @since 4.1
     */
    public static Parameters fromConfiguration( final Configuration configuration,
                                                final String elementName )
        throws ConfigurationException
    {
        if( null == configuration )
        {
            throw new ConfigurationException( 
               "You cannot convert to parameters with a null Configuration" );
        }

        final Configuration[] parameters = configuration.getChildren( elementName );
        final Parameters params = new Parameters();

        for( int i = 0; i < parameters.length; i++ )
        {
            try
            {
                final String name = parameters[ i ].getAttribute( "name" );
                final String value = parameters[ i ].getAttribute( "value" );
                params.setParameter( name, value );
            }
            catch( final Exception e )
            {
                throw new ConfigurationException( "Cannot process Configurable", e );
            }
        }

        return params;
    }

    /**
     * Create a <code>Parameters</code> object from a <code>Properties</code>
     * object.
     *
     * @param properties the Properties
     * @return This <code>Parameters</code> instance.
     */
    public static Parameters fromProperties( final Properties properties )
    {
        final Parameters parameters = new Parameters();
        final Enumeration names = properties.propertyNames();

        while( names.hasMoreElements() )
        {
            final String key = names.nextElement().toString();
            final String value = properties.getProperty( key );
            parameters.setParameter( key, value );
        }

        return parameters;
    }

    /**
     * Creates a <code>java.util.Properties</code> object from an Avalon
     * Parameters object.
     *
     * @param params a <code>Parameters</code> instance
     * @return a <code>Properties</code> instance
     */
    public static Properties toProperties( final Parameters params )
    {
        final Properties properties = new Properties();
        final String[] names = params.getNames();

        for( int i = 0; i < names.length; ++i )
        {
            // "" is the default value, since getNames() proves it will exist
            properties.setProperty( names[ i ], params.getParameter( names[ i ], "" ) );
        }

        return properties;
    }
}
