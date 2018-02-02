
function up_status(type, count) {
    if(type == "ahead") {
        return " " cyan type " " count reset;
    } else if(type == "behind") {
        return " " yellow type " " count reset;
    }
    return "";
}

function upstream_status() {
    if($3 == "") { return "" }

    ahead = 0;
    behind = 0;

    if($4 == "ahead") { ahead = $5 }
    if($4 == "behind") { behind = $5 }
    if($6 == "behind") { behind = $7 }
    
#    return sprintf("%s%s%s %s", remote_color, $3, reseti, ab_status(ahead, behind));

    part1 = up_status($4, $5);
    part2 = up_status($6, $7);
    if(part1 == "") {
        return remote_color $3 reset;
    } else {
        return remote_color$3 part1 part2;
    }
}

function sprintnz(value, prefix) {
    if(value == 0) { return "" }
    return prefix value;
}

function ab_status(ahead, behind) {
    return sprintf("%s%5s%s %s%-5s%s", cyan, sprintnz(ahead, "+"), reset, yellow, sprintnz(behind, "-"), reset);
}

function master_status() {
    branch = $2;
    if(branch == "master") { return " " }
    cmd= "git rev-list --count ^master " branch;
    cmd | getline ahead;
    close(cmd);
    cmd= "git rev-list --count master ^" branch;
    cmd | getline behind;
    close(cmd);
    return ab_status(ahead, behind);
}

function randomize(name) {
    c = sprintf("cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w %d | head -n 1", length(name));
    c | getline rb;
    close(c);
    return rb;
}

BEGIN {
    stage=1;
    max_length = 0;
    if(output == "terminal") {
        green="\033[0;32m";
        red="\033[0;91m";
        cyan="\033[0;96m";
        yellow="\033[0;93m";
        remote_color="\033[0;34m";
        reset="\033[0m";
    } else {
        green="";
        red="";
        cyan="";
        yellow="";
        remote_color="";
        reset="";
    }
}  
{ 
    if($0 == "====") { 
        stage += 1; 
    } else if(stage == 1) { 
        mb[$1] = 1;
    } else if(stage == 2) {
        l = length($1);
        if(l > max_length) { max_length = l }
    } else { 
        if($1 == "*") { 
            head = "*";
            fs = green; 
            fe = reset; 
        } else { 
            head = " ";
            fs = ""; 
            fe = ""; 
        } 
        branch = $2; 

        merge_status = " ";
        if(branch != target && mb[branch] == 1) { 
            merge_status = "M";
            fs = red;
            fe = reset;
        }
        out = head " " merge_status " " branch;
        printf "%s%-*s%s %-11s %s%s\n", fs, max_length+5, out, fe, master_status(), upstream_status(), reset;
    }
}
