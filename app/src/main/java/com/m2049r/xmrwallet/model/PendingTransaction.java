/*
 * Copyright (c) 2017 m2049r
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.m2049r.xmrwallet.model;

public class PendingTransaction {
    static {
        System.loadLibrary("monerujo");
    }

    public long handle;

    PendingTransaction(long handle) {
        this.handle = handle;
    }

    public enum Status {
        Status_Ok,
        Status_Error,
        Status_Critical
    }

    public enum Priority {
        Slow(1),
        Blink(0x626c6e6b);

        public static Priority fromInteger(int n) {
            if (n == Blink.getValue()) return Priority.Blink;
            return Priority.Slow;
        }

        public static Priority fromString(String string) {
            try {
                return Priority.valueOf(string);
            } catch (Exception e) {
                return Priority.Slow;
            }
        }

        public int getValue() {
            return value;
        }

        private int value;

        Priority(int value) {
            this.value = value;
        }

    }

    public Status getStatus() {
        return Status.values()[getStatusJ()];
    }

    public native int getStatusJ();

    public native String getErrorString();

    // commit transaction or save to file if filename is provided.
    public native boolean commit(String filename, boolean overwrite);

    public native long getAmount();

    public native long getDust();

    public native long getFee();

    public String getFirstTxId() {
        String id = getFirstTxIdJ();
        if (id == null)
            throw new IndexOutOfBoundsException();
        return id;
    }

    public native String getFirstTxIdJ();

    public native long getTxCount();

}
