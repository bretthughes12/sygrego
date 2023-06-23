class RoundRobinLadder
    attr_accessor :finals_format, :groups, :section_id, :start_court, :second_court

    def initialize(section)
        @ladder = {}
        @finals_format = section.finals_format
        @groups = section.number_of_groups
        @start_court = section.start_court
        @second_court = section.start_court + (section.number_of_courts > 1 ? 1 : 0)
        @section_id = section.id
    end
  
    def add_sports_entries(sport_entries)
        sport_entries.each do |entry|
            @ladder[entry.id] = RoundRobinEntry.new(games: 0, wins: 0, draws: 0, for: 0, against: 0, group: entry.group_number)
        end
    end

    def add_result(result)
        if result.match > 99
            # do nothing - finals do not count in ladder calculation
        elsif result.forfeit_a && result.forfeit_b
            @ladder[result.entry_a_id].games += 1
            @ladder[result.entry_b_id].games += 1
        elsif result.forfeit_a
            @ladder[result.entry_a_id].games += 1
            @ladder[result.entry_a_id].against += result.forfeit_score
            @ladder[result.entry_b_id].games += 1
            @ladder[result.entry_b_id].wins += 1
            @ladder[result.entry_b_id].for += result.forfeit_score
        elsif result.forfeit_b
            @ladder[result.entry_a_id].games += 1
            @ladder[result.entry_a_id].wins += 1
            @ladder[result.entry_a_id].for += result.forfeit_score
            @ladder[result.entry_b_id].games += 1
            @ladder[result.entry_b_id].against += result.forfeit_score
        elsif result.score_a == result.score_b
            @ladder[result.entry_a_id].games += 1
            @ladder[result.entry_a_id].draws += 1
            @ladder[result.entry_a_id].for += result.score_a
            @ladder[result.entry_a_id].against += result.score_b
            @ladder[result.entry_b_id].games += 1
            @ladder[result.entry_b_id].draws += 1
            @ladder[result.entry_b_id].for += result.score_b
            @ladder[result.entry_b_id].against += result.score_a
        elsif result.score_a > result.score_b
            @ladder[result.entry_a_id].games += 1
            @ladder[result.entry_a_id].wins += 1
            @ladder[result.entry_a_id].for += result.score_a
            @ladder[result.entry_a_id].against += result.score_b
            @ladder[result.entry_b_id].games += 1
            @ladder[result.entry_b_id].for += result.score_b
            @ladder[result.entry_b_id].against += result.score_a
        else
            @ladder[result.entry_a_id].games += 1
            @ladder[result.entry_a_id].for += result.score_a
            @ladder[result.entry_a_id].against += result.score_b
            @ladder[result.entry_b_id].games += 1
            @ladder[result.entry_b_id].wins += 1
            @ladder[result.entry_b_id].for += result.score_b
            @ladder[result.entry_b_id].against += result.score_a
        end
    end

    def ladder
        # 3 points for a win; 2 points for a draw and 1 point for each loss
        @ladder.each do |key, entry|
            entry.points = entry.wins * 2 + entry.draws * 1 + entry.games
            if entry.against == 0
                entry.percent = 999.to_f
            else
                entry.percent = (entry.for.to_f / entry.against.to_f)
            end
        end

        @ladder.sort_by(&:last).reverse
    end

    def nth_in_group(group, n)
        k = 0
        ladder.each do |key, entry|
            k += 1 if entry.group == group
            return key if entry.group == group && k == n
        end
    end

    def next_best
        nb = {}
        nb[nth_in_group(1, 2)] = @ladder[nth_in_group(1, 2)]
        nb[nth_in_group(2, 2)] = @ladder[nth_in_group(2, 2)]
        nb[nth_in_group(3, 2)] = @ladder[nth_in_group(3, 2)]

        nb[nth_in_group(1, 2)].group = 0
        nb[nth_in_group(2, 2)].group = 0
        nb[nth_in_group(3, 2)].group = 0

        r = nb.sort_by(&:last).reverse
        r.first[0]
    end
end