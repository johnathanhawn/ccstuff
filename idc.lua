local csFilePath = "cs.txt"
local textutilsAvailable = textutils and textutils.serialize ~= nil

-- Check if the cs.txt file exists
if not fs.exists(csFilePath) then
  -- File doesn't exist, create it
  local csFile = fs.open(csFilePath, "w")
  csFile.writeLine("wss://your-websocket-server-url") -- Replace with your desired default server URL
  csFile.close()
  print("cs.txt file created. Please update the WebSocket server URL in cs.txt.")
  return
end

-- Read the server URL from the cs.txt file
local csFile = fs.open(csFilePath, "r")
local serverURL = csFile.readAll()
csFile.close()

local function connectToWebSocket()
  local ws, err = http.websocket(serverURL)

  if ws then
    print("WebSocket server connected")

    -- Send a welcome message to the client
    ws.send("Hello, client!")

    while true do
      local message = ws.receive()

      if message then
        -- Print the received command
        print("Received command:", message)

        -- Process the received command
        local success, result = pcall(loadstring(message))

        -- Handle turtle.inspect() response
        if message == "turtle.inspect()" then
          local inspectResult = {}
          inspectResult.success = success
          if success then
            inspectResult.tag = result ~= nil and { name = result.name, state = result.state } or "nil"
          else
            inspectResult.tag = "Command execution error: " .. tostring(result)
          end
          
          -- Serialize the inspectResult to send as a string
          local serializedResult
          if textutilsAvailable then
            serializedResult = textutils.serialize(inspectResult)
          else
            serializedResult = tostring(inspectResult)
          end

          -- Return the serialized result as a string
          ws.send(serializedResult)
        else
          -- Create the response object
          local response = {
            success = success,
            result = result
          }
          
          -- Serialize the response to send as a string
          local serializedResult
          if textutilsAvailable then
            serializedResult = textutils.serialize(response)
          else
            serializedResult = tostring(response)
          end

          -- Return the serialized result as a string
          ws.send(serializedResult)
        end
      end
    end

    ws.close()
    print("WebSocket server disconnected")
  else
    print("Failed to connect to the WebSocket server: " .. err)
  end
end

while true do
  connectToWebSocket()
  print("Retrying in 3 seconds...")
  os.sleep(3) -- Retry after 3 seconds
end
