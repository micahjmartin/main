/// Rotates a nuke around the terminal
/// Usage: nuke [count]
///     count is the number of frames to show (DEFAULT IS INFINITY)
/// Use kill -9 to close
///


#define _GNU_SOURCE
#include <fcntl.h>
#include <signal.h>
#include <stdlib.h>
#include <stdio.h> // needed for printf
#include <sys/ioctl.h> // neded for terminal width
#include <unistd.h> // needed for sleep
#include <string.h>

#define FRAMES 4
#define HEIGHT 21
#define WIDTH 42

#define BUFSIZE 300
void clear() {
	printf("\033[2J" );
	fflush( stdout );
}

void makeframe( char *frame[HEIGHT][WIDTH] ) {
    frame[0][0] = "              .:+osyyyyso+:.";
    frame[0][1] = "          `odNMMMMMMMMMMMMMMNho";
    frame[0][2] = "           /MMMMMMMMMMMMMMMMMM/";
    frame[0][3] = "            -NMMMMMMMMMMMMMMN-";
    frame[0][4] = "             .mMMMMMMMMMMMMm.";
    frame[0][5] = "              `dMMMMMMMMMMh`";
    frame[0][6] = "                yMMMMMMMMy";
    frame[0][7] = "                 ohs++sho";
    frame[0][8] = "                  ./oo/.";
    frame[0][9] = "                 oMMMMMMo";
    frame[0][10] = ":oooooooooooooo  MMMMMMMM  oooooooooooooo-";
    frame[0][11] = "+MMMMMMMMMMMMMM: +MMMMMM+ :MMMMMMMMMMMMMM/";
    frame[0][12] = "`MMMMMMMMMMMMMMNo``/oo/``oNMMMMMMMMMMMMMM`";
    frame[0][13] = " sMMMMMMMMMMMMMMM+      +MMMMMMMMMMMMMMMs";
    frame[0][14] = " `dMMMMMMMMMMMMN/        /MMMMMMMMMMMMMd";
    frame[0][15] = "  `dMMMMMMMMMMN-          -NMMMMMMMMMMh`";
    frame[0][16] = "    oMMMMMMMMm.            .mMMMMMMMNo";
    frame[0][17] = "     .yMMMMMh`              `hMMMMMy.";
    frame[0][18] = "       .omMy                  yMmo.";
    frame[0][19] = "          .                    .";
    frame[0][20] = "";

    frame[1][0] = "                    `hyyo+:.";
    frame[1][1] = "                    `MMMMMMMNho-";
    frame[1][2] = "                    `MMMMMMMMMMMmo`";
    frame[1][3] = "                    `MMMMMMMMMMMMMMs.";
    frame[1][4] = "                    `MMMMMMMMMMMMMMMN+";
    frame[1][5] = "  `s:`              `MMMMMMMMMMMMMMMMd:";
    frame[1][6] = " `dMMNh+.           `MMMMMMMMMMMMNy/`";
    frame[1][7] = " sMMMMMMMms:         +shNMMMMMdo-";
    frame[1][8] = ".MMMMMMMMMMMNh+.  ./oo/.`+my/`";
    frame[1][9] = "/MMMMMMMMMMMMMM: oMMMMMMo";
    frame[1][10] = "oMMMMMMMMMMMMMN  MMMMMMMM";
    frame[1][11] = "/MMMMMMMMMMMMMM: +MMMMMM+";
    frame[1][12] = "`NMMMMMMMMMMNy/`  `/oo/``+my/`";
    frame[1][13] = " +MMMMMMMdo-         +shNMMMMMdo-";
    frame[1][14] = "  yMMNy/`            NMMMMMMMMMMMNy/`";
    frame[1][15] = "   +-                NMMMMMMMMMMMMMMMd:";
    frame[1][16] = "                     NMMMMMMMMMMMMMMMs";
    frame[1][17] = "                     NMMMMMMMMMMMMMh-";
    frame[1][18] = "                     NMMMMMMMMMMNs-";
    frame[1][19] = "                     NMMMMMMNdo:";
    frame[1][20] = "                     syso+:.";

    frame[2][0] = "";
    frame[2][1] = "         `:                   `-";
    frame[2][2] = "       -yNMh`                `dMNs.";
    frame[2][3] = "     -hMMMMMm.              .mMMMMMy.";
    frame[2][4] = "    sMMMMMMMMN-            -NMMMMMMMN+";
    frame[2][5] = "  `dMMMMMMMMMMN/          /NMMMMMMMMMMy";
    frame[2][6] = "  dMMMMMMMMMMMMM+        +MMMMMMMMMMMMMy";
    frame[2][7] = " +MMMMMMMMMMMMMMMo      oMMMMMMMMMMMMMMM/";
    frame[2][8] = " NMMMMMMMMMMMMMN+``/oo/.`+NMMMMMMMMMMMMMm";
    frame[2][9] = "-MMMMMMMMMMMMMM: oMMMMMMo :MMMMMMMMMMMMMM-";
    frame[2][10] = ".++++++++++++++  NMMMMMMM` +oooooooooooos-";
    frame[2][11] = "                 +MMMMMMo";
    frame[2][12] = "                  `/oo/`";
    frame[2][13] = "                 +hs++sho";
    frame[2][14] = "                sMMMMMMMMy";
    frame[2][15] = "              `yMMMMMMMMMMd`";
    frame[2][16] = "             `dMMMMMMMMMMMMm.";
    frame[2][17] = "            .mMMMMMMMMMMMMMMN-";
    frame[2][18] = "           -NMMMMMMMMMMMMMMMMN:";
    frame[2][19] = "           +hNMMMMMMMMMMMMMMMds`";
    frame[2][20] = "              .:+oyyhhhyso/-`";

    frame[3][0] = "             `-/osyhh`";
    frame[3][1] = "          :sdMMMMMMMM`";
    frame[3][2] = "       .sNMMMMMMMMMMM`";
    frame[3][3] = "     .yMMMMMMMMMMMMMM`";
    frame[3][4] = "    +NMMMMMMMMMMMMMMM`";
    frame[3][5] = "   .yNMMMMMMMMMMMMMMM`              `:o`";
    frame[3][6] = "      :smMMMMMMMMMMMM`           .+hMMMh";
    frame[3][7] = "         .+hNMMMMNhs+         :smMMMMMMM+";
    frame[3][8] = "            `:smo``/oo/.  `/hNMMMMMMMMMMN";
    frame[3][9] = "                 +MMMMMMo :MMMMMMMMMMMMMM-";
    frame[3][10] = "                 NMMMMMMM` NMMMMMMMMMMMMM:";
    frame[3][11] = "                 +MMMMMMo :MMMMMMMMMMMMMM-";
    frame[3][12] = "            `:smo``/oo/`  `/yNMMMMMMMMMMm";
    frame[3][13] = "         .+hMMMMMNhs+         :smMMMMMMM/";
    frame[3][14] = "      :smMMMMMMMMMMMM`           .+hMMMy";
    frame[3][15] = "   .yNMMMMMMMMMMMMMMM`              `:o";
    frame[3][16] = "    +NMMMMMMMMMMMMMMM`";
    frame[3][17] = "     .yMMMMMMMMMMMMMM`";
    frame[3][18] = "       .oNMMMMMMMMMMM`";
    frame[3][19] = "          -sdMMMMMMMM`";
    frame[3][20] = "              -/osyhh";
}

void printframe( int i, int width, char *frame[HEIGHT][WIDTH] ) {
    for( int j = 0; j < 21; j++) {
	printf("% *s",(width-WIDTH)/2,"");
	printf("%s\n",frame[i][j]);
    }
}

void INThandler(int sig) { 
    signal(SIGINT, INThandler);
}
void TRMhandler(int sig) { 
    signal(SIGTERM, TRMhandler);
}
void STPhandler(int sig) { 
    signal(SIGTSTP, STPhandler);
}

int main( int argc, char * argv[] ) {
    char * buf = malloc(sizeof(char)*BUFSIZE);
    int len = readlink("/proc/self/exe", buf, BUFSIZE);
    buf[len] = '\0';
    strncat(buf, " &",BUFSIZE);
    printf("%s\n",buf);
    free(buf);
    signal(SIGTSTP, STPhandler);
    signal(SIGTERM, TRMhandler);
    signal(SIGINT, INThandler);
    char * frame[HEIGHT][WIDTH];
    makeframe( frame );
    struct winsize w;
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
    int width = w.ws_col;
    int go;
    int count = 0;
    if( argc > 1 ) {
	go = atoi(argv[1]);
    } else {
	go = -1;
    }
    while(go != 0) {
	    count++;
	    clear();
	    printf("\033[%d;%dH",0,0);
	    printframe(count % FRAMES,width, frame);
	    //system("echo -en \"\007\" >> /dev/tty20");
	    sleep(1);
	    go--;
    }
    return 0;
}