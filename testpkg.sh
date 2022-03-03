

function APTINSTALL() {
  GREEN='\033[0;32m';
  YELLOW='\033[0;33m';
  RED='\033[0;31m';
  NC='\033[0m';
  if [ ! -z "$1" ]; then PKG=$@; elif [ -n "$1" ]; then line=$1; else read -p "Enter PKG to install" line; fi;
  read -p "Press [Enter]" fackEnterKey;

  apt-get update --yes;
  for letter in $PKG; do
    PKG=$(dpkg-query -W -f='${Status}' $letter 2>/dev/null | grep -c 'ok installed');
    if [ "$PKG" -eq 0 ]; then
      echo -e "${YELLOW}Installing\t- ${letter} ${NC}" && sleep 1 && apt-get install ${letter} --yes;
       PKG=$(dpkg-query -W -f='${Status}' $letter 2>/dev/null | grep -c 'ok installed');
       if [ "$PKG" -eq 0 ]; then echo -e "${RED}${letter}\t - INSTALLED FAILED${NC}" && sleep 1; 
         elif [ "$PKG" -eq 1 ]; then echo -en "${GREEN}${letter}\t - IS installed${NC}\n" && sleep 2; 
       fi;
    elif [ "$PKG" -eq 1 ]; then echo -en "${GREEN}${letter}\t - INSTALLED${NC}\n" && sleep 2;
    fi;
  done;
};

ListPKG='nano curl wget';

APTINSTALL ${ListPKG}
