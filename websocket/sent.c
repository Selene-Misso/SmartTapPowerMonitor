/* sent.c 
 * 
 * 日時を1秒毎にFIFO(名前付きパイプ)に送出する */


#include        <stdio.h>
#include        <stdlib.h>
#include        <string.h>
#include        <sys/types.h>
#include        <sys/stat.h>
#include        <sys/errno.h>
#include        <sys/fcntl.h>
#include        <time.h>


void main()
{
int fd;
char buf[256];
//time_t timer;

        if(mkfifo("FifoTest",0666)==-1){
                perror("mkfifo");
        }

        if((fd=open("FifoTest",O_WRONLY))==-1){
                perror("open");
                exit(-1);
        }

        while(1){
//                timer = time(NULL);
//                sprintf(buf, "%s" , ctime(&timer));
                sprintf(buf, "      57       6      35       0\n");
//              fgets(buf,sizeof(buf)-1,stdin);
//              if(feof(stdin)){
//                      break;
//              }
                write(fd,buf,strlen(buf));
                sleep(1);
        }
        close(fd);
}
