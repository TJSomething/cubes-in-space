(local fm (require :fullmoon))

(local streamServices [
  "Hulu"
  "Funimation"
  "Crunchyroll"
  "CONtv"
  "Netflix"
  "HIDIVE"
  "TubiTV"
  "Amazon"
  "YouTube"
  "AnimeLab"
  "VRV"])

(fm.setTemplate
  "html-head"
  "<!DOCTYPE html>
<html lang='en'>
<head>
  <meta charset='UTF-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1.0'>
  <meta http-equiv='X-UA-Compatible' content='ie=edge'>
  <title>{%& title %}</title>
  <link rel='stylesheet' href='https://unpkg.com/spectre.css/dist/spectre.min.css'>
</head>")

(fm.setTemplate
  "select-site"
  "{% render('html-head', { title = 'Random Anime' }) %}
<body class='container grid-md mt-2'>
  <div class='columns'>
    <div class='col-12'>
      <h1>Random Anime</h1>
      <h2>Pick your streaming sites</h2>
      <form action='random'>
        <ul>
        {% for k,service in ipairs(streamServices) do %}
          <li>
            <label>
              <input
                type='checkbox'
                name='streamers[]'
                value='{%& service %}'
              > {%& service %}
            </label>
          </li>
        {% end %}
        </ul>
        <input type='submit' class='btn btn-primary' value='SPIN'>
      </form>
    </div>
  </div>
</body>")

(fm.setTemplate
  "random"
  "{% render('html-head', { title = 'Anime Redirector' }) %}
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
  <div class='p-centered my-2'>
    <button class='btn btn-primary' onclick='spin()'>SPIN AGAIN</button>
    <a class='btn' href='./'>Change streams</a>
  </div>
  <iframe
    width='100%'
    scrolling='yes'
    frameborder='0' 
    name='{%& slug %}'
    src='https://kitsu.io/anime/{%& slug %}'></iframe>
</body>")


(fn getAnime [services offset]
  (let [offsetParam (.. "page[offset]=" offset)
        initParams ["fields[anime]=slug"
                    "page[limit]=1"
                    offsetParam
                    "sort=-user_count"]
        params (icollect [_ v (ipairs services) &into initParams]
                 (.. "filter[streamers]=" (fm.escapePath v)))
        reqParams {:headers {:Accept "application/vnd.api+json"}}
        url (.. "https://kitsu.io/api/edge/anime?" (table.concat params "&"))]
    (Fetch url reqParams)))

(fm.setRoute
  "/"
  (fn [r]
    (fm.serveContent "select-site" { : streamServices })))

(fm.setRoute
  "/random"
  (fn [r]
    (case-try (. r :params "streamers[]")
      streamers (getAnime streamers 0)
      (200 _ listResp) (. (DecodeJson listResp) :meta :count)
      animeCount (% (Rand64) animeCount)
      offset (getAnime streamers offset)
      (200 _ randomResp) (. (DecodeJson randomResp) :data 1 :attributes :slug)
      slug (fm.serveContent "random" {: slug})
      (catch
        (_) (fm.serveError 500)))))

(fm.run)
