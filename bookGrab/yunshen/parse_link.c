#include <stdio.h>
#include <string.h>

//#define TAG1 "<table width=\"100%\" border=\"0\"><tr>"
//#define TAG1 "<p><font size=\"4\"><a target=\"_blank\""
//#define TAG1 "<p><span class=\"td_m\"><a target=\"_blank\""
#define TAG1 "<p style=\"color: rgb(0,0,255)\"><a target=\"_blank\""
//#define TAG1 "<p><a target=\"_blank\""
#define TAG2 "href=\""

static char line[65535];
/** 
 * get links from a html index file, TAG1 means string BEGIN of the
 * url link line
 * 
 * @param argv argv[1] is the input html file which have links
 * @param argc 
 * 
 * @return 
 */
int main(int argv, char *argc[])
{
    FILE *fp;

    if ((fp = fopen(argc[1], "r")) == NULL) {
        fprintf(stderr, "Can't open input file\n");
        return -1;
    }

    while(fgets(line, sizeof(line), fp) != NULL) {
        char *p = line;
        
        while((*p == ' ')||(*p == '\t')) p++;

        if(strncmp(p, TAG1, strlen(TAG1)) == 0) {
            /* we find the link line, get each of the one */
            
            while(p = strstr(p, TAG2)) {
                char *q = p;

                while(*p++ != '"');
                q = p;
                while(*p != '"') p++;
                *p++ = '\0';

                printf("%s\n",q);
            }
        }
    }

    fclose(fp);
    
    return 0;
}
