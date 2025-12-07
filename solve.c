#include <stdio.h>
#include <string.h>
int main() {
    int t;
    scanf("%d", &t);

    while (t--) {
        char s[105];
        scanf("%s", s);

        int n = strlen(s);
        int i = 0;
        int ok = 0;
        while (i < n - 1) {
            if (s[i] == s[i + 1]) {
                ok = 1;
                break;
            }
            i++;
        }
        if (ok)
            printf("1\n");
        else
            printf("%d\n", n);
    }

    return 0;
}
