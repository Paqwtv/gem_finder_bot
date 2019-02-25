require 'httparty'

class RubyGemsApi
  attr_reader :text

  def initialize(request, gem_name)
    raise 'No method for request API' if request.empty?
    @text = send(request, gem_name)
  end

  def find_gem(gem_name)
    find_url = 'https://rubygems.org/api/v1/gems/'
    res = HTTParty.get("#{find_url}#{gem_name.downcase}.json")
    prepare_answer(res)
  end

  def versions(gem_name)
    versions_url = 'https://rubygems.org/api/v1/versions/'
    res = HTTParty.get("#{versions_url}#{gem_name.downcase}.json")
    version_answer(res, gem_name.capitalize)
  end

  private

  def prepare_answer(res)
    return '<b>This rubygem could not be found.</b>' unless res.ok?
    text = "Gem <b>#{res['name'].capitalize},</b>\n"
    text << "<b>version:</b> #{res['version']}\n"
    text << "<b>downloads:</b> #{res['downloads']}\n"
    text << "<b>info:</b> #{res['info']}\n" if res['info']
    text << "<a href='#{res['documentation_uri']}'>Documentation</a>\n" if res['documentation_uri']
    text << "<i>authors:</i> #{res['authors']}" if res['authors']
    text
  end

  def version_answer(responce, gem_name)
    return '<b>This rubygem could not be found.</b>' unless responce.ok?
    text = responce.to_a.size > 10 ? "The last 10 versions for <b>#{gem_name}:</b>\n" : "<b>#{gem_name} versions:</b>\n"
    responce.to_a.first(10).each_with_object(text) do |res, string|
      string << "<b>Downloads count:</b> #{res['downloads_count']}\n"
      string << "<b>Version:</b> #{res['number']}\n"
      string << "<b>Ruby version:</b> #{res['ruby_version']}\n" if res['ruby_version']
      res['prerelease'] == true ? string << "<b>Prerelease:</b> #{res['prerelease']}\n\n" : string << "\n\n"
    end
  end
end
