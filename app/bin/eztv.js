#!/usr/bin/env node
const request = require('https')
const spawn = require('child_process').spawn

const rofi =
    (data, callback) => {
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
          return callback(code)
        }
        return callback(undefined, stdout, code)
      })
    }

const get_from_regex =
    (regex, data) => {
      let result = new Map()
      while ((m = regex.exec(data)) !== null) {
        if (m.index === regex.lastIndex) {
          regex.lastIndex++
        }
        let key = ""
        let matches = m.reduce((acc, el, index, arr) => {
          if (index == 2)
            key = el
            return [...acc, el ]
        }, [])
        result.set(key, matches)
      }
      return result
    }

const content_list =
    (url, regex) => {
      return new Promise((resolve, reject) => {
            request.get(url,
                 res => {
                   res.setEncoding('utf8')
      let rawData = ""
      res.on('data', chunk => rawData += chunk)
                   res.on('end', () => resolve(get_from_regex(regex, rawData)))
                 })
            .on('error', err => reject(err))
      })
    }

const URL = "https://eztv.re"

content_list(URL + "/showlist/",
             /<a href="(.*?)"\s*class="thread_link"\s*>\s*(.*)\s*<\/a>/gm)
    .then(shows => rofi(shows.keys(), (err, selection, code) => 
      { if(selection)content_list(URL + (shows.get(selection)[1]),
	    /<a href="(.*?)" class="magnet" title="(.*?)"(?:.*\n.*\n.*\n.*\n.*\n.*?color="green">([0-9]+).*)?/g)
              .then(magnets => rofi(
                [...magnets.keys()]
                .map(el => (magnets.get(el)[3]!=undefined)? el+"| Seeds "+magnets.get(el)[3]:el+"| Seeds -"), 
                (err, selection, code) => {if(selection)console.log(magnets.get(selection.split("|")[0])[1])}))}
      ))
