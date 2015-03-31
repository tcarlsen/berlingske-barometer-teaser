angular.module "berlingskeBarometerTeaserDirective", []
  .directive "berlingskeBarometerTeaser", (pollGetter, pollSorter) ->
    restrict: "E"
    templateUrl: "/upload/tcarlsen/berlingske-barometer-teaser/partials/berlingske-barometer-teaser.html"
    link: (scope, element, attr) ->
      currentYear = new Date().getFullYear()

      scope.view = "percent"

      getLatestPoll = (year) ->
        pollGetter.get(year, "10.xml").then (data) ->
          if data.error
            getLatestPoll currentYear - 1
          else
            scope.poll = pollSorter.sort data.json.polls.poll[0]

      getLatestPoll currentYear
