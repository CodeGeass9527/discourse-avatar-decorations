import Component from "@ember/component";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default Component.extend({
  tagName: "",
  groupName: "",
  groupDescription: "",
  selectedDecorationIds: null,
  saving: false,
  
  init() {
    this._super(...arguments);
    
    if (this.model.isNew) {
      this.set("groupName", "");
      this.set("groupDescription", "");
      this.set("selectedDecorationIds", []);
    } else {
      const group = this.model.group;
      this.set("groupName", group.name);
      this.set("groupDescription", group.description || "");
      this.set("selectedDecorationIds", group.decorations.map(d => d.id));
    }
  },
  
  @action
  toggleDecoration(decorationId) {
    const ids = [...this.selectedDecorationIds];
    const index = ids.indexOf(decorationId);
    
    if (index === -1) {
      ids.push(decorationId);
    } else {
      ids.splice(index, 1);
    }
    
    this.set("selectedDecorationIds", ids);
  },
  
  @action
  save() {
    if (!this.groupName.trim()) {
      return;
    }
    
    this.set("saving", true);
    
    const data = {
      name: this.groupName,
      description: this.groupDescription,
      decoration_ids: this.selectedDecorationIds
    };
    
    let url = "/admin/avatar_decoration_groups";
    let method = "POST";
    
    if (!this.model.isNew) {
      url = `/admin/avatar_decoration_groups/${this.model.group.id}`;
      method = "PUT";
    }
    
    ajax(url, {
      type: method,
      data
    })
      .then(() => {
        this.closeModal();
      })
      .catch(popupAjaxError)
      .finally(() => {
        this.set("saving", false);
      });
  }
});
