class MoviesController < ApplicationController

  @@movie_db = [
          {"Title"=>"The Matrix", "Year"=>"1999", "imdbID"=>"tt0133093", "Type"=>"movie"},
          {"Title"=>"The Matrix Reloaded", "Year"=>"2003", "imdbID"=>"tt0234215", "Type"=>"movie"},
          {"Title"=>"The Matrix Revolutions", "Year"=>"2003", "imdbID"=>"tt0242653", "Type"=>"movie"}]

  # route: GET    /movies(.:format)
  def index
    @movies = @@movie_db
    respond_to do |format|
      format.html
      format.json { render :json => @@movie_db }
      format.xml { render :xml => @@movie_db.to_xml }
    end
  end
  # route: # GET    /movies/:id(.:format)
  def show
    @movie = get_movie(params[:id])
    @on_show_movie_page = true
    @on_show_movie_id = params[:id]
  end

  # route: GET    /movies/new(.:format)
  def new
    # by default, calls render :new
  end

  # route: GET    /movies/:id/edit(.:format)
  def edit
    @movie = get_movie(params[:id])

  end

  #route: # POST   /movies(.:format)
  def create
    # create new movie object from params
    movie = params.require(:movie).permit(:Title, :Year)
    movie["imdbID"] = rand(10000..100000000).to_s
    # add object to movie db
    @@movie_db << movie
    # show movie page
    # render :index
    redirect_to action: :index
  end

  # route: PATCH  /movies/:id(.:format)
  def update
    # 'delete and insert'
    @@movie_db.delete_if do |m|
      m["imdbID"] == params[:id]
    end

    #create new movie
    movie = params.require(:movie).permit(:Title, :Year)
    movie['imdbID'] = params[:id]
binding.pry
    @@movie_db << movie
    redirect_to action: :index
    # go to index or show
  end

  # route: DELETE /movies/:id(.:format)
  def destroy
    @@movie_db.delete_if do |m|
      m["imdbID"] == params[:id]
    end
    redirect_to action: :index
  end

  def search
    search_title = params[:search_title]

    # if no string has been entered, do not do search
    # NOTE: doing this comparison because was getting 
    #       wierd results when using empty? or == ""
    if search_title.length > 0   
      add_imdb_movies(search_title)
    end

    redirect_to action: :index
  end

  private   # all methods below this line are private to this class

  def get_movie(movie_id)
    the_movie = @@movie_db.find do |m|
      m["imdbID"] == movie_id
    end

    if the_movie.nil?
      flash.now[:message] = "Movie not found"
      the_movie = {}
    end
    return the_movie
  end

  def add_imdb_movies (search_str)
  
    # Create a request to OMDB API, search (param is 's') for movie titles
    search_response = Typhoeus.get("www.omdbapi.com", :params => {:s => search_str})

    # store result in a hash, for better parsing
    result_hash = JSON.parse(search_response.body)

    # {"Response"=>"False", "Error"=>"Movie not found!"}
    if result_hash.empty? || result_hash.has_key?("Search") == false 
      @page_error = true
    else
      @page_error = false 
      # add found movies to psuedo db
      result_hash["Search"].each { |imdb_movie| @@movie_db << imdb_movie }
    end
  binding.pry
  end

end
