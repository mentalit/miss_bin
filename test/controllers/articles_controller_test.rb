require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article = articles(:one)
  end

  test "should get index" do
    get articles_url
    assert_response :success
  end

  test "should get new" do
    get new_article_url
    assert_response :success
  end

  test "should create article" do
    assert_difference("Article.count") do
      post articles_url, params: { article: { EDS: @article.EDS, SSD: @article.SSD, artname: @article.artname, artno: @article.artno, loc_price: @article.loc_price, price1: @article.price1, slid_h: @article.slid_h, store_id: @article.store_id } }
    end

    assert_redirected_to article_url(Article.last)
  end

  test "should show article" do
    get article_url(@article)
    assert_response :success
  end

  test "should get edit" do
    get edit_article_url(@article)
    assert_response :success
  end

  test "should update article" do
    patch article_url(@article), params: { article: { EDS: @article.EDS, SSD: @article.SSD, artname: @article.artname, artno: @article.artno, loc_price: @article.loc_price, price1: @article.price1, slid_h: @article.slid_h, store_id: @article.store_id } }
    assert_redirected_to article_url(@article)
  end

  test "should destroy article" do
    assert_difference("Article.count", -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_url
  end
end
