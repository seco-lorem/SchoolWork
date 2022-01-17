import java.net.URL;
import java.net.Socket;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.List;
import java.util.ArrayList;
import java.io.*;

public class ParallelFileDownloader extends Thread{
    
    // Properties
    String url;
    String host;
    String path;
    Socket socket;
    PrintStream outputStream;
    BufferedReader inputStream;
    String[] fileSlices;
    
    // Properties for Threads
    int contentSize;
    int sliceNo;
    String fileSlice;
    int lowerBound;
    int upperBound;
    ParallelFileDownloader parent;
    
    // Constructor
    public ParallelFileDownloader(String url) {
        try {
            this.url = url;
            URL urlObject;
            if (!url.substring(0, 4).equals("http"))
                urlObject = new URL("http://" + url);
            else
                urlObject = new URL(url);
            host = urlObject.getHost();
            path = urlObject.getPath();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        initiate();
    }
    
    // Methods
    public void setSlice(int index, int lowerBound, int upperBound, ParallelFileDownloader parentDownloader, int contentSize){
        this.sliceNo = index;
        this.lowerBound = lowerBound;
        this.upperBound = upperBound;
        this.parent = parentDownloader;
        this.contentSize = contentSize;
    }
    
    private void initiate() {
        try {
            socket = new Socket(host, 80);
            inputStream = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            outputStream = new PrintStream(socket.getOutputStream());
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    public void terminate() {
        if (socket != null){
            try {
                inputStream.close();
                outputStream.close();
                socket.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Elinde gitmen gereken path var:  this.path   (String)    ÖR: /100/balls.txt
     *                   host adý var:  this.host   (String)    ÖR: www.textfiles.com
     *       o hosta kurulu soket var:  this.socket (Socket)
     *     o soketten streamlerin var:  this.outputStream (PrintStream), this.inputStream (BufferedReader)
     * 
     * O file'ýn boundaryler arasýndaki kýsmýný indirmen gerekiyor.
     * Boundaryler (-1, -1) ise tamamýný indirmen gerekiyor.
     */
    public void downloadIn(int connectionCount) {
        
        
        outputStream.println("HEAD " + this.path + " HTTP/1.1");
        outputStream.println("Host: " + this.host);
        outputStream.println("Connection: close ");
        outputStream.println("");
        outputStream.flush();
        int contentSize = 0;
        int returnHTTP = 0;
        try{
            boolean readingLinks = false;
            String line = inputStream.readLine();
            while (line != null) {
                
                //System.out.println(line);
                
                if(line != null && line.contains("Content-Length"))
                {
                    String contentLength = line.substring(line.lastIndexOf("Content-Length:") + 1);
                    if(contentLength!= null)
                    {
                        Matcher matcher = Pattern.compile("\\d+").matcher(contentLength);
                        matcher.find();
                        contentSize = Integer.valueOf(matcher.group());
                    }
                    
                    fileSlices = new String[connectionCount];
                    
                }else if(line != null && line.contains("HTTP/1.1"))
                {
                    String messageHTTP = line.substring(line.lastIndexOf("HTTP/1.1") + 8);
                    Matcher matcher = Pattern.compile("\\d+").matcher(messageHTTP);
                    matcher.find();
                    returnHTTP = Integer.valueOf(matcher.group());
                    
                }
                
                line = inputStream.readLine();
                
            }
            socket.close();
        }catch(Exception e)
        {
            e.printStackTrace();
        }
        
        
        
        //System.out.println("The number is " + contentSize);
        //System.out.println("The http get is " + returnHTTP);
        
        if(returnHTTP == 200)
        {
            try{
                System.out.print(" (size = " + contentSize + ") is being downloaded\nFile parts: ");
                // The number of bytes downloaded through each connection differ by at most one
                // byte. It is assumed that contentSize is not divisible by connectionCount,
                // contentSize / connectionCount + 1 bytes are downloaded through the first
                // contentSize - (contentSize / connectionCount) * connectionCount connections,
                // and contentSize / connectionCount bytes are downloaded through the remaining
                // connections.
                int overflowAmount = contentSize - (contentSize / connectionCount) * connectionCount;
                int lastIndex = 0;
                for (int i = 0; i < connectionCount; i++){
                    ParallelFileDownloader newConnection = new ParallelFileDownloader(url);
                    int byteAmount = contentSize / connectionCount;
                    if ( i < overflowAmount)
                        byteAmount++;
                    
                    if (i != connectionCount - 1)
                        System.out.print(lastIndex + ":" + (lastIndex + byteAmount - 1) + "(" + byteAmount + "), ");
                    else
                        System.out.print(lastIndex + ":" + (lastIndex + byteAmount - 1) + "(" + (contentSize - lastIndex) + ")\n");
                    
                    newConnection.setSlice(i, lastIndex, lastIndex + byteAmount - 1, this, contentSize);
                    lastIndex+= byteAmount;
                    newConnection.start();
                }
                
            }catch(Exception e)
            {
                //e.printStackTrace();
            }
        }else{
            System.out.println(" is not found");
        }
        
        
    }
    
    private void sliceDone(){
        try{

            fileSlice = fileSlice.substring(0, fileSlice.length() - 1);   // Avoid extra newline in end of slice
            parent.fileSlices[sliceNo] = fileSlice;
            String file = "";
            terminate();
            // If all slics are done reading
            for (int i = 0; i < parent.fileSlices.length; i++){
                if (parent.fileSlices[i] == null)
                    return;
                file += parent.fileSlices[i];
            }
            
            // Write it
            PrintWriter writerFile = new PrintWriter(path.substring(path.lastIndexOf("/") + 1), "UTF-8");
            writerFile.write(file);
            writerFile.close();
        }catch(Exception e)
        {
            e.printStackTrace();
        }
    }
    
    
    public void readSlice(){
        try{
            Socket nwSocket = new Socket(this.host, 80);
            PrintStream nwStream = new PrintStream(nwSocket.getOutputStream());
            fileSlice = "";
            BufferedReader inputStream1 = new BufferedReader(new InputStreamReader(nwSocket.getInputStream()));
            if(lowerBound == -1 && upperBound == -1)
            {
                nwStream.println("GET " + this.path + " HTTP/1.1");
                nwStream.println("Host: " + this.host );
                nwStream.println();
                nwStream.flush();
            }else
            {
                nwStream.println("GET " + this.path + " HTTP/1.1");
                nwStream.println("Host: " + this.host );
                nwStream.println("Range: bytes=" + lowerBound + "-" + upperBound);
                nwStream.println();
                nwStream.flush();
            }
            
            String outToFile = inputStream1.readLine();
            fileSlice = "";
            boolean checkForEndHeader = false;
            while(outToFile != null)
            {
                if(checkForEndHeader)
                    fileSlice +=  outToFile + "\n";
                
                if(!checkForEndHeader && outToFile.contains("Content-Type"))
                {
                    checkForEndHeader = true;
                    outToFile = inputStream1.readLine();
                }
                outToFile = inputStream1.readLine();
            }
            int highestValue;
            if(contentSize >= upperBound)
            {
                highestValue = upperBound;
            }else
            {
                highestValue = contentSize;
            }
            nwSocket.close();
        }catch(Exception e)
        {
            e.printStackTrace();
        }
    }
    
    public void downloadFilesInContents(int connectionCount) {
        // HTTP GET
        outputStream.println("GET " + path + " HTTP/1.0");
        outputStream.println();
        System.out.println("Index file is downloaded");
        List<String> links = new ArrayList<String>();
        try {
            // While reading HTTP response contents (not headers)
            boolean readingLinks = false;
            int lineFile = 1;
            String line = inputStream.readLine();
            while (line != null) {
                
                if (readingLinks) {
                    // Download the linked file in each line
                    links.add(line);
                    
                }
                else if (line.equals(""))
                    readingLinks = true;
                line = inputStream.readLine();
            }
        }
        
        catch (Exception e) {
            e.printStackTrace();
        }
        
        String[] linksArr = links.toArray(new String[links.size()]);
        
        System.out.println("There are " + links.size() + " files in the index.");
        
        for(int i = 0; i < links.size(); i++)
        {
            System.out.print(i + 1  + ". " + linksArr[i]);
            ParallelFileDownloader fileDownloader = new ParallelFileDownloader(linksArr[i]);
            fileDownloader.downloadIn(connectionCount);
            fileDownloader.terminate();
        }
    }
    
    @Override
    public void run() {
        try {
            readSlice();
            sliceDone();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    public static void main(String args[]) {
        ParallelFileDownloader fileDownloader = new ParallelFileDownloader(args[0]);
        System.out.println("URL of the index file: " + args[0]);
        System.out.println("Number of parallel connections: " + args[1]);
        
        fileDownloader.downloadFilesInContents(Integer.parseInt(args[1]));
        fileDownloader.terminate();
    }
}