# Subterfuge

A library for event driven websocket browsing.

## Idea

The idea for this project is to create a standard set of libraries to implement websocket based event driven browsing. 

Specific uses:

* Chat
* Notifications
* File uploads
* Streaming page loads

## TODO

* Create base communication layer between browser and server using em-websocket gem and javascript library.
* Define helper methods for creating common javascript code that is loaded through the socket connection.
  * Listeners
  * Commands
  * etc.
* Create common usage examples using the subterfuge code.

## Required libraries


### Gems
* em-websocket
* json

### Javacript
* http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js


## Old Example usage for server:

    require 'rubygems'
    require 'em-websocket'

    #this example must be used with the web_socket_command.js file.

    EventMachine.run {
      @channel = EM::Channel.new

      EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => true) do |ws|

        ws.onopen {
          sid = @channel.subscribe { |msg| ws.send msg }
          @channel.push "#{sid} connected!"

          ws.onmessage { |msg|
        
            @channel.push ws.js_command('alert', 'test')
            #calls alert('test');
        
            @channel.push ws.js_command('prompt', 'prompt test', 9)
            #calls prompt('prompt test', 9);
        
            #javascript is a special command where the rest of the arguments are just evaluated.
            @channel.push ws.js_command('javascript', "alert('javascript alert')", "testval = 9+1", "alert(testval)")
            #runs the script below on the browser
            #     alert('javascript alert');
            #     testval = 9+1;
            #     alert(testval);
          }

          ws.onclose {
            @channel.unsubscribe(sid)
          }

        }
      end

      puts "Server started"
    }

## Included javascript code

    <html>
      <head>
        <script src='http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js'></script>
        <script>
          
          var allowed_commands = ['alert', 'javascript', 'prompt'];

          $(document).ready(function(){
            function debug(str){ $("#debug").append("<p>"+str+"</p>"); };

            ws = new WebSocket("ws://localhost:8080");
            ws.onmessage = function(evt) { 
              socket_command(evt.data);
              $("#msg").append("<p>"+evt.data+"</p>"); 
            };
            ws.onclose = function() { debug("socket closed"); };
            ws.onopen = function() {
              debug("connected...");
              ws.send("hello server");
            };
          });

          function socket_command(msg){
            try{
              jsonmsg = JSON.parse(msg);
              vars = jsonmsg.vars;
              command = jsonmsg.method_name;
            }catch(err){
              command = "";
              vars = [];
            }
            if(allowed_commands.contains(command)){
              //javascript is a special command where the rest of the arguments are just evaluated.
              if(command=='javascript'){
                for(x in vars){
                  eval(vars[x].value);
                }
              }else{
                vars_array = [];
                for(x in vars){
                  //right now we only have String and not NotString
                  switch(vars[x].type){
                    case 'String':
                      vars_array.push("'"+vars[x].value+"'");
                      break;
                    default:
                      vars_array.push(""+vars[x].value+"");
                  }
                }
                eval(command+"("+vars_array.join(",")+")");
              }
            }else{
              $("#debug").append("<p>"+msg+"</p>");
            }
          }
          Array.prototype.contains = function(obj) {
            var i = this.length;
            while (i--) {
              if (this[i] === obj) {
                return true;
              }
            }
            return false;
          }
        </script>
      </head>
      <body>
        <div id="debug"></div>
        <div id="msg"></div>
      </body>
    </html>


# License

(The MIT License)

Copyright (c) 2010 Kelly Mahan

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
