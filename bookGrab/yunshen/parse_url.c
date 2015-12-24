#include <stdio.h>
#include <string.h>

#define TAG "href=\""

static char line[65535];
/** 
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

        while(p = strstr(p, TAG)) {
            char *q = p;

            while(*p++ != '"');
            q = p;
            while(*p != '"') p++;
            *p++ = '\0';

            printf("%s\n",q);
        }
    }

    fclose(fp);
    
    return 0;
}
