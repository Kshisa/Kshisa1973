#include <openssl/ssl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <unistd.h>
#include <netdb.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <error.h>
#include <openssl/err.h>
#include <openssl/bio.h>
#define PORT 1252

using namespace std;
struct SSLClientCtx
{
 SSL_CTX * ctx;
 SSL  * ssl;
 BIO  *  sbio;
 string  name;
 int   s;

 SSLClientCtx( SSL_CTX * sslctx )
  : ctx( sslctx ), ssl( NULL ), sbio( NULL ), s(-1)

 {

 }

 

 void release()

 {

  int r  = SSL_shutdown( ssl );

  if( !r )

  {

   shutdown( s, 2 );

   r  = SSL_shutdown( ssl );

   close( s );

  }

 

  SSL_free( ssl );

 }

 

};

 

const char * pass;

BIO * bio_err;

 

int berr_exit( const char * string)

{

 BIO_printf(bio_err,"%s\n",string);

 ERR_print_errors( bio_err );

 exit(0);

}

 

static int password_cb( char *buf, int num, int rwflag, void *userdata)

{

 if( (unsigned)num < strlen(pass)+1)

  return(0);

 

 strcpy(buf,pass);

 return( strlen(pass) );

}

 

bool openssl_init( SSL_CTX ** ctx,  const char * keyfile,

     const char * certfile,

     const char * password,

     const char * ca )

{

 const SSL_METHOD * meth;

 SSL_CTX * tempCtx;

 

 SSL_load_error_strings();

 

 if( SSL_library_init() <= 0 )

 {

  printf( "Fail SSL init\n" );

  return false;

 }

 

 bio_err = BIO_new_fp( stderr, BIO_NOCLOSE );

 meth = SSLv23_method();

 

 tempCtx = SSL_CTX_new( meth );

 

 printf( "SSL open client cert\n" );

 if(  ( SSL_CTX_use_certificate_file( tempCtx, certfile, SSL_FILETYPE_PEM ) ) <= 0 )

 {

  berr_exit(  "SSL_CTX_use_certificate_chain_file fail" );

 }

 printf( "OK\n" );

 

 SSL_CTX_set_default_passwd_cb( tempCtx, password_cb );

 pass = password;

 

 printf( "SSL open private key\n" );

 if( SSL_CTX_use_PrivateKey_file( tempCtx, keyfile, SSL_FILETYPE_PEM ) <= 0 )

 {

  berr_exit( "Fail!\n" );

 }

 printf( "OK\n" );

 

 if( ca )

 {

  printf( "SSL load CA\n" );

  if( (SSL_CTX_load_verify_locations( tempCtx, ca,0)) <= 0 )

  {

   berr_exit("Fail!\n");

  }

  printf( "OK\n" );

 }

 

    SSL_CTX_set_verify_depth( tempCtx, 1 );

 

 *ctx = tempCtx;

 return true;

}

 

bool check_cert( SSL * ssl, char * nameOut, int maxNameSize )

{

 X509 *peer;

 char *line;

 

 printf( "Verifying cert\n" );

 if( SSL_get_verify_result( ssl ) != X509_V_OK )

 {

  printf( "Cannot verify certyficate\n" );

 }

 

 printf( "Getting peer certificate\n" );

 peer = SSL_get_peer_certificate( ssl );

 

 if( !peer )

 {

  printf( "No client certyficate\n" );

  return false;

 }

    else

    {

        printf("Server cert:\n");

        line = X509_NAME_oneline(X509_get_subject_name(peer), 0, 0);

        printf("Subject: %s\n", line);

        free(line);

        line = X509_NAME_oneline(X509_get_issuer_name(peer), 0, 0);

        printf("Issuer: %s\n", line);

    }

 X509_NAME_get_text_by_NID( X509_get_subject_name( peer ), NID_commonName, nameOut, maxNameSize );

 

 return true;

}

 

int tcp_connect( const char * host, int port )

{

 struct  hostent *hp;

 struct  sockaddr_in addr;

 int  sock;

 

 if( !( hp = gethostbyname(host)) )

 {

  berr_exit("Bad host name!\n");

 }

 

 memset(&addr,0,sizeof(addr));

 addr.sin_addr=*(struct in_addr*)

 hp->h_addr_list[0];

 addr.sin_family=AF_INET;

 addr.sin_port=htons(port);

 

 if( ( sock = socket(AF_INET,SOCK_STREAM,IPPROTO_TCP)) < 0 )

 {

  berr_exit("Socket creation ERROR!\n");

 }

 

 if( connect(sock,(struct sockaddr *)&addr,sizeof(addr)) < 0 )

 {

  berr_exit("Socket connection ERROR!\n");

 }

 

 return sock;

}

 

int tcp_listen()

{

 int sock;

 struct sockaddr_in sin;

 int val=1;

 

 if(( sock = socket( AF_INET,SOCK_STREAM,0) ) < 0 )

 {

  printf( "Fail create listen socket!\n" );

  exit( 1 );

 }

 

 int so_reuseaddr = 1;

 

 if( setsockopt( sock,SOL_SOCKET,SO_REUSEADDR, &so_reuseaddr, sizeof(so_reuseaddr) ) < 0 )

 {

  exit( 1 );

 }

 

 memset(&sin,0,sizeof(sin));

 sin.sin_addr.s_addr=INADDR_ANY;

 sin.sin_family=AF_INET;

 sin.sin_port=htons(PORT);

 setsockopt(sock,SOL_SOCKET,SO_REUSEADDR,

 &val,sizeof(val));

 

 printf( "Socket binding!\n" );

 if( bind( sock,( struct sockaddr *)&sin, sizeof(sin) ) < 0 )

 {

  berr_exit( "Binding error!\n" );

 }

 printf( "OK\n" );

 

 printf( "Waiting for client!\n" );

 listen( sock, 5 );

 printf( "OK\n" );

 

 return ( sock );

}

 

bool accept_client( int serverSock, SSLClientCtx & clientCtx )

{

 char nameBuffer[256];

 

 clientCtx.s = accept( serverSock, 0, 0 );

 

 clientCtx.sbio = BIO_new_socket( clientCtx.s, BIO_NOCLOSE );

 clientCtx.ssl = SSL_new( clientCtx.ctx );

 SSL_set_bio( clientCtx.ssl, clientCtx.sbio, clientCtx.sbio );

 

 if( ( SSL_accept( clientCtx.ssl ) <= 0 ))

 {

  return false;

 }

 

 if( ! check_cert( clientCtx.ssl, nameBuffer, 256 ) )

 {

  return false;

 }

 

 clientCtx.name = string( nameBuffer, 256 );

 

 return true;

}

 

bool server()

{

 SSL_CTX * ctx = NULL;

 int  sock;

 

 char keyfile[]    = "keys/server.key";

 char clientCert[]  = "keys/server.pem";

 char password[]   = "kuba";

 char cacert[]   = "keys/cacert.pem";

 

 if( !openssl_init( &ctx, keyfile, clientCert, password, cacert ) )

 {

  return 1;

 }

 SSL_CTX_set_verify( ctx, SSL_VERIFY_PEER, NULL );

 

 sock = tcp_listen();

 

 fd_set  readFdSet;

 

 int  result;

 int  nfds = sock+1;

 int  r;

 

 char  recvBuffer[1024];

 int  recvBufferSize = 1024;

 int  readBytes  = 0;

 char  sendBuffer[1284];

 int  bytesToSend  = 0;

 

    SSLClientCtx newClientCtx( ctx );

    int written = 0;

 

 while( 1 )

 {

  FD_ZERO( &readFdSet );

  FD_SET( 0, &readFdSet );

  FD_SET( sock, &readFdSet );

 

        FD_SET( newClientCtx.s, &readFdSet );

        if( newClientCtx.s >= nfds )

            nfds = newClientCtx.s + 1;

 

  result = select( nfds, &readFdSet, NULL, NULL, NULL );

 

  if( result > 0 )

  {

   if( FD_ISSET( 0, &readFdSet )  )

   {

    readBytes = read( 0, recvBuffer, recvBufferSize - 1 );

    recvBuffer[ readBytes ] = 0;

 

    if( recvBuffer[ 0 ] == 'q' )

    {

     printf( "Exiting\n" );

     break;

    }

    else

    {

     printf( "ERROR!\n" );

    }

   }

 

   if( FD_ISSET( sock, &readFdSet ) )

   {

 

    if( accept_client( sock, newClientCtx ) )

    {

     printf( "%s connected!\n", newClientCtx.name.c_str() );

 

    }

    else

    {

     printf( "Connection error!\n" );

    }

   }

 

            if( FD_ISSET( newClientCtx.s, &readFdSet ) )

            {

                r = SSL_read( newClientCtx.ssl, recvBuffer, recvBufferSize );

                switch( SSL_get_error( newClientCtx.ssl, r ) )

                {

                    case SSL_ERROR_NONE:

                        recvBuffer[ r ] = 0;

                        printf( "%s: %s\n", newClientCtx.name.c_str(),  recvBuffer );

                        bytesToSend = sprintf( sendBuffer, "%s:%s", newClientCtx.name.c_str(), recvBuffer );

                        while( written < bytesToSend )

                        {

                            r  = SSL_write( newClientCtx.ssl, sendBuffer + written, bytesToSend - written );

                            written += r;

                            if( SSL_get_error( newClientCtx.ssl, r ) != SSL_ERROR_NONE)

                            {

                                    printf( "Sending error %s (%d)\n", newClientCtx.name.c_str(), newClientCtx.s );

                            }

                        }

                        written = 0;

                        break;

                    default:

                        printf( "%s disconnected\n", newClientCtx.name.c_str() );

                        newClientCtx.release();

      break;

                }

            }

 

  }

  else if( result < 0 )

  {

   perror( "Select error\n" );

  }

 }

 

 printf( "Exiting!\n" );

 

 shutdown( sock, 2 );

 close( sock );

 

 if( ctx )

 {

  SSL_CTX_free(ctx);

 }

 return 0;

}

 

bool client()

{

 SSL_CTX * ctx = NULL;

 

 char keyfile[]   = "keys/client.key";

 char clientCert[] = "keys/client.pem";

 char password[]  = "kuba";

 char cacert[]  = "keys/cacert.pem";

 

 fd_set  readFdSet;

 int  result;

 int  nfds = 0;

 SSL  *ssl;

 BIO  *sbio;

 int  r;

 char    *line;

 X509    *peer;

 

 if( !openssl_init( &ctx, keyfile, clientCert, password, cacert ) )

 {

  return 1;

 }

 

 int  s;

 char  recvBuffer[1024];

 int  recvBufferSize = 1280;

 int  maxStdInMsgSize = 1024;

 int  readBytes  = 0;

 

 printf( "Connecting" );

 s = tcp_connect( "localhost", PORT );

 

 nfds = s+1;

 

 ssl  = SSL_new( ctx );

 sbio = BIO_new_socket( s, BIO_NOCLOSE );

 SSL_set_bio( ssl, sbio, sbio );

 printf( "OK\n" );

 

 printf( "SSL connect\n" );

 if( SSL_connect( ssl ) <= 0 )

 {

  berr_exit( "ERROR!\n" );

 }

 else

 {

     peer = SSL_get_peer_certificate( ssl );

     printf("Server cert:\n");

        line = X509_NAME_oneline(X509_get_subject_name(peer), 0, 0);

        printf("Subject: %s\n", line);

        free(line);

        line = X509_NAME_oneline(X509_get_issuer_name(peer), 0, 0);

        printf("Issuer: %s\n", line);

 }

 printf( "OK\n" );

 

 while( 1 )

 {

  FD_ZERO( &readFdSet );

  FD_SET( 0, &readFdSet );

  FD_SET( s, &readFdSet );

 

  result = select( nfds, &readFdSet, NULL, NULL, NULL );

 

  if( result > 0 )

  {

   if( FD_ISSET( 0, &readFdSet )  )

   {

    readBytes = read( 0, recvBuffer, maxStdInMsgSize - 1 );

    recvBuffer[ readBytes ] = 0;

 

    if( recvBuffer[ 0 ] == 'q' )

    {

     printf( "exit command\n" );

     break;

    }

 

    else if( strncmp( recvBuffer, "m ", 2 ) == 0 )

    {

     r  = SSL_write( ssl, recvBuffer + 2, readBytes - 2 );

     switch( SSL_get_error( ssl, r ) )

     {

      case SSL_ERROR_NONE:

       if( readBytes - 2 != r )

        berr_exit("Write ERROR!");

        break;

      default:

       berr_exit("SSL writting ERROR!");

     }

    }

    else

    {

     printf( "q - for exit, m - message\n" );

    }

 

   }

 

   if( FD_ISSET( s, &readFdSet ) )

   {

    r = SSL_read( ssl, recvBuffer, recvBufferSize - 1 );

    if( SSL_get_error( ssl, r ) == SSL_ERROR_NONE )

    {

     recvBuffer[ r ] = 0;

     printf( "%s\n", recvBuffer );

    }

    else

    {

     printf( "Client exited!\n" );

     break;

    }

   }

 

  }

  else if( result < 0 )

  {

   perror( "ERROR select\n" );

  }

 }

 

 SSL_shutdown( ssl );

 shutdown( s, 2 );

 close( s );

 SSL_free( ssl );

 

 if( ctx )

 {

  SSL_CTX_free(ctx);

 }

 

 printf( "Exiting!\n" );

 return 0;

}

 

int main( int argc, char * argv [] )

{

 

 if( argc < 2 )

 {

  printf( "USAGE:\n\tSSLEchoConsole 0/1 (0 - server, 1 - klient)\n" );

  return 1;

 }

 

 char * input = argv[1];

 

    if(input[0] == '0')

    {

        //Server

        server();

    }

    else if(input[0] == '1')

    {

        //Client

        client();

    }

    else

    {

        printf( "ERROR: Invalid input option - 0/1!\n" );

  return 1;

    }

    return 0;

