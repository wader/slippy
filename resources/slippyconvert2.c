
#include <stdio.h>

typedef struct SlippyLevel_s {
  char *author;
  char *data[9];
} SlippyLevel_t;

SlippyLevel_t slippy_levels[] = {
  {
    "Mattias Wadman",
    {
      "OOOOOOOOOOOOOOOO",
      "O              O",
      "O  #########   O",
      "O  #P      #   O",
      "O  #    M  # $ O",
      "O  #       #   O",
      "O  #########   O",
      "O              O",
      "OOOOOOOOOOOOOOOO"
    }
  },
  {
    "Mattias Wadman",
    {
      "OOOOOOOOOOOOOOOO",
      "O              O",
      "O  #######  M  O",
      "O  #     #     O",
      "O  #  $  #  P  O",
      "O  #     #  O  O",
      "O  #######     O",
      "O              O",
      "OOOOOOOOOOOOOOOO"
    }
  },
  {
    "Martin Hock",
    {
      "OOOOOOOOOOOOOOOO",
      "O$$$$$$#  #$$$$O",
      "O#######  #####O",
      "O$#    M       O",
      "O$#   O     MM O",
      "O$#            O",
      "O##   M        O",
      "O             PO",
      "OOOOOOOOOOOOOOOO"
    }
  },
  {
    "Martin Hock",
    {
      "O#O#OOO OOOOOOOO",
      "O   O$$$$$$O O O",
      " M  OOOOOO O P #",
      "    #$$$$$$O M O",
      "OOOOOOOOOOOO   O",
      "O$$$O  O    O#OO",
      "O$OOO     M O$$O",
      " $O   O   M #$$ ",
      "O$O OOO#OOOOOOOO"
    }
  },
  {
    "Martin Hock",
    {
      "OOOOOOOOOOOOOOOO",
      "OP     O### $O$O",
      "O M M M#O#$  O#O",
      "O   O    #OOOO$O",
      "O O      M     O",
      "O#O    M       O",
      "O$O M O        O",
      "O$O   O        O",
      "OOOOOOOOOOOOOOOO"
    }
  },
  {
    "Martin Hock",
    {
      "OOOOOOOOOOOOOOOO",
      "OP          #$$O",
      "OOO    M  M O$$O",
      "O$#         O$$O",
      "OOO  M    M OOOO",
      "O$#         #$$O",
      "OOO    M    O$$O",
      "O$#         O$$O",
      "OOOOOOOOOOOOOOOO"
    }
  },
  {
    "Martin Hock",
    {
      "O   O   O   O OO",
      "               O",
      "O              O",
      "        M    M O",
      "#O#O M M       O",
      "#$$O   ####OO  O",
      "#$$OOOOOO#O    O",
      "#$$$$$$$$$O  M O",
      "###########P  OO"
    }
  },
  {
    "Martin Hock",
    {
      "OOOOOO  OOOOOOOO",
      "O          #$$$O",
      "O      MO  # M O",
      "O       M  ## #O",
      "O             PO",
      "O          ####O",
      "      M    #$$$O",
      "O          #$$$O",
      "OOOOOOOOOOOOOOOO"
    }
  },
  {
    "Martin Hock",
    {
      "OOOOOOOO#OOOOOOO",
      "OP        OO$$$O",
      "O      M   #$$$O",
      "OOOOO    M OOOOO",
      "O$$$# M    M   O",
      "OOOOO#OO       O",
      "O   O$$OO      O",
      "O   O$$O$O     O",
      "OOOOOOOO$OOOOOOO"
    }
  },
  {
    "Martin Hock",
    {
      "OO   OOOOOOOOO$O",
      "OO M # O  O   #O",
      "OPM  #    #   OO",
      "O    O    O    O",
      "OO##OOO##OOO##OO",
      "O    OOMM O$$$$O",
      "OOMM #  M O$$OOO",
      "#    O    O$$O  ",
      "OOOOOOOOOOOOOO O"
    }
  },
  {
    "Carlos Rodriguez",
    {
      "OOOOOOOOOOOOOOOO",
      "O$#        #$$$O",
      "O$#    P   OOOOO",
      "O$# O       #$$O",
      "O$#   M     #M$O",
      "O$# M       #O#O",
      "O$#  M MO   #$$O",
      "O$#   O     #$$O",
      "OOOOOOOOOOOOOOOO"
    }
  },
  {
    "Tae-Ho Kim",
    {
      "OOOOOOOOOOOOOOOO",
      "O$$$#    O$$$$$$",
      "OOOOO    OMO#OOO",
      "                ",
      "OPMMMMMM     OOO",
      "OO#     O    ##O",
      "O$#OOOOOOO#OOO$O",
      "O$$$$$$O$$$$$O$O",
      "OOOOOOOOOOOOOOOO"
    }
  },
  {
    "Tae-Ho Kim",
    {
      "OOOOOOOOOOOOOOOO",
      "O     ##$$#$$$$O",
      "OPM MMMOOOO#OOOO",
      "$OO        M#$$#",
      "$$O   M OOM #$$O",
      "$$O     OO  OOOO",
      "OOO#O   OOM #$$O",
      "#$$##   OO  #$$$",
      "OOOOOOOOOOOOOOOO"
    }
  },
  {
    "Martin Hock",
    {
      "OOOOOOO O       ",
      "O$$$$$$$O# O  O ",
      "O#O#OOO#O#  M P ",
      "O #   O O       ",
      "OO              ",
      "O M  O  O M M   ",
      "O      O M      ",
      "OO          M  O",
      "OOOOOOO#OOOOOOOO"
    }
  },
  {
    "Andreas Ess' brother",
    {
      "OOOOOOO OOOOOOOO",
      "O   OOOOOOOOO  O",
      "OO        O  M O",
      "O              O",
      "O M M          O",
      "O#O#OOO        O",
      "O$$$O$O   M    O",
      "O$$$#$O        O",
      "OOOOOOO  P OOOOO"
    }
  },
  {
    "Tae-Ho Kim",
    {
      "OO      OOOOOOOO",
      "#       O$$O$#$$",
      "O  MMM  OO#OOOMO",
      "#          #$O$$",
      "O  MMM  OMMOOOOO",
      "#  MPM     O#$$$",
      "O#OOOOO#OO#O$OMO",
      "#$$M#M$#O$#O$O$$",
      "OOOOOOOOOOOOOOOO"
    }
  },
  {
    "Daniel Walls",
    {
      "OOOO    OOOOOOOO",
      "O$$O M    ##$$$O",
      "O$$#   O  ##$$$O",
      "OMOO  M   ##$$$O",
      "OP M    OO  O#OO",
      "O   M      OO#OO",
      "OOOO##OO#O#   OO",
      "$$#        M  ##",
      "OOOOOOOOOOOOOOOO"
    }
  },
  {
    "Tae-Ho Kim",
    {
      "OOOOOOO  OO  OOO",
      "O$O$#$#       M$",
      "O#OOOOO       #$",
      "O     M    MM OO",
      "O O O           ",
      "OPM M M  M  O M ",
      "O#O#O#O#O     OO",
      "O$O$O$O$O     #$",
      "O$O$O$OOO  O OO$"
    }
  },
  {
    "Tae-Ho Kim",
    {
      "POO   O$OOOOOOOO",
      "  M M O#O$$#$$$O",
      " M      OOOO##OO",
      "  M     O     OO",
      " M      O MO  OO",
      "        #     OO",
      " O   O#OOOOO   O",
      " M M O$$O$##   O",
      "     OOOOOOOOOOO"
    }
  },
  {
    "Tae-Ho Kim",
    {
      "$OOOOOOOOOOOOOOO",
      "$O$#$$$#$$$O$O$O",
      "$OOO##$OOO$O$O$O",
      "$$#O##OOOOOO#O#O",
      "OO#          M O",
      " M     M  O  M O",
      "PM     O  M  M O",
      " M     O  M  M O",
      "OO             O"
    }
  },
  {
    "Tae-Ho Kim",
    {
      "      OOOOOOOOOO",
      " MMM   ##$$#$#$O",
      " MPM M OOOOOOOOO",
      " MMM   O$##  #$O",
      " M M M OOOO  O$O",
      "       #$#   OOO",
      "OOOO M #$#  MO$O",
      "O$$#   OOO   #$O",
      "OOOOOOOOOOOOOOOO"
    }
  },
  {
    "Tae-Ho Kim",
    {
      "      OOOOOOOOOO",
      " MMM OO#$O$#P#$O",
      "      #$OOO MO$O",
      " MOO  #$#$O  O$O",
      " M M  OOOOO##OOO",
      " M M  # M    O$O",
      "      #   M  O$O",
      " OMMOOOOO#O##O$O",
      "      O$$$O$$$$O"
    }
  },
  {
    "Tae-Ho Kim",
    {
      "OOOOOOOO$$$OP O ",
      "O$$#$$$OOOOOMMM ",
      "OOOO$$$##$$O    ",
      "O$$#$$$OOOOO M  ",
      "OOOO###O     OM ",
      "       O        ",
      " M       M      ",
      " O       M     O",
      " O     O#OOOO   "
    }
  },
  {
    "Tae-Ho Kim",
    {
      "O$$$OOOOOOOOOOOO",
      "OO#O#        #$$",
      "O$$$#  OOOOOOOOO",
      "O#$M#  ##$#$$#$$",
      "O$$$#  OOOOOOOOO",
      "O#O#O   M M M M ",
      "O$O$O         M ",
      "O$O$O  MMMMMMMO ",
      "OOOOO          P"
    }
  },
  {
    "Tae-Ho Kim",
    {
      "OOO   O  OOOO$$O",
      "$$O      #$OOO#O",
      "$##      OOO$$$O",
      "OOO    M #MP#$$O",
      "$OO      OOMO##O",
      "$#   MM  M  O$$O",
      "OO   M  M   OO#O",
      "$#   OM M MOO$$O",
      "$O O       OOOOO"
    }
  },
  {
    "Tae-Ho Kim",
    {
      "OOOOOOOOOOOOOOOO",
      "O$$O$$$#$O$$#$$O",
      "O$$#$$$O$O$$O#$O",
      "O#OOO##OOOOOO#OO",
      "O#O$O     O   OO",
      "O$O$O MMM       ",
      "OOO$O           ",
      "O$#$# MOMMMMMMM ",
      "OOOOOO         P"
    }
  },
  {
    "Tae-Ho Kim",
    {
      "OOOOOOOOOOOOOOOO",
      "O$$##$#$$$OO$$$O",
      "O$$OO$O$$$##$$$O",
      "OOOOOOO##OOOOO#O",
      "             O#O",
      "             O$O",
      " MM          O$O",
      "   MMMM  MMM OOO",
      "               P"
    }
  }  
};


int main(void) {
  printf("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	 "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n"
	 "<plist version=\"1.0\">\n"
	 "<dict>\n"
	 "\t<key>version</key>\n"
	 "\t<integer>0</integer>\n"
	 "\t<key>levels</key>\n"
	 "\t<array>\n"
	);

  int i;
  for(i = 0; i < 27; i++) {
    printf("\t\t<dict>\n"
	   "\t\t\t<key>id</key>\n"
	   "\t\t\t<string>slippy%d</string>\n"
	   "\t\t\t<key>author</key>\n"
	   "\t\t\t<string>%s</string>\n"
	   "\t\t\t<key>name</key>\n"
	   "\t\t\t<string>Level %d</string>\n"
	   "\t\t\t<key>width</key>\n"
	   "\t\t\t<integer>16</integer>\n"
	   "\t\t\t<key>height</key>\n"
	   "\t\t\t<integer>9</integer>\n"
	   "\t\t\t<key>data</key>\n"
	   "\t\t\t<string>",
	   i + 1,
	   slippy_levels[i].author,
	   i + 1
	  );

    int j;
    for(j = 0; j < 9; j++) {
      printf("%s", slippy_levels[i].data[j]);
    }

    printf("</string>\n");

    if(i > 8)
      printf("\t\t\t<key>locked</key>\n"
	     "\t\t\t<true/>\n"
	     );

    /*
    if(i < sizeof(slippy_levels) / sizeof(slippy_levels[0]) - 3) {
      printf("\t\t\t<key>unlocks</key>\n"
	     "\t\t\t<array>\n");

      int n;
      for(n = 0; n < 3; n++)
	printf("\t\t\t\t<string>slippy%d</string>\n", (i - (i % 3)) + 3 + n + 1);
      printf("\t\t\t</array>\n");
      
      printf("\t\t\t<key>required</key>\n"
	     "\t\t\t<array>\n");
      for(n = 0; n < 3; n++)
	if (i != (i - (i % 3)) + n)
	  printf("\t\t\t\t<string>slippy%d</string>\n", (i - (i % 3)) + n + 1);
      printf("\t\t\t</array>\n");
    }

    */

    printf("\t\t</dict>\n");

  }
  printf("\t</array>\n"
	 "</dict>\n"
	 "</plist>\n");

  return 0;
}
