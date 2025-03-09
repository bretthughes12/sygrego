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
        elsif sport.ladder_tie_break == 'Points For'
            'For'
        end
    end

    def ladder_explanation(sport)
        case
        when sport.ladder_tie_break == "Percentage"
            "Teams on equal points are separated by percentage."
        when sport.ladder_tie_break == "Point Difference"
            "Teams on equal points are separated by #{sport.point_name.downcase} difference."
        when sport.ladder_tie_break == "Points For"
            "Teams on equal points are separated by total #{sport.point_name.downcase.pluralize} scored."
        end
    end

    def sport_filtered(sport, group)
        if GroupsSportsFilter.exists?(sport_id: sport.id, group_id: group.id)
          'table-dark'
        else
          'table-primary'
        end
    end
end
