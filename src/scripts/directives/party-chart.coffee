angular.module "partyChartDirective", []
  .directive "partyChart", ($window, $filter) ->
    restrict: "E"
    scope: false
    link: (scope, element, attr) ->
      retina = true if $window.devicePixelRatio > 1
      svgHeight = 150
      partyColors =
        "Ø": "#731525"
        "Å": "#5AFF5A"
        F: "#9C1D2A"
        A: "#E32F3B"
        B: "#E52B91"
        C: "#0F854B"
        V: "#0F84BB"
        O: "#005078"
        I: "#EF8535"
        K: "#F0AC55"
      svg = d3.select(element[0]).append "svg"
        .attr "width", "100%"
        .attr "height", svgHeight
      tip = d3.tip()
        .attr "class", "d3-tip"
        .html (value, suffix) ->
          value = $filter('number')(value)
          html = "<p>#{value}#{suffix}</p>"

          return html
      svg.call tip

      waitForPoll = scope.$watch "poll", (newData) ->
        if newData
          render()
          waitForPoll()

          $window.onresize = -> scope.$apply()

          scope.$watch "view", ->
            svg.selectAll("*").remove()
            render()

          scope.$watch (->
            angular.element($window)[0].innerWidth
          ), ->
            svg.selectAll("*").remove()
            render()

      render = ->
        renderColumnView() if scope.view is "percent"
        renderDonutView() if scope.view is "mandates"

      renderColumnView = ->
        entries = scope.poll.entries.entry
        entryCount = entries.length
        svgWidth = d3.select(element[0])[0][0].offsetWidth
        columnWidth = svgWidth / entryCount
        barMargin = (svgWidth / (entryCount - 1)) * 0.2
        barWidth = columnWidth - barMargin
        columnX = columnWidth + (barMargin / entryCount)
        logoSize = if columnWidth < 20 then columnWidth else 20
        logoTopMargin = 10
        logoLeftMargin = (barWidth - logoSize) / 2
        barMaxHeight = svgHeight - logoSize - logoTopMargin
        maxPercent = d3.max entries, (d) -> parseFloat d.percent
        yScale = d3.scale.linear()
          .domain [0, maxPercent]
          .range [barMaxHeight, 0]

        columns = svg.selectAll(".column").data(entries)

        columns
          .enter()
            .append "rect"
              .attr "class", "column"
              .attr "height", 0
              .attr "y", barMaxHeight
              .attr "fill", (d) -> partyColors[d.party.letter]

        columns
          .attr "width", barWidth
          .attr "x", (d, i) -> columnX * i
          .transition().duration(1000)
            .attr "height", (d) -> barMaxHeight - yScale d.percent
            .attr "y", (d) -> yScale d.percent

        columns
          .on "mouseover", (d) -> tip.show(d.percent, '%')
          .on "mouseout", tip.hide

        logos = svg.selectAll(".logo").data(entries)

        logos
          .enter()
            .append "image"
            .attr "class", "logo"
            .attr "y", barMaxHeight + logoTopMargin
            .attr "xlink:href", (d) ->
              return "/upload/tcarlsen/berlingske-barometer-teaser/img/#{d.party.letter.toLowerCase()}_small@2x.png" if retina
              return "/upload/tcarlsen/berlingske-barometer-teaser/img/#{d.party.letter.toLowerCase()}_small.png"

        logos
          .attr 'width', logoSize
          .attr 'height', logoSize
          .attr "x", (d, i) -> (columnX * i) + logoLeftMargin

      renderDonutView = ->
        entries = scope.poll.blokEntries
        entryCount = entries.length
        svgWidth = d3.select(element[0])[0][0].offsetWidth
        pi = Math.PI
        frameWidth = svgWidth / 2
        frameHight = svgHeight
        logoSize = 15
        logoMargin = 15
        donutWidth = 60
        donutRadius = if frameWidth < frameHight then frameWidth - logoSize else frameHight - logoSize - logoMargin
        donutInnerRadius = donutRadius - donutWidth
        arc = d3.svg.arc()
          .outerRadius donutRadius
          .innerRadius donutInnerRadius
        pie = d3.layout.pie()
          .sort(null)
          .value (d) -> d.mandates
          .startAngle -90 * (pi / 180)
          .endAngle 90 * (pi / 180)

        donut = svg.append "g"
          .attr "id", "donut"
          .attr "transform", "translate(#{frameWidth}, #{frameHight})"
          .data [entries]

        slices = donut.selectAll(".slice").data(pie)

        slices
          .enter()
            .append "path"
              .attr "class", "slice"
              .attr "fill", (d) -> partyColors[d.data.party.letter]

        slices
          .transition().duration(1000)
            .attr "d", arc

        slices
          .on "mouseover", (d) -> tip.show(d.data.mandates, '')
          .on "mouseout", tip.hide

        logos = donut.selectAll(".logo").data(pie)

        logos
          .enter()
            .append "image"
            .attr "class", "logo"
            .attr "xlink:href", (d) ->
              return "/upload/tcarlsen/berlingske-barometer-teaser/img/#{d.data.party.letter.toLowerCase()}_small@2x.png" if retina
              return "/upload/tcarlsen/berlingske-barometer-teaser/img/#{d.data.party.letter.toLowerCase()}_small.png"
            .attr 'width', logoSize
            .attr 'height', logoSize

        logos
          .attr "display", (d) ->
            return "none" if d.data.mandates is "0"
            return "block"
          .transition().duration(1000)
            .attr "x", (d) ->
              c = arc.centroid(d)
              x = c[0]
              y = c[1]
              h = Math.sqrt(x*x + y*y)

              return ((x / h) * (donutRadius + logoMargin)) - (logoSize / 2)
            .attr "y", (d) ->
               c = arc.centroid(d)
               x = c[0]
               y = c[1]
               h = Math.sqrt(x*x + y*y)

               return ((y / h) * (donutRadius + logoMargin)) - (logoSize / 2)
