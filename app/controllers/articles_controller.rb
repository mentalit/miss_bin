class ArticlesController < ApplicationController
  before_action :set_article, only: %i[ show edit update destroy ]
  before_action :get_store, only: %i[ new create index import ]

  # GET /articles or /articles.json
  def index
    @articles = @store.articles
  end

  # GET /articles/1 or /articles/1.json
  def show
  end

  # GET /articles/new
  def new
    @article = @store.articles.build
  end

  # GET /articles/1/edit
  def edit
  end

  

 def import
    if params[:file].present?
      # 1. Pass @store as the second argument to match your model's expected parameters
      Article.import(params[:file], @store)
      
      # 2. Redirect back to the store show page instead of the non-existent users_path
      redirect_to store_path(@store), notice: "CSV imported successfully!"
    else
      redirect_to store_path(@store), alert: "Please upload a valid CSV file."
    end
  end

  # POST /articles or /articles.json
  def create
    @article = @store.articles.build(article_params)

    respond_to do |format|
      if @article.save
        format.html { redirect_to @article, notice: "Article was successfully created." }
        format.json { render :show, status: :created, location: @article }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @article.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /articles/1 or /articles/1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to @article, notice: "Article was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @article.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /articles/1 or /articles/1.json
  def destroy
    @article.destroy!

    respond_to do |format|
      format.html { redirect_to articles_path, notice: "Article was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    def get_store
      @store = Store.find(params[:store_id])

    end

    # Only allow a list of trusted parameters through.
    def article_params
      params.require(:article).permit(:artno, :artname, :price1, :loc_price, :slid_h, :SSD, :EDS, :store_id)
    end
end
