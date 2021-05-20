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
                 })
            .on('error', err => reject(err))
      })
    }

const check_url = (URL) => new Promise(( resolve, reject) =>
      request.get("https://"+URL, res => resolve(res.statusCode)))

const make_a_map = (m) => new Map(m.map(e => [e[2],e[1]]))

const main = async () => {
  const URLS = [...new Set(await content_list("https://eztvstatus.com/", /eztv\.\w+/gm))]
  const URL = URLS.filter(async (el) =>  await check_url(el) == 200)[0]
  const allShow = await content_list("https://"+URL+"/showlist/",/<a href="(.*?)"\s*class="thread_link"\s*>\s*(.*)\s*<\/a>/gm, make_a_map)
  const show = await rofi([...allShow.keys()])
  if(show){
    const episodes = await content_list("https://"+URL+"/"+allShow.get(show), /<a href="(.*?)" class="magnet" title="(.*?)"(?:.*\n.*\n.*\n.*\n.*\n.*?color="green">([0-9]+).*)?/g,make_a_map)
    const ep = await rofi([...episodes.keys()])
    if(ep) console.log(episodes.get(ep))
  }
}

main()
