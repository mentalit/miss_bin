class StoresController < ApplicationController
  before_action :set_store, only: %i[ show edit update destroy ]
  before_action :set_store_nested, only: %i[ all_aisles aisle ]

  # GET /stores or /stores.json
  def index
    @stores = Store.all
  end

  # GET /stores/1 or /stores/1.json
  def show
  end

  # GET /stores/new
  def new
    @store = Store.new
  end

  # GET /stores/1/edit
  def edit
  end

  def all_aisles
    @articles = @store.articles
    @aisles = @articles.filter_map { |art| art.slid_h&.[](0..1) }.uniq.sort
  end

  def aisle
    @articles = @store.articles.where("slid_h LIKE ?", "#{params[:aisle]}%").order(:slid_h)
  end
  

  # POST /stores or /stores.json
  def create
    @store = Store.new(store_params)
    respond_to do |format|
      if @store.save
        format.html { redirect_to @store, notice: "Store was successfully created." }
        format.json { render :show, status: :created, location: @store }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @store.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /stores/1 or /stores/1.json
  def update
    respond_to do |format|
      if @store.update(store_params)
        format.html { redirect_to @store, notice: "Store was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @store }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @store.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /stores/1 or /stores/1.json
  def destroy
    @store.destroy!
    respond_to do |format|
      format.html { redirect_to stores_path, notice: "Store was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_store
    @store = Store.find(params[:id])
  end

  # all_aisles and aisle are nested under stores, so the param is :store_id not :id
  def set_store_nested
    @store = Store.find(params[:store_id])
  end

  def store_params
    params.require(:store).permit(:storename, :storenum)
  end
end