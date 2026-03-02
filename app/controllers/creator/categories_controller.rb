module Creator
  class CategoriesController < ApplicationController
    before_action :authenticate_author!

    def new
      @category = Category.new
    end

    def create
      @category = Category.new(category_params)

      if @category.save
        redirect_to author_dashboard_path, notice: "Category created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def category_params
      params.require(:category).permit(:name)
    end
  end
end
