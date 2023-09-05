# !/bin/bash
# manage sub repositories with givent key and packages
DIR="${BASH_SOURCE%/*}"
COMPOSER="$(which composer)"
GREP="$(which grep)"

# include parts for environment initialization
function execute() {
    SUBDIR=$1
    PUBLIC_KEY=$2
    PRIVATE_KEY=$3
    shift 3
    PACKAGES=$@

    # crate sub dir if not exist
    if [ ! -d "$DIR/$SUBDIR" ]; then
        mkdir -p $DIR/$SUBDIR
    fi

    # verify composer is installed, prioritize local composer.phar
    if [ -f "./composer.phar" ]; then
        COMPOSER="php ./composer.phar"
        # copy composer.phar to sub dir so it can be used in sudirectories
        cp ./composer.phar $DIR/$SUBDIR/
    else
        if [ -z "$COMPOSER" ]; then 
            echo "composer not found, please install composer or place composer.phar in Magento webroot directory";
            exit;
        fi
    fi  

    # make sure PACKAGES is not empty
    if [ -z "$PACKAGES" ]; then
        echo "no packages given, please provide packages to install";
        exit;
    fi

    cd $DIR/$SUBDIR

    # init composer.json
    if [ -f "./composer.json" ]; then
        echo "$DIR/$SUBDIR/composer.json exists"
    else
        echo "generating composer.json"
        $COMPOSER init --no-interaction --name="$SUBDIR/repo" --description="$SUBDIR repository with different key" --stability="dev" --repository="https://repo.magento.com/"
    fi

    # init auth.json for repo.magento.com
    if [ -f "./auth.json" ]; then
        echo "$DIR/$SUBDIR/auth.json exists"
    else
        echo $PWD
        echo "generating auth.json"
        $COMPOSER config --no-interaction http-basic.repo.magento.com d8cf8882e7e04b12631a2c16f43c02b0 3adc070b740237aefc90c61ff7c407e0
    fi

    # loop through $PACKAGES and install packages that were not installed
    for PACKAGE in $PACKAGES
    do
        if $GREP -q $PACKAGE "./composer.json"; then
            echo "$PACKAGE exists"
        else
            $COMPOSER require $PACKAGE --no-interaction --no-update
        fi
    done

    # check last composer update time and update if older than 30 days
    TO_UPDATE=0
    if [ -d "./vendor" ]; then
        LAST_UPDATE=$(stat -c %Y "./composer.lock")
        CURRENT_TIME=$(date +%s)
        DIFFERENCE=$((CURRENT_TIME-LAST_UPDATE))
        if [ $DIFFERENCE -gt 2592001 ]; then
            TO_UPDATE=1
        fi
    else
        TO_UPDATE=1
    fi

    if [ $TO_UPDATE -eq 1 ]; then
        echo "modules not installed or oudated, running composer update..."
        $COMPOSER update --no-interaction
    fi

    cd ../..

    # install packages to webroot directory
    $COMPOSER require $PACKAGES --no-interaction --no-update
}

execute $@
