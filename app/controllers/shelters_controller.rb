class SheltersController < ApplicationController
  def index
    @shelters = Shelter.all
  end

  def show
    @shelter = Shelter.find(params[:shelter_id])
    @reviews = @shelter.reviews
  end

  def new
  end

  def create
    shelter = Shelter.new(shelter_info)
    if shelter.save
      flash[:notice] = "Succesfully created #{shelter.name}!"
      redirect_to '/shelters'
    else
      flash.now[:notice] = "The following fields are missing: #{grab_empty_keys} "
      render :new
    end
  end

  def edit
    @shelter = Shelter.find(params[:shelter_id])
  end

  def update
    shelter = Shelter.find(params[:shelter_id])
    if shelter.update(shelter_info)
      flash[:notice] = "Succesfully updated #{shelter.name}!"
      redirect_to "/shelters/#{shelter.id}"
    else
      flash[:notice] = "The following fields are missing: #{grab_empty_keys} "
      redirect_to "/shelters/#{shelter.id}/edit"
    end
  end

  def destroy
    shelter = Shelter.find(params[:shelter_id])

    if shelter.pets.pets_pending?
      flash[:notice] = 'Unable to delete shelter due to pending pet approval'
      redirect_to "/shelters/#{shelter.id}"
    else
      shelter.reviews.delete_associated_reviews
      shelter.pets.remove_select_pets_from_db(shelter.pets)
      shelter.destroy
      flash[:notice] = "Successfully deleted shelter and it's pets"
      redirect_to '/shelters'
    end
  end

  private
  def shelter_info
    params.permit(:name, :address, :city, :state, :zip)
  end

  def grab_empty_keys
    keys = []
    params.each do |key, value|
      if value.empty?
        keys << key
      end
    end
    keys
  end
end
