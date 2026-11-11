package com.iptv.tvbox.data.parser

import com.iptv.tvbox.data.model.Channel
import java.io.BufferedReader
import java.io.InputStream
import java.io.InputStreamReader
import java.util.UUID
import java.util.regex.Pattern

object M3UParser {

    private val TVG_ID_PATTERN = Pattern.compile("tvg-id=\"([^\"]*)\"", Pattern.CASE_INSENSITIVE)
    private val TVG_NAME_PATTERN = Pattern.compile("tvg-name=\"([^\"]*)\"", Pattern.CASE_INSENSITIVE)
    private val TVG_LOGO_PATTERN = Pattern.compile("tvg-logo=\"([^\"]*)\"", Pattern.CASE_INSENSITIVE)
    private val GROUP_TITLE_PATTERN = Pattern.compile("group-title=\"([^\"]*)\"", Pattern.CASE_INSENSITIVE)

    /**
     * Parses an M3U stream line-by-line into a list of Channel objects.
     */
    fun parse(inputStream: InputStream): List<Channel> {
        val channels = mutableListOf<Channel>()
        val reader = BufferedReader(InputStreamReader(inputStream, Charsets.UTF_8))

        var line: String?
        var currentTvgId: String? = null
        var currentTvgName: String? = null
        var currentLogo: String? = null
        var currentGroup: String? = null
        var currentChannelName: String? = null
        var channelIndex = 1

        while (reader.readLine().also { line = it } != null) {
            val trimmedLine = line?.trim() ?: continue
            if (trimmedLine.isEmpty()) continue

            if (trimmedLine.startsWith("#EXTINF:", ignoreCase = true)) {
                // Parse attributes
                currentTvgId = extractAttribute(trimmedLine, TVG_ID_PATTERN)
                currentTvgName = extractAttribute(trimmedLine, TVG_NAME_PATTERN)
                currentLogo = extractAttribute(trimmedLine, TVG_LOGO_PATTERN)
                currentGroup = extractAttribute(trimmedLine, GROUP_TITLE_PATTERN)

                // Channel name is after the last comma
                val commaIndex = trimmedLine.lastIndexOf(',')
                currentChannelName = if (commaIndex != -1 && commaIndex < trimmedLine.length - 1) {
                    trimmedLine.substring(commaIndex + 1).trim()
                } else {
                    currentTvgName ?: "Kanal $channelIndex"
                }

                if (currentChannelName.isEmpty()) {
                    currentChannelName = currentTvgName ?: "Kanal $channelIndex"
                }
            } else if (!trimmedLine.startsWith("#")) {
                // It's a stream URL
                if (isValidStreamUrl(trimmedLine)) {
                    val finalName = currentChannelName ?: currentTvgName ?: "Kanal $channelIndex"
                    val finalGroup = if (!currentGroup.isNullOrBlank()) currentGroup else "Genel"

                    val channel = Channel(
                        id = currentTvgId?.takeIf { it.isNotBlank() } ?: UUID.randomUUID().toString(),
                        name = finalName,
                        logoUrl = currentLogo?.takeIf { it.isNotBlank() },
                        streamUrl = trimmedLine,
                        category = finalGroup,
                        epgId = currentTvgId,
                        channelNum = channelIndex
                    )
                    channels.add(channel)
                    channelIndex++
                }

                // Reset temporary holders
                currentTvgId = null
                currentTvgName = null
                currentLogo = null
                currentGroup = null
                currentChannelName = null
            }
        }

        reader.close()
        return channels
    }

    private fun extractAttribute(line: String, pattern: Pattern): String? {
        val matcher = pattern.matcher(line)
        return if (matcher.find()) {
            matcher.group(1)?.trim()
        } else {
            null
        }
    }

    private fun isValidStreamUrl(url: String): Boolean {
        val lower = url.lowercase()
        return lower.startsWith("http://") ||
                lower.startsWith("https://") ||
                lower.startsWith("rtmp://") ||
                lower.startsWith("rtsp://") ||
                lower.startsWith("mms://")
    }
}
