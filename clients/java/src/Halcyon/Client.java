package Halcyon;
import java.io.File;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import org.apache.commons.httpclient.*;
import org.apache.commons.httpclient.methods.*;
import org.json.*;

public class Client {
    
    private Header USER_AGENT = new Header("User-Agent","JSON/1.1.2 Compatible (en-US) Halcyon/0.4.0 Client/0.4.0");
    private Header CONTENT_TYPE = new Header("Content-Type","'application/json'");
    
    private String url;
    
    public Client(String Url)
    {
        url = Url;
    }
    
    public HashMap GET(String Uri, HashMap headers) throws Exception
    {
        return request(new GetMethod(url + Uri), headers);
    }
    
    public HashMap POST(String Uri, Map data, HashMap headers) throws Exception
    {
        PostMethod post = new PostMethod(url + Uri);
		post.setRequestBody(format_post(data));
        return request(post, headers);
    }
    
    public HashMap DELETE(String Uri, HashMap headers) throws Exception
    {
        return request(new DeleteMethod(url + Uri), headers);
    }
    
    public HashMap PUT(String Uri, RequestEntity data, HashMap headers) throws Exception
    {
        PutMethod put = new PutMethod(url + Uri);
        put.setRequestEntity(data);
        return request(put, headers);
    }
    
    private HashMap request(HttpMethodBase method, HashMap headers) throws Exception
    {
        method.setRequestHeader(USER_AGENT);
        method.setRequestHeader(CONTENT_TYPE);
        Object[] keys = headers.keySet().toArray();
        for (Object key : keys)
        {
            method.setRequestHeader(key.toString(), headers.get(key).toString());
        }
        HttpClient client = new HttpClient();
        client.executeMethod(method);
        if (method.getStatusCode() != 200)
        {
            StatusLine line = method.getStatusLine();
            method.releaseConnection();
            throw new HttpException(line);
            
        }
        String res = new String(method.getResponseBody(),"utf-8");
        method.releaseConnection();
        return JSONParse(new HashMap(), res);
    }

	private HashMap JSONParse(HashMap map, String jsonstring)
	{
		try
		{
			JSONObject obj = new JSONObject(jsonstring);
			Iterator<String> reskeys = obj.keys();
	        while (reskeys.hasNext())
	        {
	            String key = reskeys.next();
				JSONParse(map, obj.get(key).toString());
	            map.put(key, obj.get(key));
	        }
		}
		catch (Exception e){}
		return map;
	}
    
    private NameValuePair[] format_post(Map data) throws Exception
    {
        NameValuePair[] result = new NameValuePair[data.size()];
	Object[] keys = data.keySet().toArray();
	int a = 0;
	while (a < keys.length)
	{
            result[a] = new NameValuePair(keys[a].toString(), data.get(keys[a]).toString());
            a++;
	}
	return result;
    }
    
    private class HttpException extends Exception
    {
        public HttpException(StatusLine status)
        {
            super(status.getHttpVersion() + " => " + status.getStatusCode() + " => " + status.getReasonPhrase());
        }
    }
    
    public FileRequestEntity PutFile(File file, String content_type) 
    {
        return new FileRequestEntity(file, content_type);
    }
    
    public InputStreamRequestEntity PutStream(InputStream content)
    {
		return new InputStreamRequestEntity(content);
    }
    
    public ByteArrayRequestEntity PutByteArray(byte[] data)
    {
        return new ByteArrayRequestEntity(data);
    }
    
    public StringRequestEntity PutString(String content, String type, String charSet) throws Exception
    {
        return new StringRequestEntity(content, type, charSet);
    }
}
