import Component from "@ember/component";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default Component.extend({
  tagName: "",
  name: "",
  imageUrl: "",
  saving: false,
  
  init() {
    this._super(...arguments);
    
    if (!this.model.isNew) {
      this.set("name", this.model.decoration.name);
      this.set("imageUrl", this.model.decoration.image_url);
    }
  },
  
  @action
  save() {
    if (!this.name.trim() || !this.imageUrl.trim()) {
      return;
    }
    
    this.set("saving", true);
    
    const data = {
      name: this.name,
      image_url: this.imageUrl
    };
    
    let url = "/admin/avatar_decorations";
    let method = "POST";
    
    if (!this.model.isNew) {
      url = `/admin/avatar_decorations/${this.model.decoration.id}`;
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
