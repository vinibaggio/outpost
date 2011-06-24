module Outpost
  # Contain the status report of an Outpost execution. Holds the name,
  # description and status of the reported item.
  class Report
    # Summarizes the list of statuses in a single status only.
    # The logic is rather simple - it will return the lowest status
    # present in the list.
    #
    # Examples:
    #
    # if passed [:up, :up, :up], will result on :up
    #
    # if passed [:up, :down, :up], will result on :down
    #
    # @params [Array] status_list a list of statuses to be analyzed
    # @return [Symbol] the final status to be considered.
    def self.summarize(status_list)
      return :down if status_list.empty? || status_list.include?(:down)
      return :warning if status_list.include?(:warning)
      return :up
    end

    attr_reader :name, :description, :status, :data

    def initialize(params)
      @name        = params[:name]
      @description = params[:description]
      @status      = params[:status]
      @data        = params[:data]
    end

    def to_s
      "#{name}: '#{description}' is reporting #{status}."
    end
  end
end
