class RoundRobinEntry
    attr_accessor :games,
                  :wins,
                  :draws,
                  :for,
                  :against,
                  :group,
                  :points,
                  :percent

    def initialize(attributes = {})
        attributes.each do |name, value|
            send("#{name}=", value)
        end
    end

    def <=>(other)
        if group != other.group
            group <=> other.group
        elsif group == other.group && points != other.points
            points <=> other.points
        else
            percent <=> other.percent
        end
    end
end