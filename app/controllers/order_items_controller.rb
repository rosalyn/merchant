class OrderItemsController < ApplicationController
  before_filter :set_order_item, only: [:show, :edit, :update, :destroy]
  before_filter :load_order, only: [:create]

  # GET /order_items/1/edit
  def edit
  end

  # POST /order_items
  # POST /order_items.json
  def create
    @order_item = @order.order_items.find_or_initialize_by_product_id(product_id: params[:product_id])
    @order_item.quantity += 1

    respond_to do |format|
      if @order_item.save
        format.html { redirect_to @order, notice: 'Successfully added product to cart' }
        format.json { render action: @order_item, status: :created, location: @order_item }
      else
        format.html { render action: "new" }
        format.json { render json: @order_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /order_items/1
  # PATCH/PUT /order_items/1.json
  def update
    respond_to do |format|
      if order_item_params[:quantity].to_i == 0
        @order_item.destroy
        format.html { redirect_to @order_item.order, notice: 'Item was deleted from your cart.' }
        format.json { head :no_content }
      elsif @order_item.update_attributes(order_item_params)
        format.html { redirect_to @order_item.order, notice: 'Successfully updated the order item.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @order_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /order_items/1
  # DELETE /order_items/1.json
  def destroy
    @order_item.destroy

    respond_to do |format|
      format.html { redirect_to @order_item.order }
      format.json { head :no_content }
    end
  end

  private

    def set_order_item
      @order_item = OrderItem.find(params[:id])
    end

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def order_item_params
      params.require(:order_item).permit(:order_id, :product_id, :quantity)
    end

    def load_order
      @order = Order.find_or_initialize_by_id(session[:order_id], user_id: session[:user_id], status: "unsubmitted")
      if @order.new_record?
        @order.save!
        session[:order_id] = @order.id
      end
    end
end
