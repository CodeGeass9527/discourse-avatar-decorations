import Component from "@ember/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default Component.extend({
  dialog: service(),
  
  tagName: "",
  selectedUsers: null,
  loading: false,
  searchTerm: "",
  searchResults: null,
  
  init() {
    this._super(...arguments);
    this.set("selectedUsers", []);
    this.loadCurrentUsers();
  },
  
  loadCurrentUsers() {
    this.set("loading", true);
    
    ajax(`/admin/avatar_decoration_groups/${this.model.group.id}/users`)
      .then(result => {
        this.set("currentUsers", result.users);
      })
      .catch(popupAjaxError)
      .finally(() => {
        this.set("loading", false);
      });
  },
  
  @action
  searchUsers() {
    if (this.searchTerm.length < 2) {
      this.set("searchResults", null);
      return;
    }
    
    ajax("/u/search/users", {
      data: { term: this.searchTerm }
    })
      .then(result => {
        this.set("searchResults", result.users);
      })
      .catch(popupAjaxError);
  },
  
  @action
  selectUser(user) {
    if (!this.selectedUsers.find(u => u.id === user.id)) {
      this.selectedUsers.push(user);
    }
    this.set("searchTerm", "");
    this.set("searchResults", null);
  },
  
  @action
  removeSelectedUser(user) {
    this.set("selectedUsers", this.selectedUsers.filter(u => u.id !== user.id));
  },
  
  @action
  addUsers() {
    if (this.selectedUsers.length === 0) return;
    
    this.set("adding", true);
    
    ajax(`/admin/avatar_decoration_groups/${this.model.group.id}/add_users`, {
      type: "POST",
      data: {
        user_ids: this.selectedUsers.map(u => u.id)
      }
    })
      .then(() => {
        this.set("selectedUsers", []);
        this.loadCurrentUsers();
      })
      .catch(popupAjaxError)
      .finally(() => {
        this.set("adding", false);
      });
  },
  
  @action
  removeUser(user) {
    this.dialog.confirm({
      message: I18n.t("avatar_decorations.admin.confirm_remove_user", { username: user.username }),
      didConfirm: () => {
        ajax(`/admin/avatar_decoration_groups/${this.model.group.id}/remove_user/${user.id}`, {
          type: "DELETE"
        })
          .then(() => {
            this.loadCurrentUsers();
          })
          .catch(popupAjaxError);
      }
    });
  }
});
