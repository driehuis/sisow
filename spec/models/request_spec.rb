require 'spec_helper'

describe Sisow::Api::Request do

  before :each do
    @request = Sisow::Api::Request.new
    @request.stub!(:params).and_return(@request.default_params)
    @request.stub!(:method).and_return("CheckMerchantRequest")
    @request.stub!(:clean).and_return(['ideal'])
    @request.stub!(:validate!).and_return(true)
    Sisow::Api::Request.stub!(:new).and_return(@request)
  end

  it "should point to the base URI of the Sisow API" do
    request = Sisow::Api::Request.new
    request.send(:base_uri).should == "https://www.sisow.nl/Sisow/iDeal/RestHandler.ashx"
  end

  it "should perform properly" do
    sha1 = Digest::SHA1.hexdigest(
      [
        Sisow.configuration.merchant_id,
        Sisow.configuration.merchant_key
      ].join
    )

    params = @request.params.merge!(:sha1 => sha1)
    @request.stub!(:params).and_return(params)

    VCR.use_cassette('request') do
      @request.perform
    end
  end

  it "should raise an exception if the API returns an error" do
    VCR.use_cassette('failed_request') do
      lambda{ @request.perform }.should raise_error(Sisow::Exception, "An error occurred: TA3130. No SHA1")
    end
  end

end
