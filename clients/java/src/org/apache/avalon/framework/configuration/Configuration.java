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
package org.apache.avalon.framework.configuration;

/**
 * <code>Configuration</code> is a interface encapsulating a configuration node
 * used to retrieve configuration values.
 *
 * <p>
 * This is a "read only" interface preventing applications from modifying their
 * own configurations. Once it is created, the information never changes.
 * </p>
 * <h3>Data Model</h3>
 * <p>
 * The data model is a subset of XML's; a single-rooted hierarchical tree where each
 * node can contain multiple <em>attributes</em>, and leaf nodes can also
 * contain a <em>value</em>. Reflecting this, <code>Configuration</code>s are
 * usually built from an XML file by the {@link DefaultConfigurationBuilder}
 * class, or directly by a SAX parser using a {@link SAXConfigurationHandler} or
 * {@link NamespacedSAXConfigurationHandler} event handler.
 * </p>
 * <h4>Namespace support</h4>
 * <p>
 * Since version 4.1, each <code>Configuration</code> node has a namespace
 * associated with it, in the form of a string, accessible through {@link
 * #getNamespace}. If no namespace is present, <code>getNamespace</code> will
 * return blank (""). See {@link DefaultConfigurationBuilder} for details on how
 * XML namespaces are mapped to <code>Configuration</code> namespaces.
 * </p>
 * <h3>Example</h3>
 * <p>
 * As an example, consider two <code>Configuration</code>s (with and without
 * namespaces) built from this XML:
 * </p>
 * <pre>
 * &lt;my-system version="1.3" xmlns:doc="http://myco.com/documentation"&gt;
 *   &lt;doc:desc&gt;This is a highly fictitious config file&lt;/doc:desc&gt;
 *   &lt;widget name="fooWidget" initOrder="1" threadsafe="true"/&gt;
 * &lt;/my-system&gt;
 * </pre>
 * <p>If namespace support is enabled (eg through {@link
 * DefaultConfigurationBuilder#DefaultConfigurationBuilder(boolean) new
 * DefaultConfigurationBuilder(true)}), then the <code>xmlns:doc</code> element
 * will not translate into a Configuration attribute, and the
 * <code>doc:desc</code> element will become a <code>Configuration</code> node
 * with name "desc" and namespace "http://myco.com/documentation". The
 * <code>widget</code> element will have namespace "".
 * </p>
 * <p>If namespace support is disabled (the default for {@link
 * DefaultConfigurationBuilder}), the above XML will translate directly to
 * <code>Configuration</code> nodes. The <code>my-system</code> node will have
 * an attribute named "xmlns:doc", and a child called "doc:desc".
 * </p>
 * <p>
 * Assuming the <code>Configuration</code> object is named <code>conf</code>,
 * here is how the data could be retrieved:
 * </p>
 * <table border="1">
 * <tr align="center"><th>Code</th><th>No namespaces</th><th>With namespaces</th></tr>
 * <tr align="center"><td align="left">
 * <code>conf.{@link #getName getName}()</code></td><td colspan="2">my-system</td></tr>
 * <tr align="center"><td align="left">
 * <code>conf.{@link #getAttributeNames getAttributeNames}().length</code>
 * </td><td>2</td><td>1</td></tr>
 * <tr align="center"><td align="left">
 * <code>conf.{@link #getChildren getChildren}().length</code>
 * </td><td colspan="2">2</td></tr>
 * <tr align="center"><td align="left">
 * <code>conf.{@link #getAttributeAsFloat getAttributeAsFloat}("version")</code>
 * </td><td colspan="2">1.3</td></tr>
 * <tr align="center"><td align="left">
 * <code>conf.{@link #getChild getChild}("widget").{@link #getAttribute getAttribute}("name")</code>
 * </td><td colspan="2">fooWidget</td></tr>
 * <tr align="center"><td align="left">
 * <code>conf.{@link #getChild getChild}("widget")
 * .{@link #getAttributeAsBoolean getAttributeAsBoolean}("threadsafe")</code></td><td colspan="2">
 * <code>true</code></td></tr>
 * <tr align="center"><td align="left">
 * <code>conf.{@link #getChild getChild}("widget").{@link #getLocation getLocation}()</code>
 * </td><td colspan="2">file:///home/jeff/tmp/java/avalon/src/java/new.xconf:4:60</td></tr>
 * <tr align="center"><td align="left">
 * <code>conf.{@link #getChild getChild}("desc").{@link #getName getName}()</code>
 * </td><td>desc (see {@link #getChild(String)})</td><td>desc</td></tr>
 * <tr align="center"><td align="left">
 * <code>conf.{@link #getChild getChild}("doc:desc").{@link #getName getName}()</code>
 * </td><td>doc:desc</td><td>doc:desc (see {@link #getChild(String)})</td></tr>
 * <tr align="center"><td align="left">
 * <code>conf.{@link #getChild getChild}("desc").{@link #getValue getValue}()</code>
 * </td><td>{@link ConfigurationException}</td><td>This is a highly fictitious config file</td></tr>
 * <tr align="center"><td align="left">
 * <code>conf.{@link #getChild getChild}("doc:desc").{@link #getValue getValue}()</code>
 * </td><td>This is a highly fictitious config file</td><td>{@link ConfigurationException}</td></tr>
 * <tr align="center"><td align="left">
 * <code>conf.{@link #getChild getChild}("desc").{@link #getNamespace getNamespace}()</code>
 * </td><td>&nbsp;</td><td>http://myco.com/documentation"</td></tr>
 * </table>
 * </p>
 * <p>
 * Type-safe utility methods are provided for retrieving attribute and element
 * values as <code>String</code>, <code>int</code>, <code>long</code>,
 * <code>float</code> and <code>boolean</code>.
 * </p>
 * <h3>Miscellanea</h3>
 * <p>
 * Currently, the configuration tree can only be traversed one node at a time,
 * eg., through {@link #getChild getChild("foo")} or {@link #getChildren}. In
 * a future release, it may be possible to access child nodes with an XPath-like
 * syntax.
 * </p>
 * <p>
 * Checking for the existence of an attribute can be done as follows:
 * </p>
 * <pre>
 *String value = conf.getAttribute( "myAttribute", null );
 * if ( null == value )
 * {
 *   // Do the processing applicable if the attribute isn't present.
 * }
 * </pre>
 *
 * @author <a href="mailto:dev@avalon.apache.org">Avalon Development Team</a>
 * @version CVS $Revision: 1.29 $ $Date: 2004/02/11 14:34:24 $
 */
public interface Configuration
{
    /**
     * Return the name of the node.
     *
     * @return name of the <code>Configuration</code> node.
     */
    String getName();

    /**
     * Return a string describing location of Configuration.
     * Location can be different for different mediums (ie "file:line" for normal XML files or
     * "table:primary-key" for DB based configurations);
     *
     * @return a string describing location of Configuration
     */
    String getLocation();

    /**
     * Returns a string indicating which namespace this Configuration node
     * belongs to.
     *
     * <p>
     * What this returns is dependent on the configuration file and the
     * Configuration builder. If the Configuration builder does not support
     * namespaces, this method will return a blank string.
     * </p>
     * <p>In the case of {@link DefaultConfigurationBuilder}, the namespace will
     * be the URI associated with the XML element. Eg.,:</p>
     * <pre>
     * &lt;foo xmlns:x="http://blah.com"&gt;
     *   &lt;x:bar/&gt;
     * &lt;/foo&gt;
     * </pre>
     * <p>The namespace of <code>foo</code> will be "", and the namespace of
     * <code>bar</code> will be "http://blah.com".</p>
     *
     * @return a String identifying the namespace of this Configuration.
     * @throws ConfigurationException if an error occurs
     * @since 4.1
     */
    String getNamespace() throws ConfigurationException;

    /**
     * Return a new <code>Configuration</code> instance encapsulating the
     * specified child node.
     * <p>
     * If no such child node exists, an empty <code>Configuration</code> will be
     * returned, allowing constructs such as
     * <code>conf.getChild("foo").getChild("bar").getChild("baz").{@link
     * #getValue(String) getValue}("default");</code>
     * </p>
     * <p>
     * If you wish to get a <code>null</code> return when no element is present,
     * use {@link #getChild(String, boolean) getChild("foo", <b>false</b>)}.
     * </p>
     *
     * @param child The name of the child node.
     * @return Configuration
     */
    Configuration getChild( String child );

    /**
     * Return a <code>Configuration</code> instance encapsulating the specified
     * child node.
     *
     * @param child The name of the child node.
     * @param createNew If <code>true</code>, a new <code>Configuration</code>
     * will be created and returned if the specified child does not exist. If
     * <code>false</code>, <code>null</code> will be returned when the specified
     * child doesn't exist.
     * @return Configuration
     */
    Configuration getChild( String child, boolean createNew );

    /**
     * Return an <code>Array</code> of <code>Configuration</code>
     * elements containing all node children. The array order will reflect the
     * order in the source config file.
     *
     * @return All child nodes
     */
    Configuration[] getChildren();

    /**
     * Return an <code>Array</code> of <code>Configuration</code>
     * elements containing all node children with the specified name. The array
     * order will reflect the order in the source config file.
     *
     * @param name The name of the children to get.
     * @return The child nodes with name <code>name</code>
     */
    Configuration[] getChildren( String name );

    /**
     * Return an array of all attribute names.
     * <p>
     * <em>The order of attributes in this array can not be relied on.</em> As
     * with XML, a <code>Configuration</code>'s attributes are an
     * <em>unordered</em> set. If your code relies on order, eg
     * <tt>conf.getAttributeNames()[0]</tt>, then it is liable to break if a
     * different XML parser is used.
     * </p>
     * @return a <code>String[]</code> value
     */
    String[] getAttributeNames();

    /**
     * Return the value of specified attribute.
     *
     * @param paramName The name of the parameter you ask the value of.
     * @return String value of attribute.
     * @throws ConfigurationException If no attribute with that name exists.
     */
    String getAttribute( String paramName ) throws ConfigurationException;

    /**
     * Return the <code>int</code> value of the specified attribute contained
     * in this node.
     *
     * @param paramName The name of the parameter you ask the value of.
     * @return int value of attribute
     * @throws ConfigurationException If no parameter with that name exists.
     *                                   or if conversion to <code>int</code> fails.
     *
     */
    int getAttributeAsInteger( String paramName ) throws ConfigurationException;

    /**
     * Returns the value of the attribute specified by its name as a
     * <code>long</code>.
     *
     * @param name The name of the parameter you ask the value of.
     * @return long value of attribute
     * @throws ConfigurationException If no parameter with that name exists.
     *                                   or if conversion to <code>long</code> fails.
     */
    long getAttributeAsLong( String name ) throws ConfigurationException;

    /**
     * Return the <code>float</code> value of the specified parameter contained
     * in this node.
     *
     * @param paramName The name of the parameter you ask the value of.
     * @return float value of attribute
     * @throws ConfigurationException If no parameter with that name exists.
     *                                   or if conversion to <code>float</code> fails.
     */
    float getAttributeAsFloat( String paramName ) throws ConfigurationException;

    /**
     * Return the <code>boolean</code> value of the specified parameter contained
     * in this node.
     *
     * @param paramName The name of the parameter you ask the value of.
     * @return boolean value of attribute
     * @throws ConfigurationException If no parameter with that name exists.
     *                                   or if conversion to <code>boolean</code> fails.
     */
    boolean getAttributeAsBoolean( String paramName ) throws ConfigurationException;

    /**
     * Return the <code>String</code> value of the node.
     *
     * @return the value of the node.
     * @throws ConfigurationException if an error occurs
     */
    String getValue() throws ConfigurationException;

    /**
     * Return the <code>int</code> value of the node.
     *
     * @return the value of the node.
     *
     * @throws ConfigurationException If conversion to <code>int</code> fails.
     */
    int getValueAsInteger() throws ConfigurationException;

    /**
     * Return the <code>float</code> value of the node.
     *
     * @return the value of the node.
     * @throws ConfigurationException If conversion to <code>float</code> fails.
     */
    float getValueAsFloat() throws ConfigurationException;

    /**
     * Return the <code>boolean</code> value of the node.
     *
     * @return the value of the node.
     * @throws ConfigurationException If conversion to <code>boolean</code> fails.
     */
    boolean getValueAsBoolean() throws ConfigurationException;

    /**
     * Return the <code>long</code> value of the node.
     *
     * @return the value of the node.
     * @throws ConfigurationException If conversion to <code>long</code> fails.
     */
    long getValueAsLong() throws ConfigurationException;

    /**
     * Returns the value of the configuration element as a <code>String</code>.
     * If the configuration value is not set, the default value will be
     * used.
     *
     * @param defaultValue The default value desired.
     * @return String value of the <code>Configuration</code>, or default
     *          if none specified.
     */
    String getValue( String defaultValue );

    /**
     * Returns the value of the configuration element as an <code>int</code>.
     * If the configuration value is not set, the default value will be
     * used.
     *
     * @param defaultValue The default value desired.
     * @return int value of the <code>Configuration</code>, or default
     *          if none specified.
     */
    int getValueAsInteger( int defaultValue );

    /**
     * Returns the value of the configuration element as a <code>long</code>.
     * If the configuration value is not set, the default value will be
     * used.
     *
     * @param defaultValue The default value desired.
     * @return long value of the <code>Configuration</code>, or default
     *          if none specified.
     */
    long getValueAsLong( long defaultValue );

    /**
     * Returns the value of the configuration element as a <code>float</code>.
     * If the configuration value is not set, the default value will be
     * used.
     *
     * @param defaultValue The default value desired.
     * @return float value of the <code>Configuration</code>, or default
     *          if none specified.
     */
    float getValueAsFloat( float defaultValue );

    /**
     * Returns the value of the configuration element as a <code>boolean</code>.
     * If the configuration value is not set, the default value will be
     * used.
     *
     * @param defaultValue The default value desired.
     * @return boolean value of the <code>Configuration</code>, or default
     *          if none specified.
     */
    boolean getValueAsBoolean( boolean defaultValue );

    /**
     * Returns the value of the attribute specified by its name as a
     * <code>String</code>, or the default value if no attribute by
     * that name exists or is empty.
     *
     * @param name The name of the attribute you ask the value of.
     * @param defaultValue The default value desired.
     * @return String value of attribute. It will return the default
     *         value if the named attribute does not exist, or if
     *         the value is not set.
     */
    String getAttribute( String name, String defaultValue );

    /**
     * Returns the value of the attribute specified by its name as a
     * <code>int</code>, or the default value if no attribute by
     * that name exists or is empty.
     *
     * @param name The name of the attribute you ask the value of.
     * @param defaultValue The default value desired.
     * @return int value of attribute. It will return the default
     *         value if the named attribute does not exist, or if
     *         the value is not set.
     */
    int getAttributeAsInteger( String name, int defaultValue );

    /**
     * Returns the value of the attribute specified by its name as a
     * <code>long</code>, or the default value if no attribute by
     * that name exists or is empty.
     *
     * @param name The name of the attribute you ask the value of.
     * @param defaultValue The default value desired.
     * @return long value of attribute. It will return the default
     *          value if the named attribute does not exist, or if
     *          the value is not set.
     */
    long getAttributeAsLong( String name, long defaultValue );

    /**
     * Returns the value of the attribute specified by its name as a
     * <code>float</code>, or the default value if no attribute by
     * that name exists or is empty.
     *
     * @param name The name of the attribute you ask the value of.
     * @param defaultValue The default value desired.
     * @return float value of attribute. It will return the default
     *          value if the named attribute does not exist, or if
     *          the value is not set.
     */
    float getAttributeAsFloat( String name, float defaultValue );

    /**
     * Returns the value of the attribute specified by its name as a
     * <code>boolean</code>, or the default value if no attribute by
     * that name exists or is empty.
     *
     * @param name The name of the attribute you ask the value of.
     * @param defaultValue The default value desired.
     * @return boolean value of attribute. It will return the default
     *         value if the named attribute does not exist, or if
     *         the value is not set.
     */
    boolean getAttributeAsBoolean( String name, boolean defaultValue );
}
