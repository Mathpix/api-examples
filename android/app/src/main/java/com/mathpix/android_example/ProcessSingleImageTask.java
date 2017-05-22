package com.mathpix.android_example;

import android.os.AsyncTask;
import android.util.Base64;
import android.util.Log;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.ResponseBody;

public class ProcessSingleImageTask extends AsyncTask<File, Object, String> {

    private static final String TAG = ProcessSingleImageTask.class.getSimpleName();

    @Override
    protected String doInBackground(File... params) {
        if(params.length > 0) {
            File imageFile = params[0];

            if(imageFile != null) {
                try {
                    FileInputStream fis = new FileInputStream(imageFile);
                    byte[] buffer = new byte[(int) imageFile.length()];
                    Log.e(TAG, "image size = " + buffer.length);
                    fis.read(buffer);
                    String base64String = Base64.encodeToString(buffer, Base64.NO_WRAP);

                    OkHttpClient client = new OkHttpClient();

                    MediaType mediaType = MediaType.parse("application/json");
                    RequestBody body = RequestBody.create(mediaType, String.format("{ \"url\" : \"data:image/jpeg;base64,{%s}\" }", base64String));
                    Request request = new Request.Builder()
                            .url("https://api.mathpix.com/v3/latex")
                            .addHeader("content-type", "application/json")
                            .addHeader("app_id", "mathpix")
                            .addHeader("app_key", "139ee4b61be2e4abcfb1238d9eb99902")
                            .post(body)
                            .build();
                    Response response = client.newCall(request).execute();

                    if(response == null) {
                        return "Error: Server connection error";
                    } else {
                        ResponseBody responseBody = response.body();
                        if (responseBody == null) {
                            return "Error: Server connection error";
                        }
                        return responseBody.string();
                    }
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                    return "Error: Image file does not exist";
                } catch (IOException e) {
                    e.printStackTrace();
                    return "Error: Server connection error";
                }
            } else {
                return "No input image file";
            }
        }
        return "No input image file";
    }

    @Override
    protected void onPostExecute(String s) {
        super.onPostExecute(s);

        //Log response string
        Log.e(TAG, s);
    }
}
