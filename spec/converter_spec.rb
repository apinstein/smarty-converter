require 'spec_helper'

describe Smarty::Converter do

  let(:test_data) do
    <<-HTML
      <html>
        <head>
          <script src="bower_components/head-1.js"></script>
          <script src="bower_components/json3/lib/head-2.js"></script>
          <link rel='stylesheet' href='foo/bar.css'>
          <link rel='stylesheet' href='http://foo.js'>
          <link some-data='foo' href='bar' >
        </head>
        <body>
          <!--[if lt IE 9]>
            <script src="bower_components/es5-shim/es5-shim.js"></script>
            <script src="bower_components/json3/lib/json3.min.js"></script>
          <![endif]-->
          <!--[if lt IE 7]>
            <script src="bower_components/ie7.js"></script>
            <link rel='stylesheet' href='fpp.css'>
          <![endif]-->
          <!-- foobar -->
          <!-- build:js({.tmp,app}) scripts/scripts.js -->
            <script src="scripts/app.js"></script>
            <script src="scripts/routes.js"></script>
          <!-- endbuild -->
          <script src='/foo/bar/baz.js'></script>
        </body>
      </html>
    HTML
  end

  let(:urls_to_rewrite) do
    [
      'bower_components/head-1.js',
      'bower_components/json3/lib/head-2.js',
      'foo/bar.css',
      'fpp.css',
      'bower_components/es5-shim/es5-shim.js',
      'bower_components/json3/lib/json3.min.js',
      'bower_components/ie7.js',
      'scripts/app.js',
      'scripts/routes.js'
    ].sort
  end

  let(:rewrite_path) { '/this/rewrite/path' }


  let(:ignored_urls) do
    [
      'http://foo.js',
      '/foo/bar/baz.js'
    ]
  end

  subject { Smarty::Converter.new(test_data, rewrite_path) }

  it "should return a list of urls to rewrite" do
    subject.urls.sort.should eq(urls_to_rewrite) 
  end

  it "should be a smarty template" do
    (subject.smarty_template =~ /{WFHead}.+{\/WFHead}.+{literal}.+{\/literal}/m).should_not be_nil
  end

  it "should return a smarty template with the urls rewritten" do
    urls_to_rewrite.each do |url|
      subject.smarty_template.should include(rewrite_path + url)
    end
  end

end
