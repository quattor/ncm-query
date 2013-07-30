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

_ncm_query()
{
    local opts="--component --help"
    local comps=`find /usr/lib/perl/NCM/Component -name '*.pm' -exec basename '{}' .pm ';'`
    local paths="/hardware /hardware/cards /hardware/cards/nic /hardware/memory /system /system/network /system/aii/osinstall/ks /system/aii/nbp/pxelinux /system/filesystems /system/blockdevices /software/packages /software/components"
    COMPREPLY=()
    local cur="${COMP_WORDS[COMP_CWORD]}"
    case $cur in
        -*)
            COMPREPLY=($(compgen -W "$opts" -- ${cur}))
            return 0
            ;;
        /*)
            COMPREPLY=($(compgen -W "$paths" -- ${cur}))
            return 0
            ;;
        *)
            COMPREPLY=($(compgen -W "$comps" -- ${cur}))
            return 0
            ;;
    esac
}

complete -F _ncm_query ncm-query
