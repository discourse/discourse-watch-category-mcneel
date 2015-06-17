# name: Watch Category
# about: Watches a category for all the users in a particular group
# version: 0.1
# authors: Arpit Jalan
# url: https://github.com/techAPJ/discourse-watch-category

module ::WatchCategory
  def self.watch_category!
    mcneel_private_category = Category.find_by_slug("mcneel-private")
    mcneel_group = Group.find_by_name("mcneel")
    return if mcneel_private_category.nil? || mcneel_group.nil?

    mcneel_group.users.each do |user|
      watched_categories = CategoryUser.lookup(user, :watching).pluck(:category_id)
      CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:watching], mcneel_private_category.id) unless watched_categories.include?(mcneel_private_category.id)
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
