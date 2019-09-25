#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

char* req(char* str, int catport, char* cataddr);						// прототип функции

char* req(char* str, int catport, char* cataddr) {						// сокет си

	struct sockaddr_in SockAddr;
	char buf[4000];														// буфер сообщения
	int Sock = socket( PF_INET, SOCK_STREAM, 0 );
	int b_r;

	memset( &SockAddr, 0, sizeof( SockAddr ) );
	SockAddr.sin_family = PF_INET;
	SockAddr.sin_port = htons( catport );
	inet_pton( PF_INET, cataddr, &SockAddr.sin_addr );
	memset(&buf, 0, sizeof(buf));										// очистка буфера

	if (connect( Sock, (const void*)&SockAddr, sizeof(SockAddr)) == -1) {
		perror("Ошибка соединения");
	}
	else {
		strcpy(buf, str);
		write (Sock, buf, sizeof(buf));									// отсылаем серверу
	}
	b_r = recv(Sock, buf, sizeof(buf)-1, 0);							// читаем ответ сервера
	buf [b_r] = 0;
	shutdown( Sock, SHUT_RDWR );
	close( Sock );
	return &buf;
}

int main( void ) {

	int cat_port = 80;
	int trn_port = 9091;
	char cat_addr[] = "192.168.1.42";
	char trn_addr[] = "127.0.0.1";
	char cat_quest[160];
	char cat_quest1[] = "PUT /rest/thing HTTP/1.0\nHost: Kshisatv.ru\nContent-Length: 22\nContent-Type: application/json; charset=utf-8\n\n{\"user\":\"1\",\"n\":\"0\"}\n\n";
	char cat_quest2[] = "PUT /rest/thing HTTP/1.0\nHost: Kshisatv.ru\nContent-Length:60\nContent-Type: application/json; charset=utf-8\n\n{\"user\":\"1\",\"n\":\"1\",\"procent\":\"";
	char cat_quest3[] = "\",\"ids\":\"";
	char cat_quest4[] = "\",\"filmno\":\"";
	char cat_quest5[] ="\"}\n\n";

	char str2[] = "POST /transmission/rpc HTTP/1.0\n";
	char str3[] = "X-Transmission-Session-Id:";
	char str4[] = "\nContent-Length: 207";
	char str5[] = "\nContent-Type: application/json; charset=utf-8\n\n{\"headers\":{\"type\":\"request\"},\"body\":{\"name\":\"torrent-add\"},\"method\":\"torrent-add\",\"arguments\":";
	char str6[] = "\n\n";
	char str7[] = "\nContent-Length: 136";
	char str8[] = "\nContent-Type: application/json; charset=utf-8\n\n{\"headers\":{\"type\":\"request\"},\"body\":{\"name\":\"torrent-get\"},\"method\":\"torrent-get\",\"arguments\":{\"id\":";
	char str9[] = ", \"fields\": [\"id\", \"percentDone\"]}";

	char ident[76];
	char recv_cat[114];
	char str1[400];
	char procent[5];
	int i;
	char magnet[] = "magnet";
	char filmno[] = "filmno";
	char *retno;
	char retno1[10]; 

	const char *str = req(cat_quest1, cat_port, cat_addr);				// запрос к catalyst rest magnet

	strncpy(recv_cat, str + 200, 113);									// вырезаем магнет ссылку
	retno = strstr(str, filmno);
	strncpy(retno1, retno + 8, 1);

	printf("%s\n", cat_quest1);
	printf("%s\n", str);
	printf("%s\n", retno1);

	if (strstr (recv_cat, magnet)) {
		for ( i = 0; i < 111; i++ ) {
			if (recv_cat[i]=='_') {
				recv_cat[i]='-';
			}
		}
		printf("%s\n", recv_cat);
		memset(str1, 0, sizeof str1);									// очищаем буфер строки

		strncat(str1, str2, strlen (str2));								// сборка запроса 1 к transmission-rpc 
		strncat(str1, str3, strlen (str3));
		strncat(str1, str4, strlen (str4));
		strncat(str1, str5, strlen (str5));
		printf("\n%s\n", str1);
		const char *trans = req(str1, trn_port, trn_addr);				// Запрос 1 к transmission-rpc неверный id пользователя
		printf("\n%s\n", trans);
		strncpy(ident, trans + 45, 75);									// Вырезаем id
		printf("\n%s\n", ident);

		memset(str1, 0, sizeof str1);
		strncat(str1, str2, strlen (str2));								// сборка запроса 2 к transmission-rpc
		strncat(str1, ident, strlen (ident));
		strncat(str1, str4, strlen (str4));
		strncat(str1, str5, strlen (str5));
		strncat(str1, recv_cat, strlen (recv_cat));
		strncat(str1, str6, strlen (str6));
		printf("\n%s\n", str1);
		const char *trans1 = req(str1, trn_port, trn_addr);				// Запрос 2 к transmission-rpc верный id пользователя, установка закачки
		printf("\n%s\n", trans1);

		char *id;														// выделение id закачки из ответа сервера
		char id1[3];
		char inid[] = "id";
		id = strstr(trans1, inid);
		strncpy(id1, id+4, 2);
		if (id1[1] == ',') {											// если однозначный id закачки, удаляем запятую
			id1[1] = '\0';
		}
		printf("\n%s\n", id1);

		memset(str1, 0, sizeof str1);									// очищаем буфер строки
		strncat(str1, str2, strlen (str2));								// сборка запроса 3 к transmission-rpc процент закачки
		strncat(str1, ident, strlen (ident));
		strncat(str1, str7, strlen (str7));
		strncat(str1, str8, strlen (str8));
		strncat(str1, id1, strlen (id1));
		strncat(str1, str9, strlen (str9));
		printf("\n%s\n", str1);
		//for (i = 1; i < 5; i++){
			const char *trans2 = req(str1, trn_port, trn_addr);			// Запрос 3 к transmission-rpc процент закачки
			printf("\n%s\n", trans2);
			strncpy(procent, trans2+136, 4);
			printf("\n%s\n", procent);
			memset(cat_quest, 0, sizeof cat_quest);
			strncat(cat_quest, cat_quest2, strlen (cat_quest2));
			strncat(cat_quest, procent, strlen (procent));
			strncat(cat_quest, cat_quest3, strlen (cat_quest3));
			strncat(cat_quest, id1, strlen (id1));
			strncat(cat_quest, cat_quest4, strlen (cat_quest4));
			strncat(cat_quest, retno1, strlen (retno1));
			strncat(cat_quest, cat_quest5, strlen (cat_quest5));
			printf("\n%s\n", cat_quest);
			char *cat = req(cat_quest, cat_port, cat_addr);				// Сообщение Catalyst-rest скаченные проценты
			printf("\n%s\n", cat);
		// sleep(5);
		//}
	   return 0;
	}
	return 0;
}

