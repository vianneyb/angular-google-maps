describe "MarkerChildModel", ->
    beforeEach ->
        #comparison variables
        @index = 0
        @model =
            icon: 'icon.png'
            coords:
                latitude: 90
                longitude: 90
            options:
                animation: google.maps.Animation.BOUNCE
        @iconKey = 'icon'
        @zIndexKey = 'zIndex'
        @coordsKey = 'coords'
        @optionsKey = 'options'

        #define / inject values into the item we are testing... not a controller but it allows us to inject
        angular.module('mockModule', ["google-maps"])
        module('mockModule')

        inject ($timeout, $rootScope, $controller, MarkerChildModel, MarkerManager) =>
            scope = $rootScope.$new()
            scope.click = ->
            scope.icon = @iconKey
            scope.coords = @coordsKey
            scope.options = @optionsKey
            @subject = new MarkerChildModel(@model, scope, document.gMap, $timeout, defaults = {},
                    doClick = (()->),
                    new MarkerManager(document.gMap, undefined, undefined))

    it 'can be created', ->
        expect(@subject).toBeDefined()
        expect(@subject.scope).toBeDefined()

    it 'parentScope keys are set correctly', ->
        expect(@subject.iconKey).toEqual(@iconKey)
        expect(@subject.coordsKey).toEqual(@coordsKey)
        expect(@subject.optionsKey).toEqual(@optionsKey)

    describe 'evalModelHandle()', ->
        it 'scope values are equal to the model values by key', ->
            #since evalHModelHandle does not use => and uses ->
            #it is a prototype function which is more static, and kinda private.. as in not obvious to find
            #2 ways to get to it instance.__proto___.function or classType.prototype.function
            # equates to @subject.__proto__.evalModelHandle or directives.api.model.child.MarkerChildModel.prototype.evalModelHandle
            expect(@subject.__proto__.evalModelHandle(@model, @iconKey)).toEqual(@model.icon)
            expect(@subject.__proto__.evalModelHandle(@model, @coordsKey)).toEqual(@model.coords)
            expect(@subject.__proto__.evalModelHandle(@model, @optionsKey)).toEqual(@model.options)
        it 'updates an existing models properties via watch, icon', ->
            @model.icon = 'test.png'
            expect(@subject.__proto__.evalModelHandle(@model, @iconKey)).toEqual(@model.icon)
        it 'updates an existing models properties via watch, coords', ->
            @model.coords.latitude = 91
            expect(@subject.__proto__.evalModelHandle(@model, @coordsKey)).toEqual(@model.coords)
        it 'updates an existing models properties via watch, options', ->
            @model.options = 'options2'
            expect(@subject.__proto__.evalModelHandle(@model, @optionsKey)).toEqual(@model.options)
        it 'undefined model returns undefined', ->
            expect(@subject.__proto__.evalModelHandle(undefined, @optionsKey)).toEqual(undefined)

        it 'modelKey of self returns model', ->
            expect(@subject.__proto__.evalModelHandle(@model, 'self')).toEqual(@model)
        it 'modelKey of undefined returns undefined', ->
            expect(@subject.__proto__.evalModelHandle(@model, undefined)).toEqual(undefined)

    describe 'maybeSetScopeValue()', ->
        beforeEach(->
            @gSetterCalled = false
            @isInit = false
            @gSetter = (scope)=>
                @gSetterCalled = true
        )
        it "oldModel undefined, isInit false - changes scope's models value, and calls gSetter ", ->
            newModel =
                icon: 'someIcon'
            @subject.scope.icon = 'junk'
            @subject.maybeSetScopeValue('icon', newModel, undefined, @iconKey,
                    @subject.__proto__.evalModelHandle, @isInit, @gSetter)
            expect(@gSetterCalled).toEqual(true)
            expect(@subject.scope.icon).toEqual(newModel.icon)


    describe 'destroy()', ->
        it 'wipes internal scope', ->
            @subject.destroy()
            expect(@subject.scope.$$destroyed).toEqual(true)

        it 'wipes gMarker', ->
            @subject.destroy()
            expect(@subject.gMarker).toEqual(undefined)
            expect(@subject.gMarkerManager.gMarkers.length).toEqual(0)
