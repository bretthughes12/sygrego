namespace :syg do
    desc 'Create / update helper vouchers'
    task make_helper_vouchers: ['environment'] do |_t|
      inserts = 0
      updates = 0
      puts 'Updating group helper vouchers...'

      groups = Group.not_admin.coming.load

      groups.each do |group|
        name = "#{group.abbr}FREEHELPER"
        voucher = Voucher.find_by_name(name)

        if voucher
          if voucher.limit != group.free_helpers
            voucher.limit = group.free_helpers
            voucher.save
            updates += 1
          end
        else
            Voucher.create(
                name: name,
                group_id: group.id,
                limit: group.free_helpers,
                restricted_to: "Helpers",
                voucher_type: "Set",
                adjustment: 0.0
            )
            inserts += 1
        end
      end
      puts "Vouchers created: #{inserts}"
      puts "Vouchers updated: #{updates}"
    end

    desc 'Update MySYG names'
    task update_mysyg_names: ['environment'] do |_t|
      updates = 0
      puts "Correcting MySYG names..."

      groups = Group.all.load

      groups.each do |group|
        if group.mysyg_setting.mysyg_name != group.short_name.downcase.gsub(/[\[\] ,\.\/\']/,'')
          puts "Correcting #{group.short_name} - (#{group.mysyg_setting.mysyg_name} becomes #{group.short_name.downcase.gsub(/[\[\] ,\.\/\']/,'')})..."
          ms = group.mysyg_setting
          ms.update_name!(group.short_name)
          updates += 1
        end
      end

      puts "MySYG names corrected: #{updates}"
    end
end