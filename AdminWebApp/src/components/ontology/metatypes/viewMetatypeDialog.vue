<template>
  <v-dialog v-model="dialog" @click:outside="dialog = false" max-width="60%">
    <template v-slot:activator="{ on }">
      <v-icon
          small
          class="mr-2"
          v-on="on"
      >mdi-eye</v-icon>
    </template>

    <v-card class="pt-1 pb-3 px-2" v-if="selectedMetatype">
      <v-card-title>
        <span class="headline text-h3">{{selectedMetatype.name}}</span>
      </v-card-title>   
      <v-card-text>
        <error-banner :message="errorMessage"></error-banner>
        <v-row>    
          <v-col :cols="12">
            <v-form
                ref="form"
                v-model="valid"
            >
              <v-text-field
                  v-model="selectedMetatype.name"
                  :rules="[v => !!v || $t('editMetatype.nameRequired')]"
                  required
                  :disabled="true"
                  class="disabled"
              >
                <template v-slot:label>{{$t('editMetatype.name')}}</template>
              </v-text-field>
              <v-textarea
                  v-model="selectedMetatype.description"
                  :rules="[v => !!v || $t('editMetatype.descriptionRequired')]"
                  required
                  :disabled="true"
                  class="disabled"
              >
                <template v-slot:label>{{$t('editMetatype.description')}} </template>
              </v-textarea>
            </v-form>
          </v-col>

          <v-col :cols="12" v-if="keysLoading">
            <v-progress-linear indeterminate></v-progress-linear>
          </v-col>
          <v-col :cols="12">
            <v-data-table
                :headers="headers()"
                :items="selectedMetatype.keys"
                :items-per-page="100"
                :footer-props="{
                    'items-per-page-options': [25, 50, 100]
                }"
                class="elevation-1"
                sort-by="name"
            >

              <template v-slot:top>
                <v-toolbar flat color="white">
                  <v-toolbar-title>{{$t("viewMetatype.keys")}}</v-toolbar-title>
                  <v-divider
                      class="mx-4"
                      inset
                      vertical
                  ></v-divider>
                  <v-spacer></v-spacer>
                </v-toolbar>
              </template>
              <template v-slot:[`item.actions`]="{ item }">
                <view-metatype-key-dialog :metatypeKey="item" :metatype="metatype" :icon="true"></view-metatype-key-dialog>
              </template>
            </v-data-table>
          </v-col>
        </v-row>
      </v-card-text>

      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn color="blue darken-1" text @click="dialog = false" >{{$t("viewMetatype.close")}}</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script lang="ts">
import {Component, Prop, Watch, Vue} from 'vue-property-decorator'
import {MetatypeT} from "../../../api/types";
import ViewMetatypeKeyDialog from "@/components/ontology/metatypes/viewMetatypeKeyDialog.vue";

@Component({components: {
    ViewMetatypeKeyDialog
  }})
export default class ViewMetatypeDialog extends Vue {
  @Prop({required: true})
  metatype!: MetatypeT;

  errorMessage = ""
  keysLoading = false
  dialog = false
  selectedMetatype: MetatypeT | null  = null
  valid = false

  // this way we only load the keys when the edit dialog is open, so we don't
  // overload someone using this in a list
  @Watch('dialog', {immediate: true})
  isDialogOpen() {
    if(this.dialog) {
      this.loadKeys()
    }
  }

  headers() {
    return  [
      { text: this.$t('viewMetatype.keyName'), value: 'name', sortable: false },
      { text: this.$t('viewMetatype.keyDescription'), value: 'description', sortable: false},
      { text: this.$t('viewMetatype.keyType'), value: 'data_type', sortable: false},
      { text: this.$t('viewMetatype.actions'), value: 'actions', sortable: false }
    ]
  }

  mounted() {
    // have to do this to avoid mutating properties
    this.selectedMetatype = JSON.parse(JSON.stringify(this.metatype))
  }

  loadKeys() {
    if(this.selectedMetatype) {
      this.keysLoading = true
      this.$client.listMetatypeKeys(this.selectedMetatype.container_id, this.selectedMetatype.id!)
          .then(keys => {
            if(this.selectedMetatype) {
              this.selectedMetatype.keys = keys
              this.keysLoading = false
              this.$forceUpdate()
            }
          })
          .catch(e => {
            this.errorMessage = e
            this.keysLoading = false
          })
    }
  }
}

</script>

<style lang="scss">
.disabled input {
  color: black !important;
}

.disabled textarea {
  color: black !important;
}

.disabled .v-select__selection{
  color: black !important;
}

.edited-field {
  input {
    background: #CD7F32;
    color: white !important;
    box-shadow: -5px 0 0 #CD7F32;
  }

  textarea {
    background: #CD7F32;
    color: white !important;
    box-shadow: -5px 0 0 #CD7F32;
  }

  .v-select__slot {
    background: #CD7F32;
    color: white !important;
    box-shadow: -5px 0 0 #CD7F32;
  }

  .v-select__selection {
    background: #CD7F32;
    color: white !important;
    box-shadow: -5px 0 0 #CD7F32;
  }
}
</style>