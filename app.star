"""
Current Dance Wave - A Tidbyt app showing the currently playing song from Dance Wave Online Radio
"""

load("render.star", "render")
load("http.star", "http")
load("cache.star", "cache")
load("schema.star", "schema")
load("encoding/json.star", "json")

# Dance Wave API endpoint
DANCEWAVE_API_URL = "https://dancewave.online/api/playlist.cgi?user=dw8080&streamid=1&mount=/dw.ogg&num=25&excludestring=Dance%20Wave&out=json&_=1757708308450"
DANCEWAVE_LOGO_URL = "https://dancewave.online/wp-content/uploads/2021/06/dwplay_mp3.png"

CACHE_TTL_SECONDS = 300  # Cache for 5 minutes (more frequent updates for live radio)

# Feature flag - set to True to enable real API calls, False for mock data
USE_REAL_API = False

def main(config):
    """
    Main function that renders the Tidbyt display
    """
    show_time = config.bool("show_time", False)
    
    # Get user-configured colors
    header_color = config.get("header_color", "#0785ff")
    artist_color = config.get("artist_color", "#46e3fb")
    title_color = config.get("title_color", "#07fcaa")

    # Fetch current playing track
    current_track = fetch_current_track()

    if current_track == None:
        # Fallback display if API fails
        return render.Root(
            child = render.Box(
                render.Column(
                    expanded = True,
                    main_align = "space_evenly",
                    cross_align = "center",
                    children = [
                        render.Text(
                            content = "Dance Wave",
                            font = "tb-8",
                            color = header_color,
                        ),
                        render.Text(
                            content = "Radio",
                            font = "tb-8",
                            color = artist_color,
                        ),
                        render.Text(
                            content = "Loading...",
                            font = "tom-thumb",
                            color = title_color,
                        ),
                    ],
                ),
            ),
        )

    # Display current track info
    artist = current_track.get("artist", "Unknown Artist")
    title = current_track.get("title", "Unknown Track")
    time = current_track.get("time", "")

    # Build the display children
    children = [
        render.Text(
            content = "NOW PLAYING ♫",
            font = "tb-8",
            color = header_color,
        ),
        render.Marquee(
            width = 64,
            child = render.Text(
                content = artist,
                font = "tb-8",
                color = artist_color,
            ),
            scroll_direction = "horizontal",
        ),
        render.Marquee(
            width = 64,
            child = render.Text(
                content = title,
                font = "tb-8",
                color = title_color,
            ),
            scroll_direction = "horizontal",
        ),
    ]

    # Add time if enabled and available
    if show_time and time:
        children.append(
            render.Text(
                content = time,
                font = "tom-thumb",
                color = title_color,
            )
        )

    return render.Root(
        child = render.Box(
            render.Column(
                expanded = True,
                main_align = "space_evenly",
                cross_align = "center",
                children = children,
            ),
        ),
    )

def get_schema():
    """
    Configuration schema for the app
    """
    return schema.Schema(
        version = "1",
        fields = [
            schema.Toggle(
                id = "show_time",
                name = "Show Time",
                desc = "Show the time when the track started playing",
                icon = "clock",
                default = False,
            ),
            schema.Color(
                id = "header_color",
                name = "Header Color",
                desc = "Color for 'NOW PLAYING' text",
                icon = "palette",
                default = "#0785ff",
            ),
            schema.Color(
                id = "artist_color",
                name = "Artist Color", 
                desc = "Color for artist name text",
                icon = "palette",
                default = "#46e3fb",
            ),
            schema.Color(
                id = "title_color",
                name = "Title Color",
                desc = "Color for song title text", 
                icon = "palette",
                default = "#07fcaa",
            ),
        ],
    )

def fetch_current_track():
    # Switch between real API and mock data
    # Testing if serving works better than check command for network requests
    USE_REAL_API = True

    if USE_REAL_API:
        url = "https://dancewave.online/api/playlist.cgi?user=dw8080&streamid=1&mount=/dw.ogg&num=1&out=json"
        headers = {
            "Referer": "https://dancewave.online/tracklist/",
        }

        # Cache the API response for 30 seconds
        cached = cache.get("current_track")
        if cached != None:
            return json.decode(cached)

        resp = http.get(url, headers=headers)

        if resp.status_code == 200:
            data = resp.json()
            # Extract the current track (first item in playlist)
            if data.get("mscp", {}).get("playlist") and len(data["mscp"]["playlist"]) > 0:
                current = data["mscp"]["playlist"][0]
                track_data = {
                    "artist": current.get("artist", "Unknown Artist"),
                    "title": current.get("title", "Unknown Title"),
                    "time": current.get("time", "Unknown Time")
                }
                cache.set("current_track", json.encode(track_data), ttl_seconds=30)
                return track_data
            else:
                print("No playlist data found")
                return None
        else:
            print("Failed to fetch from API:", resp.status_code)
            return None

    # Use mock data if real API is disabled or failed
    return {
        "artist": "Dance Wave Radio",
        "title": "Now Playing Great Music",
        "time": "00:00"
    }
