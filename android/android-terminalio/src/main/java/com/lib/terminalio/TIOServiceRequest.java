/* ------------------------------------------------------------------------------------------------
*
* Copyright (C) 2016 Telit Wireless Solutions GmbH, Germany
*
-------------------------------------------------------------------------------------------------*/

package com.lib.terminalio;

import android.os.Parcel;
import android.os.Parcelable;



class TIOServiceRequest implements Parcelable
{
    private String   mAddress;
    private byte     mCommand;
    private byte []  mData;
    private int      mStatus;
    private int      mValue;
    private int      mId;

    public TIOServiceRequest(int id, String address) {
        mAddress = address;
        mCommand = 1;
        mId      = id;
    }

    public TIOServiceRequest(int id) {
        mCommand = 2;
        mId      = id;
    }

    public TIOServiceRequest(int id, byte [] data ) {
        mCommand = 3;
        mData    = data;
        mId      = id;
    }

    public TIOServiceRequest(int id, byte [] data, int status ) {
        mCommand = 4;
        mData    = data;
        mStatus  = status;
        mId      = id;
    }

    public TIOServiceRequest(int id, int status ) {
        mCommand = 5;
        mStatus  = status;
        mId      = id;
        mValue   = 0;
    }

    public TIOServiceRequest(int id, int status , int value) {
        mCommand = 5;
        mStatus  = status;
        mId      = id;
        mValue   = value;
    }

    public int describeContents() {
        return 0;
    }

    public int getId() { return mId; }

    public int getStatus() {
        return mStatus;
    }

    public String getAddress() {
        return mAddress;
    }

    public String getMessage() {
        return mAddress;
    }


    public byte [] getData() {
        return mData;
    }

    public int getValue() {
        return mValue;
    }

    public void writeToParcel(Parcel out, int flags) {
        out.writeByte( mCommand );
        switch ( mCommand ){
            case 1:
                out.writeInt(mId);
                out.writeString( mAddress );
                break;

            case 2:
                out.writeInt(mId);
                break;

            case 3:
                out.writeInt(mId);
                out.writeByteArray( mData );
                break;

            case 4:
                out.writeInt(mId);
                out.writeInt(mStatus);
                out.writeByteArray( mData );
                break;

            case 5:
                out.writeInt(mId);
                out.writeInt( mStatus );
                out.writeInt( mValue );
                break;
        }
    }

    public static final Parcelable.Creator<TIOServiceRequest> CREATOR
            = new Parcelable.Creator<TIOServiceRequest>() {
        public TIOServiceRequest createFromParcel(Parcel in) {
            return new TIOServiceRequest(in);
        }

        public TIOServiceRequest[] newArray(int size) {
            return new TIOServiceRequest[size];
        }
    };


    private TIOServiceRequest(Parcel in) {
        //region = in.readParcelable(TIOServiceRequest.class.getClassLoader());
        mCommand = in.readByte();

        switch ( mCommand ) {
            case 1:
                mId      = in.readInt();
                mAddress = in.readString();
                break;

            case 2:
                mId      = in.readInt();
                break;

            case 3:
                mId      = in.readInt();
                in.readByteArray(mData);
                break;

            case 4:
                mId     = in.readInt();
                mStatus = in.readInt();
                in.readByteArray(mData);
                break;

            case 5:
                mId     = in.readInt();
                mStatus = in.readInt();
                mValue  = in.readInt();
                break;
        }
    }
}
