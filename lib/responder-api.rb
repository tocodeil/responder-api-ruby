require 'rubygems'
require 'oauth'
require 'json'
require 'optparse'
require 'pp'
require 'uri'

# gem class name Responder
class Responder

  # initialize new Responder Object
  #
  # Example:
  #   >> Responder.new(MNFDKRHUI2398RJ2O3R, NF932URH29837RY923JN, NF2983HFOIMNW2983H32, NFG8927RH238RH2)
  #
  # Arguments:
  #   ck: (String) Client Key
  #   cs: (String) Client Secret
  #   uk: (String) User Key
  #   us: (String) User Secret
  def initialize(ck, cs, uk, us)
    consumer = OAuth::Consumer.new(ck,cs, :site => "http://api.responder.co.il")
    @access_token = OAuth::AccessToken.new(consumer, uk, us)
  end

  # <!----------- LISTS -----------!>

  # get all the lists
  #
  # Example:
  #   >> Responder.get_lists()
  #   => { "LISTS" => [{}, {}, ... ] }
  #
  def get_lists
    return sendRequest(:get, '', '', {})
  end

  # get list by id
  #
  # Example:
  #   >> Responder.get_list(123456)
  #   => { "LISTS" => [{}, {}, ... ] }
  #
  # Arguments:
  #   id: (int)
  def get_list(id)
    return sendRequest(:get, '', "?list_ids=" + id.to_s, {})
  end

  # create new list
  #
  # Example:
  #   >> Responder.create_list( {"DESCRIPTION": "Test List", "NAME": "try", ... } )
  #   => {"ERRORS"=>[], "LIST_ID"=>123456, "INVALID_EMAIL_NOTIFY"=>[], "INVALID_LIST_IDS"=>[]}
  #
  # Arguments:
  #   args: (Hash)
  def create_list(args = {})
    return sendRequest(:post, 'info', '', args)
  end

  # edit list by id
  #
  # Example:
  #   >> Responder.edit_list(123456, {"DESCRIPTION": "Test List Edited", "NAME": "try Edited", ... } )
  #   => {"ERRORS"=>[], "INVALID_EMAIL_NOTIFY"=>[], "INVALID_LIST_IDS"=>[], "SUCCESS"=>true}
  #
  # Arguments:
  #   id: (int)
  #   args: (Hash)
  def edit_list(id, args = {})
    return sendRequest(:put, 'info', "/" + id.to_s, args)
  end

  # delete list by id
  #
  # Example:
  #   >> Responder.delete_list(123456)
  #   => {"DELETED_LIST_ID"=>123456}
  #
  # Arguments:
  #   id: (int)
  def delete_list(id)
    return sendRequest(:delete, 'info', "/" + id.to_s, {})

  end

  # <!----------- SUBSCRIBERS -----------!>

  # get subscribers from specific list
  #
  # Example:
  #   >> Responder.get_subscribers(123456)
  #   => [{}, {}, ... ]
  #
  # Arguments:
  #   id: (int)
  def get_subscribers(id)
    return sendRequest(:get, '', "/" + id.to_s + "/subscribers", {})
  end

  # create new subscribers in specific list
  #
  # Example:
  #   >> Responder.create_subscribers(123456, {0 => {'EMAIL': "sub1@email.com", 'NAME': "sub1"}, 1 => {'EMAIL': "sub2@email.com", 'NAME': "sub2"}} )
  #   => {"SUBSCRIBERS_CREATED": [], "EMAILS_INVALID": [], "EMAILS_EXISTING": ["johnsmith@gmail.com"], "EMAILS_BANNED": [], "PHONES_INVALID": [], "PHONES_EXISTING": [], "BAD_PERSONAL_FIELDS": {}, "ERRORS" : [] }
  #
  # Arguments:
  #   id: (int)
  #   args: (Hash)
  def create_subscribers(id, args = {} )
    return sendRequest(:post, 'subscribers', "/" + id.to_s + "/subscribers", args)
  end

  # edit subscribers of specific list
  #
  # Example:
  #   >> Responder.edit_subscribers(123456, {0 => {'IDENTIFIER': "sub1@email.com", 'NAME': "sub1NewName"}, 1 => {'IDENTIFIER': "sub2", 'NAME': "sub2"}} ) 
  #   => {"SUBSCRIBERS_UPDATED": [], "INVALID_SUBSCRIBER_IDENTIFIERS": [], "EMAILS_INVALID": [], "EMAILS_EXISTED": ["johnsmith@gmail.com"], "EMAILS_BANNED": [], "PHONES_INVALID": [], "PHONES_EXISTING": [], "BAD_PERSONAL_FIELDS": {} }}  
  #
  # Arguments:
  #   id: (int)
  #   args: (Hash)
  def edit_subscribers(id, args)
    return sendRequest(:put, 'subscribers', "/" + id.to_s + "/subscribers", args)
  end

  # delete subscribers of specific list
  #
  # Example:
  #   >> Responder.delete_subscribers(123456, {0 => { 'EMAIL': "sub8@email.com" }, 1 => { 'ID': 323715811 }} ) 
  #   => {"INVALID_SUBSCRIBER_IDS": [], "INVALID_SUBSCRIBER_EMAILS": [], "DELETED_SUBSCRIBERS": {} }
  #
  # Arguments:
  #   id: (int)
  #   args: (Hash)
  def delete_subscribers(id, args)
    return sendRequest(:post, 'subscribers', "/"  + id.to_s + "/subscribers?method=delete", args)
  end

  # <!----------- PERSONAL FIELDS -----------!>

  # get personal fields from specific list
  #
  # Example:
  #   >> Responder.get_personal_fields(123456)
  #   => {"LIST_ID": 123456, "PERSONAL_FIELDS": [{"ID": 1234, "NAME": "City", "DEFAULT_VALUE": "Tel Aviv", "DIR": "rtl", "TYPE": 0}, {"ID": 5678, "NAME": "Birth Date", "DEFAULT_VALUE" : "", "DIR": "ltr", "TYPE": 1}] }
  #
  # Arguments:
  #   id: (int)
  def get_personal_fields(id)
    response = @access_token.request(:get, "/v1.0/lists/" + id.to_s + "/personal_fields")
    rsp = JSON.parse(response.body)
    return rsp
  end

  # create new personal fields in specific list
  #
  # Example:
  #   >> Responder.create_personal_fields(123456, {0 => {"NAME": "City", "DEFAULT_VALUE": "Tel Aviv", "DIR": "rtl", "TYPE": 0}, 1 => {"NAME": "Date of birth", "TYPE": 1}} )
  #   => {"LIST_ID": 123456, "CREATED_PERSONAL_FIELDS": [], "EXISTING_PERSONAL_FIELD_NAMES": []}
  #
  # Arguments:
  #   id: (int)
  #   args: (Hash)
  def create_personal_fields(id, args = {} )
    post_JSON = {'personal_fields' => 
      JSON.generate(args)
    }

    response = @access_token.request(:post, "/v1.0/lists/"  + id.to_s + "/personal_fields" , post_JSON)
    rsp = JSON.parse(response.body)
    return rsp
  end

  # edit personal fields of specific list
  #
  # Example:
  #   >> Responder.edit_personal_fields(123456, {0 => {"ID": "1234", "DEFAULT_VALUE": "Tel Aviv-Jaffa"}, 1 => {"ID": "5678", "DIR": "rtl"}})
  #   => {"LIST_ID" : 123456, "UPDATED_PERSONAL_FIELDS": [], "INVALID_PERSONAL_FIELD_IDS": [], "EXISTING_PERSONAL_FIELD_NAMES": []}
  #
  # Arguments:
  #   id: (int)
  #   args: (Hash)
  def edit_personal_fields(id, args)
    put_JSON = {'personal_fields' => 
      JSON.generate(args)
    }

    response = @access_token.request(:put, "/v1.0/lists/"  + id.to_s + "/personal_fields" , put_JSON)
    rsp = JSON.parse(response.body)
    return rsp
  end

  # delete personal fields of specific list
  #
  # Example:
  #   >> Responder.delete_personal_fields(123456, {0 => { 'ID': 1234 }, 1 => { 'ID': 5678 }} ) 
  #   => {"DELETED_FIELDS": [], "INVALID_FIELD_IDS" : [] }
  #
  # Arguments:
  #   id: (int)
  #   args: (Hash)
  def delete_personal_fields(id, args)
    delete_JSON = {'personal_fields' => 
      JSON.generate(args)
    }

    response = @access_token.request(:post, "/v1.0/lists/"  + id.to_s + "/personal_fields?method=delete" , delete_JSON)
    rsp = JSON.parse(response.body)
    return rsp
  end



  # privare method
  # common code to send the requests
  #
  # Example:
  #   >> sendRequest(:get, 'info', '?list_ids=123456', {} ) 
  #   => {}
  #
  # Arguments:
  #   type: (:get \ :post \ :put \  :delete)
  #   object_name: (string) - ('info', 'subscribers', 'personal_fields')
  #   query: (string)
  #   args: (Hash)
  def sendRequest(type, object_name = "", query = "", args = {})
    if (!(args == {}) )
      json_obj = { object_name => 
        JSON.generate(args)
      }
    end

    query = URI.escape("/v1.0/lists" + query)
    response = @access_token.request(type, query, json_obj)
    response = JSON.parse(response.body) unless response.class == String
    return response
  end

  private :sendRequest



end