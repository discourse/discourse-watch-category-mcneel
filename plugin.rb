# name: Watch Category
# about: Watches a category for all the users in a particular group
# version: 0.2
# authors: Arpit Jalan
# url: https://github.com/discourse/discourse-watch-category-mcneel

module ::WatchCategory
  def self.watch_category!
    mcneel_private_category = Category.find_by_slug("mcneel-private")
    mcneel_group = Group.find_by_name("mcneel")

    unless mcneel_private_category.nil? || mcneel_group.nil?
      mcneel_group.users.each do |user|
        watched_categories = CategoryUser.lookup(user, :watching).pluck(:category_id)
        CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:watching], mcneel_private_category.id) unless watched_categories.include?(mcneel_private_category.id)
      end
    end

    reseller_category = Category.find_by_slug("resellers")
    reseller_group = Group.find_by_name("resellers")
    return if reseller_category.nil? || reseller_group.nil?

    reseller_group.users.each do |user|
      watched_categories = CategoryUser.lookup(user, :watching).pluck(:category_id)
      CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:watching], reseller_category.id) unless watched_categories.include?(reseller_category.id)
    end
  end
end

after_initialize do
  module ::WatchCategory
    class WatchCategoryJob < ::Jobs::Scheduled
      every 1.day

      def execute(args)
        WatchCategory.watch_category!
      end
    end
  end
end
