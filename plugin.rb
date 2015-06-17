# name: Watch Category
# about: Watches a category for all the users in a particular group
# version: 0.1
# authors: Arpit Jalan
# url: https://github.com/techAPJ/discourse-watch-category

module ::WatchCategory
  def self.watch_category!
    mcneel_private_category = Category.find_by_slug("mcneel-private")
    mcneel_group = Group.find_by_name("mcneel")

    mcneel_group.users.each do |user|
      CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:watching], mcneel_private_category.id)
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
