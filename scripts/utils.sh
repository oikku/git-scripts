#!/usr/bin/bash

read_git_configuration () {
    PROJECT_ID=$(git config git-scripts.jira.project.id);
    URL=$(git config git-scripts.jira.url | sed 's|/$||');
    USER=$(git config git-scripts.jira.username);
}

load_configuration () {
    read_git_configuration
    if [[ -z "$PROJECT_ID" || -z "$URL" ]]; then
        echo "JIRA project ID or URL is not configured."
        echo
        echo "    git config git-scripts.jira.project.id PROJECT_ID"
        echo "    git config git-scripts.jira.url URL"
        echo
        exit 1
    fi
   
    SHELL_PATTERN="$PROJECT_ID-[0-9]+" 
    GREP_PATTERN="$PROJECT_ID-[0-9]\+"
    SED_SPLIT="s/\($PROJECT_ID-[0-9]\+\)/\1\n/g" 
    SED_CLEAN="s/.*\($PROJECT_ID-[0-9]\+\).*/\1/g"
}

current_branch_name () {
    git rev-parse --abbrev-ref HEAD
}

check_username () {
    if [[ -z "$USER" ]]; then
        echo "JIRA username is not configured."
        echo
        echo "    git config git-scripts.jira.username USERNAME"
        echo
        exit 1
    fi
}

parse_issues () {
    grep "$GREP_PATTERN" | sed -e "$SED_SPLIT" | sed -e "$SED_CLEAN" | grep "$GREP_PATTERN" | sort -n -t '-' -k2,2 | uniq
}

read_password () {
    PASSWORD=$(git config git-scripts.jira.password);
    if [[ -z "$PASSWORD" ]]; then
        echo -n "Give JIRA password: ";
        stty_orig=$(stty -g);
        stty -echo;
        read PASSWORD;
        stty $stty_orig;
        echo;
    fi
}

jira_status() {
    if [[ -n "$PASSWORD" ]]; then
        stat=$( curl -k -s -u "$USER:$PASSWORD" -X GET -H 'Content-Type: application/json' "$URL/rest/api/2/issue/${1}?fields=status"; );
        jq_cmd=$(tmp="$(which jq 2>/dev/null)" && echo "$tmp");
        if [[ -x "$jq_cmd" ]]; then
            stat=$( echo $stat | $jq_cmd '.fields.status.name' );
        else
            stat=$( echo $stat | sed 's/","/"\n"/g' | grep "\"name\":" | sed 's/^.*"name":"\([^"]*\)".*/\1/' | awk '{print}' ORS=' || ' );
        fi
        echo "$stat";
    else
        echo "NO CREDENTIALS GIVEN"
    fi
}

jira_summary() {
    if [[ -n "$PASSWORD" ]]; then
        stat=$( curl -k -s -u "$USER:$PASSWORD" -X GET -H 'Content-Type: application/json' "$URL/rest/api/2/issue/${1}?fields=summary"; );
        stat=$( echo $stat | sed 's/.*{"summary":"\(.*\)"}}.*/\1/' );
        stat=$( echo $stat | sed 's/\\"/"/g' );
        echo "$stat";
    else
        echo "NO CREDENTIALS GIVEN"
    fi
}
