#!/bin/bash

file="$1"

if [ $# -ne 1 ] || [ ! -f "$file" ]; then
    echo "Usage: ./2025_OSS_Project1.sh file"
    exit 1
fi

whoami() {
    echo "************OSS1 - Project1************"
    echo "*        StudentID : 12234124         *"
    echo "*        Name : Hyunmin Park          *"
    echo "***************************************"
}

menu() {
    echo "[MENU]"
    echo "1. Search player stats by name in MLB data"
    echo "2. List top 5 players by SLG value"
    echo "3. Analyze the team stats - average age and total home runs"
    echo "4. Compare players in different age groups"
    echo "5. Search the players who meet specific statistical conditions"
    echo "6. Generate a performance report (formatted data)"
    echo "7. Quit"
}

whoami

while true; do
    menu
    read -p "Enter your COMMAND (1~7) : " cmd
    case $cmd in
	    1)
            read -p "Enter a player name to search: " pname
            awk -F, -v name="$pname" '
            BEGIN { found = 0 }
            NR > 1 && $2 == name {
	 	printf("\nPlayer stats for \"" name "\":\n")
                printf("Player: %s, Team: %s, Age: %s, WAR: %s, HR: %s, BA: %s\n\n",
                       $2, $4, $3, $6, $14, $20)
                found = 1
            }
            END {
                if (!found) {
			printf("Player not found.\n")
                }
            }
            ' "$file"
            ;;
	            2)
            read -p "Do you want to see the top 5 players by SLG? (y/n) : " ans
            if [ "$ans" == "y" ]; then
                echo -e "\n***Top 5 Players by SLG***"
                awk -F, 'NR > 1 && $8 >= 502 { print $2","$4","$22","$14","$15 }' "$file" \
                    | sort -t, -k3 -nr | head -5 \
		    | awk -F, '{ printf("%d. %s (Team: %s) - SLG: %s, HR: %s, RBI: %s\n", NR, $1, $2, $3, $4, $5) }'
            fi
            ;;

        3)
            read -p "Enter team abbreviation (e.g., NYY, LAD, BOS): " team
            awk -F, -v team="$team" '
            BEGIN { ageSum=0; hrSum=0; rbiSum=0; count=0 }
            NR > 1 && $4 == team {
                ageSum += $3; hrSum += $14; rbiSum += $15; count++
            }
            END {
                if (count == 0) {
			printf( "Team not found.\n")
                } else {
                    printf("\nTeam stats for %s:\n", team)
                    printf("Average age: %.1f\n", ageSum / count)
                    printf("Total home runs: %d\n", hrSum)
                    printf("Total RBI: %d\n\n", rbiSum)
                }
            }
            ' "$file"
            ;;
	            4)
            echo -e "\nCompare players by age groups:"
            echo "1. Group A (Age < 25)"
            echo "2. Group B (Age 25-30)"
            echo "3. Group C (Age > 30)"
            read -p "Select age group (1-3): " group

            echo -e "\nTop 5 by SLG in selected group:"
            awk -F, -v group="$group" '
            NR > 1 && $8 >= 502 {
                age = $3 + 0
                if ((group == 1 && age < 25) ||
                    (group == 2 && age >= 25 && age <= 30) ||
                    (group == 3 && age > 30)) {
                    print $2","$4","$3","$22","$20","$14
                }
            }
            ' "$file" | sort -t, -k4 -nr | head -5 \
		    | awk -F, '{ printf("%s (%s) - Age: %s, SLG: %s, BA: %s, HR: %s\n", $1, $2, $3, $4, $5, $6) }'
            ;;
	            5)
            read -p "Minimum home runs: " min_hr
            read -p "Minimum batting average (e.g., 0.280): " min_ba
            echo -e "\nPlayers with HR ≥ $min_hr and BA ≥ $min_ba:"
            awk -F, -v hr="$min_hr" -v ba="$min_ba" '
            NR > 1 && $8 >= 502 {
                hr_val = $14 + 0
                ba_val = $20 + 0
                if (hr_val >= hr && ba_val >= ba) {
                    print $2","$4","$14","$20","$15","$22
                }
            }
            ' "$file" | sort -t, -k3 -nr \
		    | awk -F, '{ printf("%s (%s) - HR: %s, BA: %s, RBI: %s, SLG: %s\n", $1, $2, $3, $4, $5, $6) }'
			;;
	            6)
            read -p "Enter team abbreviation (e.g., NYY, LAD, BOS): " team
            echo -e "\n================== $team PLAYER REPORT =================="
            echo "Date: $(date +%Y/%m/%d)"
            echo "-------------------------------------------------------"
            printf "%-25s %-5s %-5s %-6s %-6s %-6s\n" "PLAYER" "HR" "RBI" "AVG" "OBP" "OPS"
            echo "-------------------------------------------------------"
            awk -F, -v team="$team" '
            NR > 1 && $4 == team {
                print $2","$14","$15","$20","$21","$23
            }
            ' "$file" | sort -t, -k2 -nr \
            | awk -F, '
            {
                printf("%-25s %-5s %-5s %-6s %-6s %-6s\n", $1, $2, $3, $4, $5, $6)
                count++
            }
            END {
                print "--------------------------------------"
                printf("TEAM TOTALS: %d players\n", count)
            }
            '
            ;;


        7)
            echo "Have a good day!"
            exit 0
            ;;
        *)
            echo "Invalid command. Please enter a number between 1 and 7."
            ;;
    esac
done
      


