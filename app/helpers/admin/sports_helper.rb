module Admin::SportsHelper
    def score_range(sport)
        if sport.allow_negative_score
            [*-99..-1, 'Forfeit', *0..99]
        else
            ['Forfeit', *0..99]
        end
    end
end
