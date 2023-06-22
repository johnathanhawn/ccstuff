local ws, err = http.websocket("ws://your-websocket-server-url")

if ws then
  print("WebSocket server connected")

  -- Send a welcome message to the client
  ws.send("Turtle Here")

  while true do
    local message = ws.receive()

    if message then
      -- Process the received command
      local response = processCommand(message)

      -- Send the response back to the client
      ws.send(response)
    end
  end

  ws.close()
  print("WebSocket server disconnected")
else
  print("Failed to connect to the WebSocket server: " .. err)
end

function processCommand(command)
  -- Run the command on the turtle shell
  shell.run(command)

  -- Return an acknowledgment message
  return "Command executed: " .. command
end
