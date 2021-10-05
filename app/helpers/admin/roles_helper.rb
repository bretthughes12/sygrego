module Admin::RolesHelper
    def role_badge_class(role)
        return "badge bg-primary" if role.name == "admin"
        return "badge bg-success" if role.name == "gc"
        return "badge bg-info" if role.name == "church_rep"
        "badge bg-secondary"
    end
end
