module Outpost
  class Report
    # summarizes the list of statuses in a single status only.
    # The logic is rather simple - it will return the lowest status
    # present in the list.
    #
    # Examples:
    #
    # if passed [:up, :up, :up], will result on :up
    # if passed [:up, :down, :up], will result on :down
    def self.summarize(status_list)
      return :down if status_list.empty? || status_list.any? { |s| s == :down }
      return :up
    end

    attr_reader :name, :description, :status

    def initialize(params)
      @name        = params[:name]
      @description = params[:description]
      @status      = params[:status]
    end

    def to_s
      "#{name}: '#{description}' is reporting #{status}."
    end
  end
end
