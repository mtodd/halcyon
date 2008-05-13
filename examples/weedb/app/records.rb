class Records < Application
  
  # GET /records
  def index
    raise NotImplemented
  end
  
  # GET /records/1
  def show
    if record = Record[:url => params[:id]]
      ok JSON.parse(record[:data])
    else
      raise NotFound
    end
  end
  
  # POST /records
  # POST /records?key1=value1&key2=value2&...
  def create
    verify_data_validity!
    
    record = Record.new
    record.url = WeeDB.generate_unique_url_key
    record.data = (JSON.parse(params[:data]) rescue nil || {}).merge(query_params).to_json
    
    if record.save
      ok record.url
    else
      raise Exception
    end
  end
  
  # PUT /records/1
  def update
    raise NotImplemented
  end
  
  # DELETE /records/1
  def destroy
    raise NotImplemented
  end
  
  private
  
  def verify_data_validity!
    raise BadRequest unless (JSON.parse(params[:data]) rescue nil).is_a?(Hash) or params[:data].nil?
  end
  
end
