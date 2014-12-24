package com.github.ncoe.typecons.exception;

public class ConstructionException extends RuntimeException {
    public ConstructionException() {
        super();
    }

    public ConstructionException(String msg) {
        super(msg);
    }

    public ConstructionException(String message, Throwable cause) {
        super(message, cause);
    }

    public ConstructionException(Throwable cause) {
        super(cause);
    }
}
