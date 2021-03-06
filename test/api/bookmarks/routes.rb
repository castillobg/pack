require 'cuba/test'
require 'json'

require './app'
require './data/repositories/bookmark'

setup do
  { post: { method: 'post', content_type: 'application/json' } }
end

scope do
  test 'returns 404 when no bookmark is found' do
    get '/bookmarks/123'

    assert_equal 404, last_response.status
  end

  test 'creates a bookmark' do |config|
    bookmark = {
      url: 'www.google.com',
      name: 'Google home'
    }.to_json

    request '/bookmarks', config[:post].merge(input: bookmark)
    assert_equal 200, last_response.status
    assert defined?(last_response.body['_id'])
    assert defined?(last_response.body['url'])
    assert defined?(last_response.body['name'])
  end

  test 'gets a bookmark' do
    bookmark = Repositories::Bookmark.create(url: 'es.stackoverflow.com/',
                                             name: 'stackoverflow home page')
    get '/bookmarks/' + bookmark['_id']
    assert_equal 200, last_response.status
    assert defined?(last_response.body['_id'])
    assert defined?(last_response.body['url'])
    assert defined?(last_response.body['name'])

    get_response = JSON.parse(last_response.body)
    assert_equal 'es.stackoverflow.com/', get_response['url']
    assert_equal 'stackoverflow home page', get_response['name']
    assert_equal bookmark['_id'],
                 BSON::ObjectId.from_string(get_response['_id']['$oid'])
  end
end
