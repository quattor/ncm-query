#!/bin/bash
#
# ${license-info}
# ${developer-info}
# ${author-info}
# ${build-info}
#
# Bash autocompletion script for ncm-query.  Autocompletes component
# names, common options and common paths.  Based on the Debian
# tutorial "An introduction to bash completion":
#
# http://www.debian-administration.org/article/316/An_introduction_to_bash_completion_part_1
# http://www.debian-administration.org/article/317/An_introduction_to_bash_completion_part_2
#

# If the option under completion starts with a dash, autocompletes an
# option name (i.e, "--configure").  If it starts with a slash (/),
# autocompletes some usual profile paths.  Otherwise, autocompletes a
# component name.
_ncm_query()
{
    local wordlist path
    COMPREPLY=()
    local cur="${COMP_WORDS[COMP_CWORD]}"
    case $cur in
        -*)
            # some more common options
            wordlist="--component --help --depth --pan --paths"
            ;;
        *)
            case $cur in
            /*)
                path=${cur%/*}
                ;;
            *)
                path=/software/components
                ;;
            esac
            
            newwordlist=$path/
            # we need a loop. single word will stop the tab completion
            # (assuming the solution is found). we need to try to look for next level words
            while [ `echo $newwordlist |wc -w` == 1 ]; do
                wordlist=$newwordlist
                newwordlist=`ncm-query --depth=1 --paths $newwordlist 2>/dev/null |grep "$cur"`
                if [ -z "$newwordlist" ]; then
                    # eg can be empty when there are no properties, only tree
                    #echo "empty newwordlist $newwordlist wordlist $wordlist"
                    break
                fi
                if [ "$newwordlist" == "$wordlist" ]; then
                    # no progress
                    #echo "no progress newwordlist $newwordlist wordlist $wordlist"
                    break
                fi

                wordlist=$newwordlist
                #echo "newwordlist $newwordlist wordlist $wordlist"
            done
            ;;
    esac

    COMPREPLY=($(compgen -W "$wordlist" -- ${cur}))
    return 0
    
}

complete -F _ncm_query ncm-query
complete -F _ncm_query quattor-query
