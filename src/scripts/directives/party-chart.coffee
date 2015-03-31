angular.module "partyChartDirective", []
  .directive "partyChart", ($window) ->
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

      waitForPoll = scope.$watch "poll", (newData) ->
        if newData
          render()
          waitForPoll()

      render = ->
        renderColumnView() if scope.view is "percent"

      renderColumnView = ->
        entries = scope.poll.entries.entry
        entryCount = entries.length
        svgWidth = svg[0][0].offsetWidth
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
