--[[
DoesGuildHistoryCategoryHaveMoreEvents(number guildId, number GuildHistoryCategory category)
boolean hasMoreEvents

DoesGuildRankHavePermission(number guildId, number rankIndex, number GuildPermission permission)
Returns: boolean hasPermission

GetGuildEventId(number guildId, number GuildHistoryCategory category, number eventIndex)
Returns: id64 guildEventId

GetGuildEventInfo(number guildId, number GuildHistoryCategory category, number eventIndex)
Returns: number eventType, number secsSinceEvent, *variant* param1, *variant* param2, *variant* param3, *variant* param4, *variant* param5, *variant* param6, number eventId

GetGuildId(number guildIndex)
Returns: number guildId

GetGuildKioskCycleTimes()
Returns: number despawnTimestampS, number bidEndTimestampS, number respawnTimestampS

GetNumGuildHistoryCategories()
Returns: number numCategories

GetNumGuildEvents(number guildId, number GuildHistoryCategory category)
Returns: number numEvents

GetGuildName(number guildId)
Returns: string name

GetGuildNameAttribute(number guildId)
Returns: string guildName

---

RequestGuildHistoryCategoryNewest(number guildId, number GuildHistoryCategory category)
Returns: boolean requested

RequestGuildHistoryCategoryOlder(number guildId, number GuildHistoryCategory category)
Returns: boolean requested

EVENT_GUILD_HISTORY_CATEGORY_UPDATED (number eventCode, number guildId, GuildHistoryCategory category)
EVENT_GUILD_HISTORY_REFRESHED (number eventCode)
EVENT_GUILD_HISTORY_RESPONSE_RECEIVED (number eventCode, number guildId, GuildHistoryCategory category)

]]--