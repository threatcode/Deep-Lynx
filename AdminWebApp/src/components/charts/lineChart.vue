<template>
  <h1>UNIMPLEMENTED</h1>
</template>

<script lang="ts">
import {Component, Prop, Vue } from "vue-property-decorator";
// @ts-ignore

@Component({components: {}})
export default class LineChart extends Vue {
  @Prop({required: true})
  x!: (d: any) => any

  @Prop({required: true})
  y!: ((d: any) => any)[]

  @Prop({required: true})
  labels!: string[]

  @Prop({required: true})
  data!: {[key: string]: any}[]
  change = 0

  layout = {
    width: document.documentElement.clientWidth - 200 ,
    height: document.documentElement.clientHeight - 400
  }

  getData() {
   return this.y.map((yfunc, index) => {
     return {
       x: this.data.map(this.x),
       y: this.data.map(yfunc),
       name: this.labels[index],
       type: "scatter"
     }
   })
  }
}
</script>