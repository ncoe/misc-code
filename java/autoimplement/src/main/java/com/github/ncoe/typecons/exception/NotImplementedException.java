package com.github.ncoe.typecons.exception;

public class NotImplementedException extends RuntimeException {
    public NotImplementedException() {
        super();
    }

    public NotImplementedException(String msg) {
        super(msg);
    }

    public NotImplementedException(String message, Throwable cause) {
        super(message, cause);
    }

    public NotImplementedException(Throwable cause) {
        super(cause);
    }
}
