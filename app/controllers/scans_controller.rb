# app/controllers/scans_controller.rb
class ScansController < ApplicationController
  before_action :get_store

  def index
  end

  def start
    from = Article.normalise_slid_h(params[:from])
    to   = Article.normalise_slid_h(params[:to])

    if from.nil? || to.nil?
      redirect_to store_scans_path(@store), alert: "Please enter a valid range." and return
    end

    @articles = @store.articles
                      .where(slid_h: from..to)
                      .order(:slid_h)

    if @articles.empty?
      redirect_to store_scans_path(@store), alert: "No articles found in that range." and return
    end

    session[:scan_slid_hs] = @articles.map(&:slid_h)
    session[:scan_index]   = 0
    session[:scan_errors]  = []

    redirect_to scan_store_scans_path(@store)
  end

  def scan
    slid_hs = session[:scan_slid_hs]
    index   = session[:scan_index].to_i

    if slid_hs.nil? || index >= slid_hs.length
      redirect_to results_store_scans_path(@store) and return
    end

    @slid_h  = slid_hs[index]
    @article = @store.articles.find_by(slid_h: @slid_h)
    @index   = index
    @total   = slid_hs.length
  end

  def capture
    slid_hs    = session[:scan_slid_hs]
    index      = session[:scan_index].to_i
    slid_h     = slid_hs[index]
    article    = @store.articles.find_by(slid_h: slid_h)
    base64_img = params[:image]

    unless article
      render json: { error: "Article not found for #{slid_h}" }, status: :not_found and return
    end

    unless base64_img.present?
      render json: { error: "No image received" }, status: :unprocessable_entity and return
    end

    result = CameraOcrService.scan_and_compare(article, base64_img)

    unless result[:match]
      errors = session[:scan_errors] || []
      errors << {
        slid_h:     result[:slid_h],
        artname:    result[:artname],
        expected:   result[:expected],
        detected:   result[:detected],
        confidence: result[:confidence]
      }
      session[:scan_errors] = errors
    end

    session[:scan_index] = index + 1
    done = (index + 1) >= slid_hs.length

    render json: result.merge(
      remaining: slid_hs.length - (index + 1),
      done:      done
    )
  rescue CameraOcrService::OcrError => e
    render json: { error: "OCR error: #{e.message}" }, status: :service_unavailable
  end

  def skip
    slid_hs = session[:scan_slid_hs]
    index   = session[:scan_index].to_i
    session[:scan_index] = index + 1

    if (index + 1) >= slid_hs.length
      redirect_to results_store_scans_path(@store)
    else
      redirect_to scan_store_scans_path(@store)
    end
  end

  def results
    @errors = session[:scan_errors] || []
  end

  private

  def get_store
    @store = Store.find(params[:store_id])
  end
end
