namespace :syg do
    desc 'Create / update helper vouchers'
    task make_helper_vouchers: ['environment'] do |_t|
      groups = Group.not_admin.coming.load

      groups.each do |group|
        name = "#{group.abbr}FREEHELPER"
        voucher = Voucher.find_by_name(name)

        if voucher
            voucher.limit = group.free_helpers
            voucher.save
        else
            Voucher.create(
                name: name,
                group_id: group.id,
                limit: group.free_helpers,
                restricted_to: "Helpers",
                voucher_type: "Set",
                adjustment: 0.0
            )
        end
      end
    end
end