class TreeBuilderBelongsToHac < TreeBuilder
  has_kids_for Datacenter, [:x_get_tree_datacenter_kids]
  has_kids_for EmsCluster, [:x_get_tree_cluster_kids]
  has_kids_for EmsFolder, [:x_get_tree_folder_kids]
  has_kids_for ExtManagementSystem, [:x_get_provider_kids]
  has_kids_for ResourcePool, [:x_get_resource_pool_kids]

  def override(node, object, _pid, options)
    if [ExtManagementSystem, EmsCluster, Datacenter, EmsFolder, ResourcePool].any? { |klass| object.kind_of?(klass) }
      node[:select] = options.key?(:selected) && options[:selected].include?("#{object.class.name}_#{object[:id]}")
    end
    node[:hideCheckbox] = true if object.kind_of?(Host) && object.ems_cluster_id.present?
    node[:selectable] = false
    node[:checkable] = options[:checkable_checkboxes] if options.key?(:checkable_checkboxes)
  end

  def initialize(name, type, sandbox, build, params)
    @edit = params[:edit]
    @group = params[:group]
    @selected = params[:selected]
    # need to remove tree info
    TreeState.new(sandbox).remove_tree(name)
    super(name, type, sandbox, build)
  end

  private

  def tree_init_options(_tree_name)
    {:full_ids             => true,
     :add_root             => false,
     :lazy                 => false,
     :checkable_checkboxes => @edit.present?,
     :selected             => @selected}
  end

  def set_locals_for_render
    locals = super
    locals.merge!(:check_url         => "/ops/rbac_group_field_changed/#{group_id}___",
                  :oncheck           => @edit ? "miqOnCheckUserFilters" : nil,
                  :checkboxes        => true,
                  :highlight_changes => true,
                  :onclick           => false)
  end

  def root_options
    {}
  end

  def x_get_tree_roots(count_only, _options)
    count_only_or_objects(count_only, ExtManagementSystem.all)
  end

  def x_get_provider_kids(parent, count_only)
    kids = []
    parent.children.each do |child|
      # this node (child) is not added to a tree
      kids.concat(child.folders_only)
      kids.concat(child.datacenters_only)
    end
    count_only_or_objects(count_only, kids)
  end

  def x_get_tree_datacenter_kids(parent, count_only)
    kids = []
    parent.folders.each do |child|
      kids.concat([child]) if child.kind_of?(EmsFolder) && child.name == 'datastore'
      next unless child.kind_of?(EmsFolder) && child.name == "host"
      kids.concat(child.folders_only)
      kids.concat(child.clusters)
      kids.concat(child.hosts)
    end
    count_only_or_objects(count_only, kids)
  end

  def x_get_tree_cluster_kids(parent, count_only)
    count_only_or_objects(count_only, parent.hosts) + count_only_or_objects(count_only, parent.resource_pools)
  end

  def x_get_resource_pool_kids(parent, count_only)
    count_only_or_objects(count_only, parent.is_default? ? parent.resource_pools : [])
  end

  def x_get_tree_folder_kids(parent, count_only = false)
    count_only_or_objects(count_only, parent.folders_only) +
      count_only_or_objects(count_only, parent.datacenters_only) +
      count_only_or_objects(count_only, parent.clusters) +
      count_only_or_objects(count_only, parent.hosts)
  end
end
