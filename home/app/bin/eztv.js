#!/usr/bin/env node
const request = require('https')
const spawn = require('child_process').spawn

const rofi =
    (data) => {
      return new Promise((res,rej) => {
        let stdout
        let stderr
        let menu = spawn("rofi", [ "-dmenu", "-fuzy", "-i" ])
        for (let d of data) menu.stdin.write(d + '\n')
        menu.stdin.end()
        menu.stdout.on('data', data => {stdout = data.toString().trim()})
        menu.stderr.on('data', console.error)
        menu.on('exit', code => {
          if (code !== 0 && code !== 10 && (stdout || stderr)) {
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
    console.log(group)
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
                   res.on('end', () => resolve(get_from_regex(regex, rawData,mapper)))
                 })
            .on('error', err => reject(err))
      })
    }

const check_url = (URL) =>new Promise(( resolve, reject) =>
      request.get("https://"+URL, res => resolve(res.statusCode)))

const make_a_map = (m) => new Map(m.map(e => [e[2],e[1]]))

const main = async () => {
  const URLS = [...new Set(await content_list("https://eztvstatus.com/", /eztv\.\w+/gm))]
  const res = await Promise.all(URLS.reduce((acc,el) => [...acc,check_url(el)],[]))
  const URL = URLS[res.findIndex(e => e==200)]
  const allShow = await content_list("https://"+URL+"/showlist/",/<a href="(.*?)"\s*class="thread_link"\s*>\s*(.*)\s*<\/a>/gm, make_a_map)
  const show = await rofi([...allShow.keys()])
  if(show){
    const episodes = await content_list("https://"+URL+"/"+allShow.get(show), /<a href="(.*?)" class="magnet" title="(.*?)"(?:.*\n.*\n.*\n.*\n.*\n.*?color="green">([0-9]+).*)?/g,make_a_map)
    const ep = await rofi([...episodes.keys()])
    if(ep) console.log(episodes.get(ep))
  }
}

main()

// content_list(URL + "/showlist/",
             // /<a href="(.*?)"\s*class="thread_link"\s*>\s*(.*)\s*<\/a>/gm)
    // .then(shows => rofi(shows.keys(), (err, selection, code) =>
      // { if(selection)content_list(URL + (shows.get(selection)[1]),
			// /<a href="(.*?)" class="magnet" title="(.*?)"(?:.*\n.*\n.*\n.*\n.*\n.*?color="green">([0-9]+).*)?/g)
              // .then(magnets => rofi(
                // [...magnets.keys()]
                // .map(el => (magnets.get(el)[3]!=undefined)? el+"| Seeds "+magnets.get(el)[3]:el+"| Seeds -"),
                // (err, selection, code) => {if(selection)console.log(magnets.get(selection.split("|")[0])[1])}))}
      // ))
