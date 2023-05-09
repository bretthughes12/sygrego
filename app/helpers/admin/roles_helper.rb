module Admin::RolesHelper
    def role_badge_class(role)
        return "" if role.nil?
        return "badge bg-primary" if role.name == "admin"
        return "badge bg-success" if role.name == "gc"
        return "badge bg-info" if role.name == "church_rep"
        return "badge bg-danger" if role.name == "sc"
        "badge bg-secondary"
    end
end
