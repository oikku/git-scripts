#!/usr/bin/bash

load_configuration () {
    KEY=$(git config jira.key);
    URL=$(git config jira.url);
    USER=$(git config jira.username);
    
    if [[ -z "$KEY" || -z "$URL" ]]; then
        echo "JIRA key or URL is not configured."
        echo
        echo "    git config jira.key KEY"
        echo "    git config jira.url URL"
        echo
        exit 1
    fi
   
    SHELL_PATTERN="$KEY-[0-9]+" 
    GREP_PATTERN="$KEY-[0-9]\+"
    SED_SPLIT="s/\($KEY-[0-9]\+\)/\1\n/g" 
    SED_CLEAN="s/.*\($KEY-[0-9]\+\).*/\1/g"
}

current_branch_name () {
    git rev-parse --abbrev-ref HEAD
}

check_username () {
    if [[ -z "$USER" ]]; then
        echo "JIRA username is not configured."
        echo
        echo "    git config jira.username USERNAME"
        echo
        exit 1
    fi
}

parse_issues () {
    grep "$GREP_PATTERN" | sed -e "$SED_SPLIT" | sed -e "$SED_CLEAN" | grep "$GREP_PATTERN" | sort -n -t '-' -k2,2 | uniq
}

read_password () {
    PASSWORD=$(git config jira.password);
    if [[ -z "$PASSWORD" ]]; then
        read -s -e -p "Give JIRA password: " PASSWORD
    fi
}

jira_status() {
    stat=$( curl -k -s -u "$USER:$PASSWORD" -X GET -H 'Content-Type: application/json' "$URL/rest/api/2/issue/${1}?fields=status"; );
	stat=$( echo $stat | sed 's/.*,"name":"\([^"]*\)".*/\1/' );
	echo "$stat";
}

jira_summary() {
	stat=$( curl -k -s -u "$USER:$PASSWORD" -X GET -H 'Content-Type: application/json' "$URL/rest/api/2/issue/${1}?fields=summary"; );
	stat=$( echo $stat | sed 's/.*{"summary":"\(.*\)"}}.*/\1/' );
	stat=$( echo $stat | sed 's/\\"/"/g' );
	echo "$stat";
}
