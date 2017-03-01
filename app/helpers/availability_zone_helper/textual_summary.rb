module AvailabilityZoneHelper::TextualSummary
  include TextualMixins::TextualEmsCloud
  include TextualMixins::TextualGroupTags
  #
  # Groups
  #

  def textual_group_relationships
    TextualGroup.new(_("Relationships"), %i(ems_cloud instances cloud_volumes))
  end

  def textual_group_availability_zone_totals
    TextualGroup.new(_("Totals for Availability Zone"), %i(block_storage_disk_capacity block_storage_disk_usage))
  end

  #
  # Items
  #

  def textual_cloud_volumes
    label = ui_lookup(:tables => "cloud_volume")
    num   = @record.number_of(:cloud_volumes)
    h     = {:label => label, :icon => "pficon pficon-volume", :value => num}
    if num > 0 && role_allows?(:feature => "cloud_volume_show_list")
      h[:link]  = url_for_only_path(:action => 'show', :id => @record, :display => 'cloud_volumes')
      h[:title] = _("Show all %{label}") % {:label => label}
    end
    h
  end

  def textual_instances
    label = ui_lookup(:tables => "vm_cloud")
    num   = @record.number_of(:vms)
    h     = {:label => label, :icon => "pficon pficon-virtual-machine", :value => num}
    if num > 0 && role_allows?(:feature => "vm_show_list")
      h[:link]  = url_for_only_path(:action => 'show', :id => @record, :display => 'instances')
      h[:title] = _("Show all %{label}") % {:label => label}
    end
    h
  end

  def textual_block_storage_disk_capacity
    return nil unless @record.respond_to?(:block_storage_disk_capacity) && !@record.ext_management_system.provider.nil?
    {:value => number_to_human_size(@record.block_storage_disk_capacity.gigabytes, :precision => 2)}
  end

  def textual_block_storage_disk_usage
    return nil unless @record.respond_to?(:block_storage_disk_usage)
    {:value => number_to_human_size(@record.block_storage_disk_usage.bytes, :precision => 2)}
  end
end
