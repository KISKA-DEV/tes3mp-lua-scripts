-- Dreamsleeve

-- by KISKA_DEV from Morrowind Classic RP server (russian language)

-- https://discord.gg/Ad5XR4JNZb

-- 2026 CC BY-NC-SA 4.0

-- Kinda... that strange kirkbride thing idk. in-game magical forum lol

-- You can easily change configs and translate this script on any language


-- Don't forget this thing in customScripts:
-- dreamsleeve = require("custom.dreamsleeve")

local logicHandler = require('logicHandler')
local customEventHooks = require('customEventHooks')
local jsonInterface = require('jsonInterface')

dreamsleeve = {}

-- Configuration
dreamsleeve.MAX_MESSAGES_SHOWN = 20 -- Number of messages displayed in the list
dreamsleeve.USE_LINE_WRAP = false -- Line wrapping, not recommended tbh, but you can fix it
dreamsleeve.MESSAGE_LINE_LENGTH = 60 -- Length of line for wrapping long messages if USE_LINE_WRAP is true

-- Character requirement configuration
dreamsleeve.USE_CHARACTER_REQUIREMENT = false -- Character requirement check
dreamsleeve.CHARACTER_REQUIREMENT_SKILL = "Mysticism" -- Skill to check (use skill ID)
dreamsleeve.CHARACTER_REQUIREMENT_VALUE = 70 -- Minimum value required for the skill
dreamsleeve.CHARACTER_REQUIREMENT_MESSAGE = "You are not skilled enouhg to transmit into Dreamsleeve." -- Message shown when requirement not met

-- Localization text strings
dreamsleeve.TEXT = {
    -- Main menu text
    MAIN_MENU_TITLE = "Welcome to Dreamsleeve.",
    MAIN_MENU_DESCRIPTION = "Here you can share thoughts with other participants.",
    DIVE_INTO_DREAMSLEEVE = "Dive into Dreamsleeve",
    SEND_MEMOSPORE = "Transmit memospore",
    CLOSE = "Close",

    -- Messages list text
    DREAMSLEEVE_LIST_TITLE = "Dreamsleeve - Memospores",
    NO_MESSAGES = "There are no memospores in Dreamsleeve yet.",

    -- Send message text
    ENTER_TITLE_PROMPT = "Enter your memospore title:",
    ENTER_CONTENT_PROMPT = "Enter your memospore content:",

    -- Confirm send text
    CONFIRM_SEND_TITLE = "Are you sure you want to send this memospore?",
    CONFIRM_SEND_PREVIEW = "Content: ",
    SEND = "Send",
    CANCEL = "Cancel",

    -- View message text
    MESSAGE_CONTENT_TITLE = "Message content",
    BACK_TO_LIST = "Back to list",

    -- Back to list text
    BACK_TO_LIST_MENU = "Back to list",

    -- Error messages and notifications
    SUCCESS_SEND = "Memospore successfully sent to Dreamsleeve.",

    -- Message formatting text
    SEPARATOR_LINE = string.rep("=", 30),
    SEPARATOR_LINE_DASH = string.rep("-", 25),
    EMPTY_LINE = "",
    SPACE_PREFIX = " "
}

-- File paths
dreamsleeve.LOG_FILE_PATH = "dreamsleeve_log.json"

-- GUI element IDs
dreamsleeve.GUI_ID = {
    MAIN_MENU = 10001,
    DIVE_INTO_DREAMSLEEVE = 10002,
    SEND_MEMOSPORE = 10003,
    DREAMSLEEVE_LIST = 10004,
    SEND_MESSAGE_DIALOG = 10005,
    ENTER_TITLE = 10006,
    ENTER_CONTENT = 10007,
    CONFIRM_SEND = 10008,
    SHOW_MESSAGE = 10009 -- Added new ID for message viewing
}

-- Загрузка лога снов
function dreamsleeve.loadDreamLog()
    -- Use jsonInterface to load data
    local success, data = pcall(jsonInterface.load, dreamsleeve.LOG_FILE_PATH)
    if success and data then
        return data
    else
        tes3mp.LogMessage(2, "Error loading dreamsleeve log or file doesn't exist, returning empty table: " .. tostring(data))
        -- Return an empty array as default
        return {}
    end
end

-- Сохранение лога снов
function dreamsleeve.saveDreamLog(logData)
    -- ИСПРАВЛЕНО 1: Правильный порядок аргументов - сначала путь, потом данные
    local success = pcall(jsonInterface.save, dreamsleeve.LOG_FILE_PATH, logData)
    if not success then
        tes3mp.LogMessage(2, "Error saving dreamsleeve log file: " .. dreamsleeve.LOG_FILE_PATH)
    end
end

-- Форматирование сообщения
function dreamsleeve.formatMessage(author, title, content)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local message = {}

    -- First line - separator of 10 "=" symbols
    table.insert(message, dreamsleeve.TEXT.SEPARATOR_LINE)

    -- Second line - date and time in format [DD.MM] HH:MM - PlayerName
    local date_part = string.sub(timestamp, 9, 10) .. "." .. string.sub(timestamp, 6, 7)  -- DD.MM (correct)
    local time_part = string.sub(timestamp, 12, 16)  -- HH:MM
    table.insert(message, "[" .. date_part .. "] " .. time_part .. " - " .. author)

    -- Third line - separator of 10 "-" symbols
    table.insert(message, dreamsleeve.TEXT.SEPARATOR_LINE_DASH)

    -- Fourth line - message title
    table.insert(message, title)

    -- Fifth line - additional separator of 10 "=" symbols after the title
    table.insert(message, dreamsleeve.TEXT.SEPARATOR_LINE)

    -- Sixth line - empty
    table.insert(message, dreamsleeve.TEXT.EMPTY_LINE)

    -- Seventh and subsequent lines - message content
    -- Split long message into lines of specified length if option is enabled
    local wrappedContent
    if dreamsleeve.USE_LINE_WRAP then
        wrappedContent = dreamsleeve.wrapText(content, dreamsleeve.MESSAGE_LINE_LENGTH)
    else
        -- If wrapping is disabled, just add text as is
        wrappedContent = {content}
    end

    for i = 1, #wrappedContent do
        table.insert(message, dreamsleeve.TEXT.SPACE_PREFIX .. wrappedContent[i])
    end

    -- Last line - empty
    table.insert(message, dreamsleeve.TEXT.EMPTY_LINE)

    return table.concat(message, "\n")
end

-- Split text into lines of specified length
function dreamsleeve.wrapText(text, maxLength)
    if not dreamsleeve.USE_LINE_WRAP then
        -- If wrapping is disabled, return text as a single line
        return {text}
    end

    local lines = {}
    local currentLine = ""

    -- Split text into words
    for word in text:gmatch("%S+") do
        -- If adding the current word exceeds the maximum length
        if #currentLine + #word + 1 <= maxLength then
            if currentLine == "" then
                currentLine = word
            else
                currentLine = currentLine .. " " .. word
            end
        else
            -- If the word is too long, split it forcibly
            if #word > maxLength then
                -- Add current line
                if currentLine ~= "" then
                    table.insert(lines, currentLine)
                end

                -- Split long word into parts
                local remainingWord = word
                while #remainingWord > maxLength do
                    local part = string.sub(remainingWord, 1, maxLength)
                    table.insert(lines, part)
                    remainingWord = string.sub(remainingWord, maxLength + 1)
                end

                if #remainingWord > 0 then
                    currentLine = remainingWord
                else
                    currentLine = ""
                end
            else
                -- Add current line and start a new one
                table.insert(lines, currentLine)
                currentLine = word
            end
        end
    end

    -- Add the last line if it's not empty
    if currentLine ~= "" then
        table.insert(lines, currentLine)
    end

    return lines
end

-- Send new message
function dreamsleeve.sendMessage(pid, title, content)
    local playerName = logicHandler.GetChatOnlyName(pid)
    local formattedMessage = dreamsleeve.formatMessage(playerName, title, content)

    -- Load existing log
    local logData = dreamsleeve.loadDreamLog()

    -- Add new message to the beginning (newest first)
    table.insert(logData, 1, {
        author = playerName,
        title = title,
        content = content,
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        formatted = formattedMessage
    })

    -- Save updated log
    dreamsleeve.saveDreamLog(logData)

    -- Notify player of successful send
    tes3mp.SendMessage(pid, dreamsleeve.TEXT.SUCCESS_SEND .. "\n")
end

-- Display main Dreamsleeve menu
function dreamsleeve.showMainMenu(pid)
    local menuText = dreamsleeve.TEXT.MAIN_MENU_TITLE .. "\n\n" ..
                     dreamsleeve.TEXT.MAIN_MENU_DESCRIPTION

    tes3mp.CustomMessageBox(pid, dreamsleeve.GUI_ID.MAIN_MENU, menuText,
                           dreamsleeve.TEXT.DIVE_INTO_DREAMSLEEVE .. ";" ..
                           dreamsleeve.TEXT.SEND_MEMOSPORE .. ";" ..
                           dreamsleeve.TEXT.CLOSE)
end

-- Display messages list
function dreamsleeve.showDreamList(pid)
    local logData = dreamsleeve.loadDreamLog()

    -- Take only the last 20 messages for display
    local displayCount = math.min(#logData, dreamsleeve.MAX_MESSAGES_SHOWN)
    local listText = "" -- Removed message count indicator

    for i = 1, displayCount do
        local entry = logData[i]
        -- Extract date and time from timestamp (format "YYYY-MM-DD HH:MM:SS")
        local date_part = string.sub(entry.timestamp, 6, 7) .. "." .. string.sub(entry.timestamp, 9, 10)  -- MM.DD
        local time_part = string.sub(entry.timestamp, 12, 16)  -- HH:MM
        -- Form 2 lines for each message
        listText = listText .. "[" .. date_part .. "] " .. time_part .. " - " .. entry.author .. "\n"
        listText = listText .. " – " .. entry.title .. "\n"
    end

    if displayCount == 0 then
        listText = listText .. dreamsleeve.TEXT.NO_MESSAGES .. "\n"
    end

    tes3mp.ListBox(pid, dreamsleeve.GUI_ID.DREAMSLEEVE_LIST, dreamsleeve.TEXT.DREAMSLEEVE_LIST_TITLE, listText)
end

-- Process GUI events
function dreamsleeve.OnGUIAction(pid, idGui, data)
    if idGui == dreamsleeve.GUI_ID.MAIN_MENU then
        if data == "0" then  -- Dive into Dreamsleeve
            dreamsleeve.showDreamList(pid)
        elseif data == "1" then  -- Send memospore
            -- Request title from player
            tes3mp.InputDialog(pid, dreamsleeve.GUI_ID.ENTER_TITLE,
                              dreamsleeve.TEXT.ENTER_TITLE_PROMPT, "")
        elseif data == "2" then  -- Close
            -- Do nothing, just close the menu
        end
    elseif idGui == dreamsleeve.GUI_ID.DREAMSLEEVE_LIST then
        -- Process message selection from list (each message takes 2 lines)
        local lineIndex = tonumber(data)
        if lineIndex ~= nil and lineIndex >= 0 then
            local logData = dreamsleeve.loadDreamLog()
            local displayCount = math.min(#logData, dreamsleeve.MAX_MESSAGES_SHOWN)

            -- Each message takes 2 lines, so divide index by 2 to get message number
            local messageIndex = math.floor(lineIndex / 2) + 1
            if messageIndex >= 1 and messageIndex <= displayCount then
                local selectedEntry = logData[messageIndex]

                -- Show selected message content
                local messageContent = selectedEntry.formatted or (selectedEntry.title .. "\n\n" .. selectedEntry.content)
                -- Truncate content if too long for display
                local displayContent = string.sub(messageContent, 1, 1000) .. (string.len(messageContent) > 1000 and "..." or "")
                tes3mp.CustomMessageBox(pid, dreamsleeve.GUI_ID.SHOW_MESSAGE,
                                      displayContent, dreamsleeve.TEXT.BACK_TO_LIST)
            else
                -- If index is out of range, return to main menu
                dreamsleeve.showMainMenu(pid)
            end
        else
            -- If user pressed ESC or another button, return to main menu
            dreamsleeve.showMainMenu(pid)
        end
    elseif idGui == dreamsleeve.GUI_ID.SHOW_MESSAGE then
        -- Return to list after viewing message
        dreamsleeve.showDreamList(pid)
    elseif idGui == dreamsleeve.GUI_ID.DREAMSLEEVE_LIST + 1 then
        -- Process "Back to list" button
        dreamsleeve.showDreamList(pid)
    elseif idGui == dreamsleeve.GUI_ID.ENTER_TITLE then
        -- Process entered title
        if data ~= "" then
            if not Players[pid].dreamsleeveTemp then
                Players[pid].dreamsleeveTemp = {}
            end

            Players[pid].dreamsleeveTemp.title = data

            -- Request message content
            tes3mp.InputDialog(pid, dreamsleeve.GUI_ID.ENTER_CONTENT,
                              dreamsleeve.TEXT.ENTER_CONTENT_PROMPT, "")
        else
            -- If title is empty, return to main menu
            dreamsleeve.showMainMenu(pid)
        end
    elseif idGui == dreamsleeve.GUI_ID.ENTER_CONTENT then
        -- Process entered content
        if data ~= "" then
            if not Players[pid].dreamsleeveTemp then
                Players[pid].dreamsleeveTemp = {}
            end

            Players[pid].dreamsleeveTemp.content = data

            -- Show send confirmation
            local confirmText = dreamsleeve.TEXT.CONFIRM_SEND_TITLE .. "\n\n" ..
                               "Title: " .. (Players[pid].dreamsleeveTemp.title or "Untitled") .. "\n" ..
                               dreamsleeve.TEXT.CONFIRM_SEND_PREVIEW .. string.sub(data, 1, 50) .. (string.len(data) > 50 and "..." or "")

            tes3mp.CustomMessageBox(pid, dreamsleeve.GUI_ID.CONFIRM_SEND,
                                   confirmText, dreamsleeve.TEXT.SEND .. ";" .. dreamsleeve.TEXT.CANCEL)
        else
            -- If content is empty, return to main menu
            dreamsleeve.showMainMenu(pid)
        end
    elseif idGui == dreamsleeve.GUI_ID.CONFIRM_SEND then
        if data == "0" then  -- Send
            if Players[pid].dreamsleeveTemp and Players[pid].dreamsleeveTemp.title and Players[pid].dreamsleeveTemp.content then
                dreamsleeve.sendMessage(pid, Players[pid].dreamsleeveTemp.title, Players[pid].dreamsleeveTemp.content)

                -- Clear temporary data
                Players[pid].dreamsleeveTemp = nil

                -- Return to main menu
                dreamsleeve.showMainMenu(pid)
            end
        elseif data == "1" then  -- Cancel
            -- Clear temporary data
            Players[pid].dreamsleeveTemp = nil

            -- Return to main menu
            dreamsleeve.showMainMenu(pid)
        end
    end
end

-- Command to open Dreamsleeve
function dreamsleeve.openDreamsleeve(pid)
    if dreamsleeve.checkCharacterRequirement(pid) then
        dreamsleeve.showMainMenu(pid)
    end
end


-- Initialize the log file if it doesn't exist
function dreamsleeve.Initialize()
    local logData = dreamsleeve.loadDreamLog()
    if logData == nil or next(logData) == nil then
        -- Create initial empty log
        dreamsleeve.saveDreamLog({})
    end
end

-- Initialize on script load
dreamsleeve.Initialize()

-- Register event handlers
customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
    dreamsleeve.OnGUIAction(pid, idGui, data)
end)

-- Function to check character requirements
function dreamsleeve.checkCharacterRequirement(pid)
    if not dreamsleeve.USE_CHARACTER_REQUIREMENT then
        return true -- Requirement check is disabled, allow access
    end

    -- Get player's skill value
    local skillId = tes3mp.GetSkillId(dreamsleeve.CHARACTER_REQUIREMENT_SKILL)
    if skillId == -1 then
        -- Invalid skill name, allow access
        return true
    end

    local playerSkillValue = tes3mp.GetSkillBase(pid, skillId)
    if playerSkillValue >= dreamsleeve.CHARACTER_REQUIREMENT_VALUE then
        return true -- Requirement met
    else
        -- Requirement not met, show message and deny access
        tes3mp.MessageBox(pid, -1, dreamsleeve.CHARACTER_REQUIREMENT_MESSAGE)
        return false
    end
end


-- Register command
local customCommandHooks = require('customCommandHooks')
customCommandHooks.registerCommand("dreamsleeve", dreamsleeve.openDreamsleeve)
customCommandHooks.registerCommand("ds", dreamsleeve.openDreamsleeve)

return dreamsleeve
