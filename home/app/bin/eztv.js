#!/usr/bin/env node
const request = require('https')
const spawn = require('child_process').spawn

const rofi =
    (data) => {
      return new Promise((res,rej) => {
        let stdout
        let menu = spawn("rofi", [ "-dmenu", "-fuzy", "-i" ])
        for (let d of data) menu.stdin.write(d + '\n')
        menu.stdin.end()
        menu.stdout.on('data', data => stdout = data.toString().trim())
        menu.stderr.on('data', console.error)
        menu.on('exit', code => {
          if (code !== 0 && code !== 10 && (stdout)) {
            console.error('returned with code ' + code)
            rej(code)
          }
          res(stdout)
        })
      })
    }

const get_from_regex =
  (regex, data, mapper) => {
    const group = []
      while ((m = regex.exec(data)) !== null) {
        if (m.index === regex.lastIndex) {
          regex.lastIndex++
        }
        group.push(m)
      }
    return mapper(group)
  }

const content_list =
    (url, regex, mapper = (x) => x.flatMap(x => x)) => {
      return new Promise((resolve, reject) => {
            request.get(url,
                 res => {
                   res.setEncoding('utf8')
                   let rawData = ""
                   res.on('data', chunk => rawData += chunk)
                   res.on('end', () => resolve(get_from_regex(regex, rawData, mapper)))
                 }).on('error', err => reject(err))
      })
    }

const check_url = (URL) => new Promise(( resolve, reject) =>
      request.get("https://"+URL, res => resolve(res.statusCode)))

const make_a_map = (m) => new Map(m.map(e => [e[2],e[1]]))
const make_torrent_info= (m) => new Map(m.map(e => [e[2]+" | Size: "+e[3]+" | Seeds: "+e[4],e[1]]))
const REGEX_URLS = /eztv\.\w+/gm
const REGEX_SHOWS = /<a href="(.*?)"\s*class="thread_link"\s*>\s*(.*)\s*<\/a>/gm
const REGEX_EPISODES = /<a href="(.*?)" class="magnet" title="(.*?)"(?:.*\n.*\n.*\n.*?>([0-9. KMBG]+).*)?\n.*\n.*?>([0-9]+)/gm

const main = async () => {
  const URLS = [...new Set(await content_list("https://eztvstatus.com/", REGEX_URLS))]
  const URL = URLS.filter(async (el) =>  await check_url(el) == 200)[0]
  const allShow = await content_list("https://"+URL+"/showlist/",REGEX_SHOWS, make_a_map)
  const show = await rofi([...allShow.keys()])
  if(show){
    const episodes = await content_list("https://"+URL+"/"+allShow.get(show), REGEX_EPISODES, make_torrent_info)
    const ep = await rofi([...episodes.keys()])
    if(ep) console.log(episodes.get(ep))
  }
}

main()
