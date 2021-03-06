#!/bin/bash
echo "Checking if Docker is installed..." 1>&2
if [ "$(uname -m)" == "x86_64" ]; then
    which docker 1> /dev/null 2> /dev/null
    if [ $? -eq 0 ]; then
        if [ -S "/var/run/docker.sock" ]; then
            PYTHON=""
            if [ -x "$(command -v python2)" ]; then
                PYTHON="python2"
            elif [ -x "$(command -v python3)" ]; then
                PYTHON="python3"
            else
                echo "  Neither python2 nor python3 was found, needed to check for Docker version. Docker agent will not be installed." 1>&2
                exit 1
            fi
            # version check (order of below check is important)
            # supported versions -- major versions >= 17, except azure forks. We need to special case for major version 3, due to Moby azure fork (which did not have 'azure' in them)
            if [ "$($PYTHON -c "print(\"azure\" in \"$(docker version --format {{.Server.Version}})\")" 2>/dev/null)" == "True" ]; then
                echo "  Azure fork is found in Docker version. Docker agent will not be installed." 1>&2
                exit 1
            elif [ "$($PYTHON -c "print(int(\"$(docker version --format {{.Server.Version}})\".split('.')[0]) == 3)" 2>/dev/null)" == "True" ]; then
                echo "  Docker version 3.* found. Docker agent will not be installed." 1>&2
                exit 1
            elif [ "$($PYTHON -c "print(int(\"$(docker version --format {{.Server.Version}})\".split('.')[0]) >= 17)" 2>/dev/null)" == "True" ]; then
                echo "  Docker version greater or equal than 17.* found. Docker agent will be installed" 1>&2
            #keeping the below not-so-good check to not break backcompat
            elif [ "$($PYTHON -c "print(int(\"$(docker version --format {{.Server.Version}})\".split('.')[1]) >= 11)" 2>/dev/null)" == "True" ]; then
                echo "  Docker version greater or equal than 1.11 found. Docker agent will be installed" 1>&2
            else
                echo "  The installed version of Docker is not supported. Version 17 or greater is required, and Azure fork is not supported. Docker agent will not be installed." 1>&2
                exit 1
            fi
        else
            echo "  Docker is not listening on /var/run/docker.sock. Docker agent will not be installed" 1>&2
            exit 1
        fi
    else
        echo "  Docker not found. Docker agent will not be installed." 1>&2
        exit 1
    fi
else
    echo "  Only 64-bit systems are supported. Docker agent will not be installed." 1>&2
    exit 1
fi
