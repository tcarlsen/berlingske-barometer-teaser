angular.module "pollSorterService", []
  .service "pollSorter", ($filter) ->
    sort: (data) ->
      poll = data
      firstBlock =
        entries: []
      secondBlock =
        entries: []
      ruler = "blue"

      for entry in poll.entries.entry
        supports = parseInt(entry.supports)

        if supports is 1 or supports is 9
          firstBlock.entries.push(entry)
        else if supports is 2
          secondBlock.entries.push(entry)

        if supports is 9
          ruler = "red" if entry.party.letter is "A"

        firstBlock.entries = $filter('orderBy')(firstBlock.entries, 'party.letter')
        secondBlock.entries = $filter('orderBy')(secondBlock.entries, 'party.letter')

      if ruler is "red"
        poll.blokEntries = firstBlock.entries.concat secondBlock.entries
      else
        poll.blokEntries = secondBlock.entries.concat firstBlock.entries

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
