#!/usr/bin/env bash
set -e

CYAN='\x1b[1;36m'
GREEN='\x1b[32m'
NC='\x1b[0m' # No Color

# Snippet source: http://stackoverflow.com/a/246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

if [[ $1 == init ]]; then
    if [ $# -lt 2 ]; then
        echo -e "${CYAN}Initializing project${NC}"
        git clone --depth=1 --branch=master git@github.com:giantjs/giant-project-boilerplate.git .
        rm -rf .git
        giant init shared
        giant init application
    else
        echo -e "${CYAN}Initializing module $2${NC}"
        mkdir modules/$2
        git clone --depth=1 --branch=master git@github.com:giantjs/giant-module-boilerplate.git modules/$2
        rm -rf modules/$2/.git
    fi
elif [[ $1 == batch ]]; then
    if [ $# -lt 2 ]; then
        echo "Usage:"
        echo "  giant batch <command>"
    else
        echo -e "${CYAN}Running batch command${NC} \"$2\""
        cd modules
        for f in * ; do
            if [[ -d $f ]]; then
                echo -e "${GREEN}>> $f${NC}"
                (cd $f && eval $2)
            fi
        done
        cd ..
    fi
elif [[ $1 == clear ]]; then
    echo -e "${CYAN}Clearing module packages${NC}"
    $0 batch "rm -f *.tgz"
elif [[ $1 == build ]]; then
    if [[ $# > 1 && $(cat ./module-sequence.dat | grep -- "$2") ]]; then
        echo -e "${CYAN}Building module $2${NC} ${@:3}"
        ## passing extra arguments to build script
        "$DIR/build-distribute.sh" ${@:2}
    else
        echo -e "${CYAN}Building modules${NC} ${@:2}"
        (cat ./module-sequence.dat | xargs -n 1 -I {} giant build {} ${@:2})
    fi
elif [[ $1 == run ]]; then
    if [ $# -lt 3 ]; then
        echo "Usage:"
        echo "  giant run <module-name> <command>"
    else
        (cd modules/$2 && eval ${@:3})
    fi
else
    echo "Usage:"
    echo "  giant (init|run|batch|clear|build) [module-name] [command]"
fi
