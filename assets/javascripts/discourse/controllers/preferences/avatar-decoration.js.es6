import Controller from "@ember/controller";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default Controller.extend({
  dialog: service(),
  
  init() {
    this._super(...arguments);
    this.set("saved", false);
    this.loadAvailableDecorations();
  },
  
  loadAvailableDecorations() {
    this.set("loading", true);
    
    ajax("/avatar-decorations/available")
      .then(result => {
        this.set("availableDecorations", result.decorations);
      })
      .catch(popupAjaxError)
      .finally(() => {
        this.set("loading", false);
      });
  },
  
  @action
  saveDecoration() {
    const user = this.model;
    const decorationId = user.get("custom_fields.selected_avatar_decoration_id") || 0;
    
    this.set("saving", true);
    this.set("saved", false);
    
    ajax(`/u/${user.username}/preferences/avatar-decoration`, {
      type: "PUT",
      data: {
        decoration_id: decorationId
      }
    })
      .then(() => {
        this.set("saved", true);
      })
      .catch(popupAjaxError)
      .finally(() => {
        this.set("saving", false);
      });
  },
  
  @action
  selectDecoration(decorationId) {
    this.model.set("custom_fields.selected_avatar_decoration_id", decorationId);
  }
});
