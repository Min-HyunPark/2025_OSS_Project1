# 2025_OSS_Project1

12234124 박현민

I. 실행 방법

   chmod +x 2025_OSS_Project1.sh 입력,
   ./2025_OSS_Project1.sh 2024_MLB_Player_Stats.csv 입력으로 parameter 1개를 받는 process 실행.

II. 기능 구현

0. 실행 전 작업

  file="$1"

   if [ $# -ne 1 ] || [ ! -f "$file" ]; then
    echo "Usage: ./2025_OSS_Project1.sh file"
    exit 1
   fi

   실행 시킬 때 parameter 개수가 1개가 아니거나 parameter가 될 파일이 존재하지 않는 파일이면 에러메시지 출력 후 종료.
   file은 첫 번째 parameter를 가리킨다.

  whoami()는 실행 후 한 번만 출력되는 인적사항을, menu()는 실행 후 exit 전까지 계속 출력되는 option 정보를 출력하는 함수이다.
    while문 밖에 whoami를, 내부 초반에 menu를 배치해 기본 출력기능 구현.
    
    read -p "Enter your COMMAND (1~7) : " cmd
    매번 menu가 출력된 후 cmd 변수로 입력값을 받아 case문을 통해 option들을 실행한다.

1. Search player statistics by name
   
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

     입력값으로 pname을 받아 awk문으로 2nd field 즉, name과 일치하는 항목이 있으면 검색 성공, 그 row의 team, age, war, hr, ba 정보 출력.
     해당하는 선수 정보가 없을 경우 Player not found 메시지 출력 후 option으로 복귀

2. List the top 5 players ranked by SLG (Slugging Percentage)

   2)
            read -p "Do you want to see the top 5 players by SLG? (y/n) : " ans
            if [ "$ans" == "y" ]; then
                echo -e "\n***Top 5 Players by SLG***"
                awk -F, 'NR > 1 && $8 >= 502 { print $2","$4","$22","$14","$15 }' "$file" \
                    | sort -t, -k3 -nr | head -5 \
		    | awk -F, '{ printf("%d. %s (Team: %s) - SLG: %s, HR: %s, RBI: %s\n", NR, $1, $2, $3, $4, $5) }'
            fi
            ;;

     ans를 입력받아 y면 slg 값 상위 5명의 정보를 출력, y가 아니면 option으로 복귀.
     타석 수가 502 이상인 선수만 포함, SLG 순으로 sort 후 상위 5 row만으로 압축,
     row번호, name, team, slg, hr, rbi값 출력.

3. Analyze the team statistics including average age and total home runs

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

     team을 입력받아 해당 team의 평균 연령, 홈런 수, rbi를 총합 계산해서 출력.
     team이 존재하지 않는 경우 Team not found 메시지 출력 후 option으로 복귀.

4. Compare players in different age groups

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

     group을 입력받아 1~3 group에 맞게 해당 group의 선수들, 타석 수가 502 이상인 선수들들을 slg 순 상위 5명의 선수들의 name, team, age, slg, ba, hr 값 출력.
     age = $3+0 으로 age 값을 수치 비교할 수 있도록 변경.

5. Find players meeting custom conditions for home runs and batting average

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

        min_hr, min_ba를 입력 받아 최소 홈런 수, 최소 ba 기준 설정.
     타석 수가 502 이상인 선수들 중 위 조건을 넘는 선수들을 압축 후 홈런 수를 기준으로 sort,
     name, team, hr, ba, rbi, slg 값을 출력.

6. Generate performance reports for specific teams
     
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

       team을 입력 받아 해당 팀의 선수들의 정보들을 hr 개수를 기준으로 sort 한 후 name, hr, rbi, ba, obp, ops 값을 출력.
     마지막에 team의 total player 수를 출력.

7. Quit
   
    7)
            echo "Have a good day!"
            exit 0
            ;;
        *)
            echo "Invalid command. Please enter a number between 1 and 7."
            ;;

      7입력 시 Have a good day! 출력 후 프로그램 종료,
      그 외의 입력값 발생 시 에러 메시지 출력 후 option 으로 복귀.
