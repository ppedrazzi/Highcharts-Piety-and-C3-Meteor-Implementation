
Data = new Mongo.Collection("data")
Sparkline = new Mongo.Collection("sparkline")

if Meteor.isClient
    Meteor.startup () ->
        Meteor.call("clearData")
        Meteor.call("loadSparklineData")
        Meteor.call("buildData", (error, result) ->
            Session.set("randomId", result))
        console.log "Client is alive."

    Template.sparklines.helpers
    #https://github.com/LumaPictures/meteor-jquery-sparklines
        data: () ->
            Sparkline.find()
        someArray: () ->
            [1,2,3,4,5]

    Template.piety.onRendered () ->
        #http://benpickles.github.io/peity/
        $("span.pie").peity("pie")
        $("span.line").peity("line")
        $("span.bar").peity("bar")

    Template.chart.onRendered () ->
        #https://atmospherejs.com/perak/c3
        chart = c3.generate(
          bindto: @find('#chartc3')
          data:
            xs:
              'data1': 'x'
              'data2': 'x'
            columns: [
              [ 'x' ]
              [ 'data1' ]
              [ 'data2' ]
            ])
        @autorun (tracker) ->
          chart.load columns: [
            ['x', 30, 50, 75, 100, 120]
            ['data1', 30, 200, 100, 400, 150]
            ['data2', 20, 180, 240, 100, 190]
            []
          ]

    Template.piety.helpers
    #http://benpickles.github.io/peity/
        line: () ->
            [5,3,9,6,5,9,7,3,5,2]

    Template.highcharts.events
        #http://www.highcharts.com/demo/box-plot/grid-light
        'click #addData': () ->
            Meteor.call("newData", (e,r) ->
                if e
                    console.log e
                else
                    Session.set("randomId", r) )

        'click #removeRandom': () ->
            Meteor.call("removeRandom", Session.get("randomId"))

    Template.highcharts.onRendered () ->
        Tracker.autorun () ->
            dataset = Data.find().fetch()
            $('#newChart').highcharts
                chart: type: 'bar'
                title: text: 'Fruit Consumption'
                xAxis: categories: ['Apples', 'Bananas', 'Oranges']
                yAxis: title: text: 'Fruit eaten'
                series:
                    for item in dataset
                        name: item.name
                        data:[
                            item.apples
                            item.bananas
                            item.oranges]

if Meteor.isServer
    Meteor.startup () ->
        console.log "Server is alive."

    Meteor.methods
        clearData: () ->
            Data.remove({})

        removeRandom: (id) ->
            Data.remove({_id: id})

        loadSparklineData: () ->
            n = 0
            while n < 100
                Sparkline.insert
                    value: Random.fraction() + 100
                n += 1

        newData: () ->
            Data.insert
                name: "WHO"
                apples: Random.fraction() * 10
                bananas: Random.fraction() * 10
                oranges: Random.fraction() * 10

        buildData: () ->
            Data.insert
                name: "Jane"
                apples: 5
                bananas: 8
                oranges: 10
            Data.insert
                name: "John"
                apples: 5
                bananas: 7
                oranges: 3
            Data.insert
                name: "Sally"
                apples: 2
                bananas: 9
                oranges: 3
