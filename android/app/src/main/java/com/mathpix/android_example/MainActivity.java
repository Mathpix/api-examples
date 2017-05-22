package com.mathpix.android_example;

import android.content.res.AssetManager;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.TextView;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.concurrent.ExecutionException;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        try {
            String result = new ProcessSingleImageTask().execute(getTestFile("limit.jpg")).get();
            ((TextView)findViewById(R.id.resultTextView)).setText(result);
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
        }
    }

    private File getTestFile(String filename) {
        AssetManager assetManager = getAssets();

        InputStream in;
        OutputStream out;

        try {
            in = assetManager.open(filename);
            File cloneFile = new File("/data/data/" + getPackageName() + "/" + filename);

            if(cloneFile.exists()) return cloneFile;

            out = new FileOutputStream(cloneFile);

            byte[] buffer = new byte[1024];
            int read;
            while((read = in.read(buffer)) != -1) {
                out.write(buffer, 0, read);
            }
            in.close();
            out.flush();
            out.close();

            return cloneFile;

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
