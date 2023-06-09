<template>
  <v-dialog v-model="dialog" @click:outside="dialog = false"  max-width="60%">
    <template v-slot:activator="{ on }">
      <v-icon
        v-if="icon"
        small
        class="mr-2"
        v-on="on"
      >
        mdi-delete
      </v-icon>
      <v-btn v-if="!displayIcon" color="primary" dark class="mt-2" v-on="on">{{$t("deleteApiKey.deleteApiKey")}}</v-btn>
    </template>

    <v-card class="pt-1 pb-3 px-2">
      <v-card-title>
        <span class="headline text-h3">{{$t('deleteApiKey.deleteTitle')}}</span>
      </v-card-title>   
      <v-card-text>
        <error-banner :message="errorMessage"></error-banner>
        <v-row>
          <v-col :cols="12">
              <v-alert type="warning">
                {{$t('deleteApiKey.deleteWarning')}}
              </v-alert>
          </v-col>
        </v-row>
      </v-card-text>

      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn color="blue darken-1" text @click="dialog = false">{{$t("deleteApiKey.cancel")}}</v-btn>
        <v-btn color="red darken-1" text @click="deleteApiKey">
          <span>{{$t("deleteApiKey.delete")}}</span>
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script lang="ts">
import {Component, Prop, Vue} from 'vue-property-decorator'
import {KeyPairT} from "@/api/types";

@Component
export default class DeleteApiKeyDialog extends Vue {
  @Prop({required: false})
  containerID?: string

  @Prop({required: false})
  serviceUserID?: string

  @Prop({required: true})
  readonly keyPair!: KeyPairT

  @Prop({required: false, default: false})
  readonly icon!: boolean

  errorMessage = ""
  dialog = false

  get displayIcon() {
    return this.icon
  }

  deleteApiKey() {
    if(this.serviceUserID) {
      this.$client.deleteKeyPairForServiceUser(this.containerID!, this.serviceUserID, this.keyPair.key)
          .then(() => {
            this.dialog = false
            this.$emit('apiKeyDeleted')
          })
          .catch(e => this.errorMessage = e)
    } else {
      this.$client.deleteKeyPairForUser(this.keyPair.key)
          .then(() => {
            this.dialog = false
            this.$emit('apiKeyDeleted')
          })
          .catch(e => this.errorMessage = e)
    }
  }

}
</script>