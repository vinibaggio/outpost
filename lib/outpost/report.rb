module Outpost
  class Report

    # Sumarizes the list of statuses in a single status only.
    # The logic is rather simple - it will return the lowest status
    # present in the list.
    #
    # Examples:
    #
    # if passed [:up, :up, :up], will result on :up
    # if passed [:up, :down, :up], will result on :down
    def self.sumarize(status_list)
      return :down if status_list.empty? || status_list.any? { |s| s == :down }
      return :up
    end
  end
end
