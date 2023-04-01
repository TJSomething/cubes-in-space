(local fm (require :fullmoon))
(local math (require :math))
(local string (require :string))

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
        serviceParam (fm.escapePath (table.concat services ","))
        params ["fields[anime]=slug"
                "page[limit]=1"
                offsetParam
                (.. "filter[streamers]=" serviceParam)
                "sort=-user_count"]
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
      (200 _ listResp) (. (DecodeJson (do (print listResp) listResp)) :meta :count)
      animeCount (math.random 0 (- (do (print animeCount) animeCount) 1))
      offset (getAnime streamers (do (print offset) offset))
      (200 _ randomResp) (. (DecodeJson randomResp) :data 1 :attributes :slug)
      slug (fm.serveContent "random" {: slug})
      (catch
        (_) (fm.serveError 500)))))

(let [randBytes (GetRandomBytes 16)
      (randInt1 randInt2) (string.unpack "I8I8" randBytes)]
  (math.randomseed randInt1 randInt2))

(fm.run)
