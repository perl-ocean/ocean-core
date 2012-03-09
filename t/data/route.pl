router {

    register_broker("broker01" => "192.168.0.1:1111");
    register_broker("broker02" => "192.168.0.1:1112");
    register_broker("broker03" => "192.168.0.1:1113");

    event_route('message', {
        broker => "broker01", 
        queue  => "message_queue",
    });

    event_route(['presence', 'initial_presence', 'unavailable_presence'], {
        broker => "broker02", 
        queue  => "presence_queue",
    });

    default_route({
        broker => "broker03",
        queue  => "default_queue",
    });

};
