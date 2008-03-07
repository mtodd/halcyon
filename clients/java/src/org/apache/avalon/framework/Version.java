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
package org.apache.avalon.framework;

import java.io.Serializable;
import java.util.StringTokenizer;

/**
 * This class is used to hold version information pertaining to a Component or interface.
 * <p />
 *
 * The version number of a <code>Component</code> is made up of three
 * dot-separated fields:
 * <p />
 * &quot;<b>major.minor.micro</b>&quot;
 * <p />
 * The <b>major</b>, <b>minor</b> and <b>micro</b> fields are
 * <i>integer</i> numbers represented in decimal notation and have the
 * following meaning:
 * <ul>
 *
 * <p /><li><b>major</b> - When the major version changes (in ex. from
 * &quot;1.5.12&quot; to &quot;2.0.0&quot;), then backward compatibility
 * with previous releases is not granted.</li><p />
 *
 * <p /><li><b>minor</b> - When the minor version changes (in ex. from
 * &quot;1.5.12&quot; to &quot;1.6.0&quot;), then backward compatibility
 * with previous releases is granted, but something changed in the
 * implementation of the Component. (ie it methods could have been added)</li><p />
 *
 * <p /><li><b>micro</b> - When the micro version changes (in ex.
 * from &quot;1.5.12&quot; to &quot;1.5.13&quot;), then the the changes are
 * small forward compatible bug fixes or documentation modifications etc.
 * </li>
 * </ul>
 *
 * @author <a href="mailto:dev@avalon.apache.org">Avalon Development Team</a>
 * @version CVS $Revision: 1.33 $ $Date: 2004/02/11 14:34:24 $
 */
public final class Version
    implements Comparable, Serializable
{
    private int m_major;
    private int m_minor;
    private int m_micro;

    /**
     * Parse a version out of a string.
     * The version string format is <major>.<minor>.<micro> where
     * both minor and micro are optional.
     *
     * @param version The input version string
     * @return the new Version object
     * @throws NumberFormatException if an error occurs
     * @throws IllegalArgumentException if an error occurs
     * @throws NullPointerException if the provided string is <code>null</code>
     * @since 4.1
     */
    public static Version getVersion( final String version )
        throws NumberFormatException, IllegalArgumentException
    {
        if( version == null )
            throw new NullPointerException( "version" );

        final StringTokenizer tokenizer = new StringTokenizer( version, "." );
        final String[] levels = new String[ tokenizer.countTokens() ];
        for( int i = 0; i < levels.length; i++ )
        {
            levels[ i ] = tokenizer.nextToken();
        }

        int major = -1;
        if( 0 < levels.length )
        {
            major = Integer.parseInt( levels[ 0 ] );
        }

        int minor = 0;
        if( 1 < levels.length )
        {
            minor = Integer.parseInt( levels[ 1 ] );
        }

        int micro = 0;
        if( 2 < levels.length )
        {
            micro = Integer.parseInt( levels[ 2 ] );
        }

        return new Version( major, minor, micro );
    }

    /**
     * Create a new instance of a <code>Version</code> object with the
     * specified version numbers.
     *
     * @param major This <code>Version</code> major number.
     * @param minor This <code>Version</code> minor number.
     * @param micro This <code>Version</code> micro number.
     */
    public Version( final int major, final int minor, final int micro )
    {
        m_major = major;
        m_minor = minor;
        m_micro = micro;
    }

    /**
     * Retrieve major component of version.
     *
     * @return the major component of version
     * @since 4.1
     */
    public int getMajor()
    {
        return m_major;
    }

    /**
     * Retrieve minor component of version.
     *
     * @return the minor component of version
     * @since 4.1
     */
    public int getMinor()
    {
        return m_minor;
    }

    /**
     * Retrieve micro component of version.
     *
     * @return the micro component of version.
     * @since 4.1
     */
    public int getMicro()
    {
        return m_micro;
    }

    /**
     * Check this <code>Version</code> against another for equality.
     * <p />
     * If this <code>Version</code> is compatible with the specified one, then
     * <b>true</b> is returned, otherwise <b>false</b>.
     *
     * @param other The other <code>Version</code> object to be compared with this
     *          for equality.
     * @return <b>true</b> if this <code>Version</code> is compatible with the specified one
     * @since 4.1
     */
    public boolean equals( final Version other )
    {
        if( other == null )
            return false;

        boolean isEqual = ( getMajor() == other.getMajor() );
        
        if ( isEqual )
        {
            isEqual = ( getMinor() == other.getMinor() );
        }
        
        if ( isEqual )
        {
            isEqual = ( getMicro() == other.getMicro() );
        }

        return isEqual;
    }

    /**
     * Indicates whether some other object is "equal to" this <code>Version</code>.
     * Returns <b>true</b> if the other object is an instance of <code>Version</code>
     * and has the same major, minor, and micro components.
     *
     * @param other an <code>Object</code> value
     * @return <b>true</b> if the other object is equal to this <code>Version</code>
     */
    public boolean equals( final Object other )
    {
        boolean isEqual = false;
        
        if( other instanceof Version )
        {
            isEqual = equals( (Version)other );
        }

        return isEqual;
    }
    
    /**
     * Add a hashing function to ensure the Version object is
     * treated as expected in hashmaps and sets.  NOTE: any
     * time the equals() is overridden, hashCode() should also
     * be overridden.
     * 
     * @return the hashCode
     */
    public int hashCode()
    {
        int hash = getMajor();
        hash >>>= 17;
        hash += getMinor();
        hash >>>= 17;
        hash += getMicro();
        
        return hash;
    }

    /**
     * Check this <code>Version</code> against another for compliancy
     * (compatibility).
     * <p />
     * If this <code>Version</code> is compatible with the specified one, then
     * <b>true</b> is returned, otherwise <b>false</b>. Be careful when using
     * this method since, in example, version 1.3.7 is compliant to version
     * 1.3.6, while the opposite is not.
     * <p />
     * The following example displays the expected behaviour and results of version.
     * <pre>
     * final Version v1 = new Version( 1, 3 , 6 );
     * final Version v2 = new Version( 1, 3 , 7 );
     * final Version v3 = new Version( 1, 4 , 0 );
     * final Version v4 = new Version( 2, 0 , 1 );
     *
     * assert(   v1.complies( v1 ) );
     * assert( ! v1.complies( v2 ) );
     * assert(   v2.complies( v1 ) );
     * assert( ! v1.complies( v3 ) );
     * assert(   v3.complies( v1 ) );
     * assert( ! v1.complies( v4 ) );
     * assert( ! v4.complies( v1 ) );
     * </pre>
     *
     * @param other The other <code>Version</code> object to be compared with this
     *              for compliancy (compatibility).
     * @return <b>true</b> if this <code>Version</code> is compatible with the specified one
     */
    public boolean complies( final Version other )
    {
        if( other == null )
            return false;

        if( other.m_major == -1 )
        {
            return true;
        }
        if( m_major != other.m_major )
        {
            return false;
        }
        else if( m_minor < other.m_minor )
        {
            //If of major version but lower minor version then incompatible
            return false;
        }
        else if( m_minor == other.m_minor 
            && m_micro < other.m_micro )
        {
            //If same major version, same minor version but lower micro level
            //then incompatible
            return false;
        }
        else
        {
            return true;
        }
    }

    /**
     * Overload toString to report version correctly.
     *
     * @return the dot seperated version string
     */
    public String toString()
    {
        return m_major + "." + m_minor + "." + m_micro;
    }

    /**
     * Compare two versions together according to the
     * {@link Comparable} interface.
     * 
     * @return number indicating relative value (-1, 0, 1)
     */
    public int compareTo(Object o) {
        if( o == null )
            throw new NullPointerException( "o" );


        Version other = (Version)o;
        int val = 0;

        if ( getMajor() < other.getMajor() ) val = -1;
        if ( 0 == val && getMajor() > other.getMajor() ) val = 1;

        if ( 0 == val && getMinor() < other.getMinor() ) val = -1;
        if ( 0 == val && getMinor() > other.getMinor() ) val = 1;

        if ( 0 == val && getMicro() < other.getMicro() ) val = -1;
        if ( 0 == val && getMicro() > other.getMicro() ) val = 1;

        return val;
    }
}
