ActiveAdmin.register User do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

actions :index, :destroy

# filter :from_chn_id, as: :select, collection: Channel.where(opened: true).map { |c| [c.name, c.id] }
# filter :mobile
# filter :name
# filter :idcard
# filter :bank_no
# filter :bank_mobile
# filter :bank_info
# filter :created_at

# scope :authed, default: true
# scope :unauthed
# scope :all

index do
  selectable_column
  column('#',:id)
  column :uid, sortable: false
  column :mobile, sortable: false
  # column :name, sortable: false
  # column :idcard, sortable: false
  # column '注册渠道' do |o|
  #   o.channel.try(:name)
  # end
  column :created_at
  # column '银行信息' do |o|
  #   raw("银行卡号: #{o.bank_no}<br>银行预留手机: #{o.bank_mobile}<br>开卡信息: #{o.bank_info}")
  # end
  # column :private_token, sortable: false
  column :verified, sortable: false
  actions defaults: false do |o|
    # item '查看'
    if o.verified
      item "禁用", block_admin_user_path(o), method: :put, data: { confirm: '你确定吗？' }, class: 'danger'
    else
      item "启用", unblock_admin_user_path(o), method: :put, data: { confirm: '你确定吗？' }
    end
    item "删除", admin_user_path(o), method: :delete, data: { confirm: '你确定吗？' }
  end
end

# 禁用账户
batch_action :block do |ids|
  batch_action_collection.find(ids).each do |o|
    o.block!
  end
  redirect_to collection_path, alert: "已禁用"
end
member_action :block, method: :put do
  resource.block!
  redirect_to collection_path, notice: '禁用成功'
end

# 启用账户
batch_action :unblock do |ids|
  batch_action_collection.find(ids).each do |o|
    o.unblock!
  end
  redirect_to collection_path, alert: "已启用"
end
member_action :unblock, method: :put do
  resource.unblock!
  redirect_to collection_path, notice: '启用成功'
end


end
