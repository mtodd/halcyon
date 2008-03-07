package org.apache.commons.httpclient;

public class HttpContentTooLargeException extends HttpException {
    private int maxlen;

    public HttpContentTooLargeException(String message, int maxlen) {
        super(message);
        this.maxlen = maxlen;
    }
    
    /**
     * @return the maximum anticipated content length in bytes.
     */
    public int getMaxLength() {
        return maxlen;
    }
}
