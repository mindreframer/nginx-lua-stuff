#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <uuid/uuid.h>

static char chars[] = { 
	'a','b','c','d','e','f','g','h',  
	'i','j','k','l','m','n','o','p',  
	'q','r','s','t','u','v','w','x',  
	'y','z','0','1','2','3','4','5',  
	'6','7','8','9','A','B','C','D',  
	'E','F','G','H','I','J','K','L',  
	'M','N','O','P','Q','R','S','T',  
	'U','V','W','X','Y','Z' 
}; 

void uuid(char *result, int len)
{
	unsigned char uuid[16];
	char output[24];
	const char *p = (const char*)uuid;

	uuid_generate(uuid);
	memset(output, 0, sizeof(output));

	int i, j;
	for (j = 0; j < 2; j++)
	{
		unsigned long long v = *(unsigned long long*)(p + j*8);
		int begin = j * 10;
		int end =  begin + 10;

		for (i = begin; i < end; i++)
		{
			int idx = 0X3D & v;
			output[i] = chars[idx];
			v = v >> 6;
		}
	}
	//printf("%s\n", output);
	len = (len > sizeof(output)) ? sizeof(output) :  len;
	memcpy(result, output, len);
}

void uuid8(char *result) 
{
	uuid(result, 8);
	result[8] = '\0';
}

void uuid20(char *result) 
{
	uuid(result, 20);
	result[20] = '\0';
}

/*
void uuid24(char *result)
{
	unsigned char uuid[16];
	char output[28];
	const char *p = (const char*)uuid;

	uuid_generate(uuid);
	memset(output, 0, sizeof(output));

	int i, j;
	for (j = 0; j < 4; j++)
	{
		unsigned v = *(unsigned*)(p + j*4);
		int begin = j * 6;
		int end =  begin + 6;

		for (i = begin; i < end; i++)
		{
			int idx = 0X3D & v;
			output[i] = chars[idx];
			v = v >> 5;    // <----it is different here
		}
	}

	memcpy(result, output, 24);
}

int main(int argc, char ** argv)
{
	char out[32] = {'\0'};

	uuid24(out);
	printf("%s\n", out);

	return 0;
}
*/
