#ifndef _CY_IP_H_
#define _CY_IP_H_

int load_ip_data_file(const char* datafile);
char* query(const char* ip);
void release(void);

#endif
