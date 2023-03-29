local fm = require "fullmoon"
local table = require "table"

local streamServices = {
  "Hulu",
  "Funimation",
  "Crunchyroll",
  "CONtv",
  "Netflix",
  "HIDIVE",
  "TubiTV",
  "Amazon",
  "YouTube",
  "AnimeLab",
  "VRV" 
}

-- Request builder
function createRequest(services, offset)
  local params = {
    "fields[anime]=slug",
    "page[limit]=1",
    "page[offset]=" .. offset,
    "sort=-user_count",
  }

  if services and #services > 0 then
    local escapedServices = {}

    for k,v in ipairs(services) do
      table.insert(escapedServices, fm.escapePath(v))
    end

    table.insert(
      params,
      "filter[streamers]=" .. table.concat(services, ",")
    )
  end

  local reqParams =
    { headers = { Accept = "application/vnd.api+json" } }

  local url = "https://kitsu.io/api/edge/anime?" .. table.concat(params, "&")

  return url, reqParams
end

-- Common Templates

fm.setTemplate(
  "html-head",
  [[
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>{%& title %}</title>
    <link rel="stylesheet" href="https://unpkg.com/spectre.css/dist/spectre.min.css">
  </head>
  ]]
)

-- Page templates

fm.setTemplate(
  "select-site",
  [[
    {% render("html-head", { title = "Random Anime" }) %}
    <body class="container grid-md mt-2">
      <div class="columns">
        <div class="col-12">
          <h1>Random Anime</h1>
          <h2>Pick your streaming sites</h2>
          <form action="random">
            <ul>
            {% for k,service in ipairs(streamServices) do %}
              <li>
                <label>
                  <input
                    type="checkbox"
                    name="streamers[]"
                    value="{%& service %}"
                  > {%& service %}
                </label>
              </li>
            {% end %}
            </ul>
            <input type="submit" class="btn btn-primary" value="SPIN">
          </form>
        </div>
      </div>
    </body>
  ]]
)

fm.setTemplate(
  "random",
  [[
  {% render("html-head", { title = "Anime Redirector" }) %}
  <body>
    <style>
      html, body, iframe {
        height: 100%;
        margin: 0;
      }
      body {
        display: flex;
        flex-direction: column;
      }
    </style>
    <script>
      function spin() {
        if (location.search) {
          location.search = location.search.replace(/$|&cb=.*/, '&cb=' + Date.now().toString());
        } else {
          location.search = 'cb=' + Date.now().toString();
        }
      }
    </script>
    <div class="p-centered my-2">
      <button class="btn btn-primary" onclick="spin()">SPIN AGAIN</button>
      <a class="btn" href="./">Change streams</a>
    </div>
    <iframe
      width="100%"
      scrolling="yes"
      frameborder="0" 
      name="{%& slug %}"
      src="https://kitsu.io/anime/{%& slug %}"></iframe>
  </body>
  ]]
)

fm.setRoute(
  "/",
  function(r)
    return fm.serveContent("select-site", { streamServices = streamServices })
  end
)

fm.setRoute(
  "/random",
  function(r)
    local listUrl, listParams = createRequest(r.params["streamers[]"], 0)
    local listStatus, listHeaders, listResp = Fetch(listUrl, listParams)

    if not listStatus then
      return fm.serveError(500)
    end

    local animeCount = DecodeJson(listResp).meta.count
    local offset = Rand64() % animeCount

    local randomUrl, randomParams = createRequest(r.params["streamers[]"], offset)
    local randomStatus, _, randomResp = Fetch(randomUrl, randomParams)

    if not randomStatus then
      return fm.serveError(500)
    end

    local slug = DecodeJson(randomResp).data[1].attributes.slug

    return fm.serveContent("random", { slug = slug })
  end
)

fm.run()
