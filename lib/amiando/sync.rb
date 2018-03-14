module Amiando

  ##
  # The main attributes are events and next_id.
  #
  # Read through [Amiando::Sync::Event] to know how to understand the
  # information returned.
  class Sync < Resource
    attr_accessor :events, :next_id

    def initialize(events, next_id)
      @events, @next_id = events, next_id
    end

    # Register an on server sync
    #
    #
    def self.register
      object = Result.new do |response_body, result|
        if response_body["success"]
          Sync.new(events, response_body['nextId'])
        else
          result.errors = response_body['errors']
          false
        end
      end

      get object, "v2/sync/register"

      object
    end

    ##
    # Get the latest 'synchronization' events. Let's not forget that in this
    # case an 'event' is something that happened. It could be, for instance,
    # that a new ticket was bought, that an event was modified, or similar.
    #
    # Read the http://developers.amiando.com/index.php/REST_API_DataSync docs
    # to find out how it really works. Simplifying, you find by the latest id
    # you have, and go through the events returned.
    #
    # When you find a data synchronization you get everything that happened
    # (events) and the next id you should query for. Next time you should use
    # that id when calling this method.
    #
    # @param last_id
    #
    # @return [Amiando::Sync] with all the [Amiando::Sync::Event]
    #
    def self.find(last_id)
      object = Result.new do |response_body, result|
        if response_body["success"]
          events = response_body['events'].map do |event|
            Sync::Event.new(event)
          end
          Sync.new(events, response_body['nextId'])
        else
          result.errors = response_body['errors']
          false
        end
      end

      get object, "v2/sync/#{last_id}"

      object
    end

    ##
    # A synchronization event aka 'Something that happened'.
    #
    # You should use mainly 4 attributes:
    #
    # * obj_type and returned_obj_type will allow you to know what kind
    #   of object you should be dealing with. Read through the official docs
    #   to know the difference between them.
    # * obj_id is the id of whichever object you're dealing with.
    # * operation is what happened to that object. Typically 'create', 'delete'
    #   and 'update'. But beware the 'resync' one.
    #
    # Please note that the original api returns object_id, object_type and
    # returned_object_type, but ruby 1.9 throws warnings if defining a method
    # called object_id. All three have been ranemd for consistency.
    class Event
      include Attributes

      def initialize(hash)
        set_attributes(hash)
      end

      def obj_id
        attributes[:object_id]
      end

      def obj_type
        attributes[:object_type]
      end

      def returned_obj_type
        attributes[:returned_object_type]
      end
    end
  end
end
