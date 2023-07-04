module Admin::SportsHelper
    def score_range(sport)
        if sport.allow_negative_score
            [*-99..-1, 'Forfeit', *0..99]
        else
            ['Forfeit', *0..99]
        end
    end

    def tie_breaker(sport)
        if sport.ladder_tie_break == 'Percentage'
            '%'
        elsif sport.ladder_tie_break == 'Point Difference'
            'Diff'
        end
    end
end
