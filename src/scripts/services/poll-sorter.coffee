angular.module "pollSorterService", []
  .service "pollSorter", ->
    sort: (data) ->
      poll = data

      poll.entries.entry.sort (a, b) ->
        a = a.party.letter
        b = b.party.letter

        getInt = (c) ->
          c = c.toLowerCase().charCodeAt(0)

          switch c
            when 229 then 299 #å
            when 248 then 298 #ø
            when 230 then 297 #æ
            else c

        d = getInt(a)
        e = getInt(b)

        if d isnt e
          return d - e

      return poll
