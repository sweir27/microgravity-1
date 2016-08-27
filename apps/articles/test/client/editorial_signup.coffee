_ = require 'underscore'
benv = require 'benv'
sinon = require 'sinon'
Backbone = require 'backbone'
{ resolve } = require 'path'

describe 'EditorialSignupView', ->

  before (done) ->
    benv.setup =>
      benv.expose $: benv.require 'jquery'
      $.fn.waypoint = sinon.stub()
      sinon.stub($, 'ajax')
      Backbone.$ = $
      @$el = $('<div><div class="article-container" data-id="123"</div></div>')
      @EditorialSignupView = benv.requireWithJadeify resolve(__dirname, '../../client/editorial_signup'), ['editorialSignupLushTemplate']
      @cycleImages = sinon.stub @EditorialSignupView::, 'cycleImages'
      sinon.stub @EditorialSignupView::, 'trackSignup'
      @view = new @EditorialSignupView el: @$el
      done()

  after ->
    $.ajax.restore()
    benv.teardown()

  describe '#eligibleToSignUp', ->

    it 'checks is not in editorial article or magazine', ->
      @EditorialSignupView.__set__ 'sd',
        ARTICLE: null
        SUBSCRIBED_TO_EDITORIAL: false
        CURRENT_PATH: ''
      @view.eligibleToSignUp().should.not.be.ok()

    it 'checks if in article or magazine', ->
      @EditorialSignupView.__set__ 'sd',
        ARTICLE: null
        SUBSCRIBED_TO_EDITORIAL: false
        CURRENT_PATH: '/articles'
      @view.eligibleToSignUp().should.be.ok()

  describe '#onSubscribe', ->

    it 'removes the form when successful', ->
      @EditorialSignupView.__set__ 'sd',
        ARTICLE: { channel_id: '123', id: '123' }
        ARTSY_EDITORIAL_CHANNEL: '123'
        SUBSCRIBED_TO_EDITORIAL: false
        MEDIUM: 'social'
      @view.initialize()
      @view.onSubscribe({currentTarget: $('<div></div>')})
      $.ajax.args[0][0].success
        images: [
          { src: 'image1.jpg' },
          { src: 'image2.jpg' },
          { src: 'image3.jpg' },
        ]
      $.ajax.args[1][0].success()
      _.defer =>
        $(@$el).children("articles-es-cta__container").css('display').should.containEql 'none'
        $(@$el).children('.articles-es-cta__social').css('display').should.containEql 'block'

    it 'removes the loading spinner if there is an error', ->
      $.ajax.yieldsTo('error')
      @EditorialSignupView.__set__ 'sd',
        ARTICLE: channel_id: '123'
        ARTSY_EDITORIAL_CHANNEL: '123'
        SUBSCRIBED_TO_EDITORIAL: false
        MEDIUM: 'social'
      $subscribe = $('<div></div>')
      @view.onSubscribe({currentTarget: $subscribe})
      $($subscribe).hasClass('loading-spinner').should.be.false()