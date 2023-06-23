local csFilePath = "cs.txt"
local defaultURL = "wss://example.com" -- Replace with your desired default WebSocket server URL

local function createCsFile(url)
  local file = fs.open(csFilePath, "w")
  file.writeLine(url)
  file.close()
end

local function getServerURL()
  if fs.exists(csFilePath) then
    local file = fs.open(csFilePath, "r")
    local url = file.readLine()
    file.close()
    return url
  else
    createCsFile(defaultURL)
    return defaultURL
  end
end

local serverURL = getServerURL()

local function sendFilesViaWebSocket()
  local ws, err = http.websocket(serverURL)

  if ws then
    print("WebSocket server connected")

    local files = fs.list(shell.dir())
    local fileData = {}

    for _, filename in ipairs(files) do
      local filePath = fs.combine(shell.dir(), filename)
      if not fs.isDir(filePath) then
        local file = fs.open(filePath, "r")
        local content = file.readAll()
        file.close()

        local fileEntry = {
          filename = filename,
          content = content
        }

        table.insert(fileData, fileEntry)
      end
    end

    local serializedData = textutils.serialize(fileData)
    ws.send(serializedData)

    ws.close()
    print("WebSocket server disconnected")
  else
    print("Failed to connect to the WebSocket server: " .. err)
  end
end

sendFilesViaWebSocket()
