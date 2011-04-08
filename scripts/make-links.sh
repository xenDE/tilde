#!/bin/bash
#
# NAME
#        make-links.sh - Create symlinks
#
# SYNOPSIS
#        make-links.sh [OPTION]... TARGETS DIRECTORY
#
# DESCRIPTION
#        Creates one symlink for each of the TARGETS in DIRECTORY. If the
#        link already exists, it is replaced. If it is a proper file or
#        directory, the user is given options to continue.
#
#        -d, --diff
#               executable to use instead of diff to compare existing files to
#               targets
#
#        -e, --exclude
#               exclude regular expressions; see $default_excludes
#
#        -f, --force
#               create symlinks without asking for confirmation
#
#        -s, --skip-existing
#               skips existing files without prompting; overrides --force
#
#        -h, --help
#               display this information and quit
#
#        -v, --verbose
#               verbose output
#
# EXAMPLES
#        make-links.sh ~/settings/* ~
#               Create links in the home directory to the regular files in
#               ~/settings.
#
#        make-links.sh -v -d meld ~/dev/tilde/.* ~/settings/.* ~
#               Create links in the home directory to all dot-files in
#               ~/dev/tilde and ~/settings. If any of the files already exist,
#               the diffs can be reviewed in meld.
#
# BUGS
#        https://github.com/l0b0/tilde/issues
#
# COPYRIGHT
#        Copyright © 2008-2011 Victor Engmark. License GPLv3+: GNU GPL
#        version 3 or later <http://gnu.org/licenses/gpl.html>.
#        This is free software: you are free to change and redistribute it.
#        There is NO WARRANTY, to the extent permitted by law.
#
################################################################################

set -o errexit
set -o nounset
set -o noclobber

# Defaults
default_diff='diff -s'
default_excludes=( '\.' '\.\.' '\.git' '\.svn' )

directory="$(dirname -- "$(readlink -fn -- "$0")")"

. "$directory/functions.sh"

# Process parameters
params="$(getopt -o d:e:fshv -l diff:,exclude:,force,skip-existing,help,verbose \
    --name "$cmdname" -- "$@")"

if [ $? -ne 0 ]
then
    usage
fi

eval set -- "$params"

while true
do
    case $1 in
        -d|--diff)
            diff_exec="$2"
            shift 2
            ;;
        -e|--exclude)
            # Will override $default_excludes
            excludes[${#excludes[*]}]="$2"
            shift 2
            ;;
        -f|--force)
            force='--force'
            shift
            ;;
        -s|--skip-existing)
            skip='--skip-existing'
            shift
            ;;
        -h|--help)
            usage
            exit
            ;;
        -v|--verbose)
            verbose='--verbose'
            shift
            ;;
        --)
            shift
            if [ -z "${1:-}" ]
            then
                error "Missing targets." "$help_info" $EX_USAGE
            fi
            if [ -z "${2:-}" ]
            then
                error "Missing directory." "$help_info" $EX_USAGE
            fi
            targets=(${@:1:$(($#-1))})
            source_dir="${@:$#}"
            break
            ;;
        *)
            usage
            ;;
    esac
done

if [ ! -d "$source_dir" ]
then
    error "Not a directory: $source_dir" "$help_info" $EX_USAGE
fi

# Set defaults
diff_exec="${diff_exec:-$default_diff}"
if [ -z "${excludes:-}" ]
then
    excludes=( "${default_excludes[@]}" )
fi

for target_path in "${targets[@]}"
do
    if [ ! -e "$target_path" ]
    then
        error "Target does not exist: $target_path" $EX_USAGE
    fi
    
    target_file="$(basename -- "$target_path")"

    # Check excludes on file name and path
    for exclude in "${excludes[@]}"
    do
        if [[ "$target_file" =~ ^${exclude}$ || "$target_path" =~ ^${exclude}$ ]]
        then
            continue 2 # Next target path
        fi
    done
    
    source_path="${source_dir}/${target_file}"

    unset do_replace
    do_replace="${force:+r}" # Always replace

    if [ -L "$source_path" ]
    then
        do_replace=r # Replace existing symlinks
    fi

    if [ -n "${skip:-}" ]
    then
        do_replace=s # Always skip
    fi

    # File exists
    if [ -f "$source_path" -o -d "$source_path" ]
    then
        # Make sure we skip or replace in the end
        while [[ ! "$do_replace" =~ ^[SsRr]$ ]]
        do
            echo "${source_path} exists and is a $(stat -c %F -- "${source_path}"). What do you want to do?"
            read -n 1 -p '[S]kip, [D]iff, [R]eplace: ' do_replace
            echo

            if [[ "$do_replace" =~ ^[Dd]$ ]]
            then
                $diff_exec -- "$target_path" "$source_path"
            fi
        done

        if [[ "$do_replace" =~ ^[Ss]$ ]]
        then
            continue
        fi
    fi

    if [ "$do_replace" == 'r' ]
    then
        rm ${verbose:-} -- "$source_path" || error "rm failed" $?
    fi

    if [ -e "$source_path" ]
    then
        warning "${source_path} exists but is not a standard file; skipping."
        continue
    fi

    ln ${verbose:-} -s "$target_path" "$source_path" || error "ln failed" $?
done
