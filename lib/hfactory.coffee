#
# * Copyright (c) Novedia Group 2012.
# *
# *    This file is part of Hubiquitus
# *
# *    Permission is hereby granted, free of charge, to any person obtaining a copy
# *    of this software and associated documentation files (the "Software"), to deal
# *    in the Software without restriction, including without limitation the rights
# *    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# *    of the Software, and to permit persons to whom the Software is furnished to do so,
# *    subject to the following conditions:
# *
# *    The above copyright notice and this permission notice shall be included in all copies
# *    or substantial portions of the Software.
# *
# *    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# *    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# *    PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
# *    FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# *    ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# *
# *    You should have received a copy of the MIT License along with Hubiquitus.
# *    If not, see <http://opensource.org/licenses/mit-license.php>.
#

fs = require "fs"
winston = require "winston"
logger = new winston.Logger
  transports: [
    new winston.transports.Console(colorize: true)
  ]


actors = {}
adapters = {}


withActor = (type, actor) ->
  if not type then throw new Error "Actor's type undefined"
  if not actor then throw new Error "Actor undefined"
  if actors[type]
    logger.warn "Actor '#{type}' already defined"
  else
    logger.info "Actor '#{type}' added"
    actors[type] = actor

withAdapter = (type, adapter) ->
  if not type then throw new Error "Adapter's type undefined"
  if not adapter then throw new Error "Adapter undefined"
  if adapters[type]
    logger.warn "Adapter '#{type}' already defined"
  else
    logger.info "Adapter '#{type}' added"
    adapters[type] = adapter


newActor = (type, properties) ->
  if not type then throw new Error "Actor's type undefined"
  if not actors[type] then actors[type] = require type
  else if typeof actors[type] is "string" then actors[type] = require actors[type]
  new actors[type] properties

newAdapter = (type, properties) ->
  if not type then throw new Error "Adapter's type undefined"
  if not adapters[type] then adapters[type] = require type
  else if typeof adapters[type] is "string" then adapters[type] = require adapters[type]
  new adapters[type] properties


scan = (path, callback) ->
  if fs.existsSync path
    stats =  fs.statSync path
    if stats.isDirectory()
      logger.info "Scanning #{path}..."
      files = fs.readdirSync path
      files.forEach (file) ->
        pos = file.indexOf ".coffee"
        if pos isnt -1
          stats = fs.statSync "#{path}/#{file}"
          if stats.isFile()
            callback file.substr(0, pos), "#{path}/#{file}"

scan "#{process.cwd()}/actors", withActor
scan "#{process.cwd()}/adapters", withAdapter

actors['hactor'] = require "./actor/hactor"
actors['hauth'] = require "./actor/hauth"
actors['hchannel'] = require "./actor/hchannel"
actors['hdispatcher'] = require "./actor/hdispatcher"
actors['hgateway'] = require "./actor/hgateway"
actors['hsession'] = require "./actor/hsession"
actors['htracker'] = require "./actor/htracker"

adapters['channel_in'] = require "./adapters/channel_in"
adapters['channel_out'] = require "./adapters/channel_out"
adapters['fork'] = require "./adapters/fork"
adapters['http_in'] = require "./adapters/http_in"
adapters['http_out'] = require "./adapters/http_out"
adapters['inproc'] = require "./adapters/inproc"
adapters['lb_socket_in'] = require "./adapters/lb_socket_in"
adapters['lb_socket_out'] = require "./adapters/lb_socket_out"
adapters['socket_in'] = require "./adapters/socket_in"
adapters['socket_out'] = require "./adapters/socket_out"
adapters['socketIO'] = require "./adapters/socketIO"
adapters['timerAdapter'] = require "./adapters/timerAdapter"
adapters['twitter_in'] = require "./adapters/twitter_in"


exports.withActor = withActor
exports.withAdapter = withAdapter
exports.newActor = newActor
exports.newAdapter = newAdapter
