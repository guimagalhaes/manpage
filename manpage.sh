
# browser application command
BROWSER="links -dump"
PAGER="less"
# url to search for man pages (include debian especific commands)
MANURL=http://www.fifi.org/cgi-bin/man2html/usr/share/man/man
# this URL include red hat especific commands
#MANURL2=http://man.linuxquestions.org/index.php?&section=0&type=0&query=

DEFAULT_MIN=1
DEFAULT_MAX=10

# initial manual page number default
MINMANPAGE=$DEFAULT_MIN
# last manual page number default
MAXMANPAGE=$DEFAULT_MAX

function usage
{
	echo "Usage:"
	echo -e "\t$0 <command> [Options]"
    echo -e "\t-h, --help\t\tShow this usage."
    echo -e "\t--min <man page>\tEspecify a man page number to init search from. Default is $DEFAULT_MIN"
    echo -e "\t--max <man page>\tEspecify a man page number to end search. Default is $DEFAULT_MAX"
	return 0
}

# verify dependencies
BCOM=`echo $BROWSER | tr -s " " | cut -d " " -f1`
which $BCOM &> /dev/null
if [ ! $? -eq 0 ]; then
	echo "$BCOM is not installed!"
    exit 1
fi
BCOM=`echo $PAGER | tr -s " " | cut -d " " -f1`
which $BCOM &> /dev/null
if [ ! $? -eq 0 ]; then
	echo "$BCOM is not installed!"
    exit 1
fi

# check options
if [ $# -eq 0 ]; then
	usage
    exit 1
fi

while [[ "$1" ]]; do
    case "$1" in
	"-h"|"--help")
	    shift
	    usage
	    exit 0
	;;
    "--min")
    	shift
        MINMANPAGE=$1
        shift
    ;;
    "--max")
    	shift
        MAXMANPAGE=$1
        shift
    ;;
    *)
    	if [ "x$COM" != "x" ]; then
        	usage
            exit 1
        fi
    	COM=$1
        shift
    ;;
    esac
done

# test command
if [ "x$COM" = "x" ]; then
	usage
    exit 1
fi

# test min and max man page number
if [ "${MINMANPAGE//[^0-9]/}" != "$MINMANPAGE" -o \
	"${MAXMANPAGE//[^0-9]/}" != "$MAXMANPAGE" ]; then
    echo "min and max man page number must be a number!"
    exit 1
fi

if [ $MINMANPAGE -gt $MAXMANPAGE ]; then
	echo "Initial man page number is greater than max man page number!"
    exit 1
fi

# search command manual
RETVAL=0
while [ $RETVAL -eq 0 -a $MINMANPAGE -le $MAXMANPAGE ]; do
	$BROWSER $MANURL$MINMANPAGE/$COM.$MINMANPAGE.gz | grep "No manpage for $COM" &> /dev/null
    RETVAL=$?
    if [ $RETVAL -eq 0 ]; then
    	let i=$MINMANPAGE+1
    	MINMANPAGE=$i
    fi
done

# if search fails, exit
if [ $MINMANPAGE -gt $MAXMANPAGE ]; then
	echo "Manual for \"$COM\" not found!"
    exit 1
fi

# Show the man page
$BROWSER $MANURL$MINMANPAGE/$COM.$MINMANPAGE.gz | $PAGER

exit 0
