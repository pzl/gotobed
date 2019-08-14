<template>
<div class="container">
	<light :red="red" :green="green" :yellow="yellow" @toggle="toggle" />
	<lamp :value="lamp" @toggle="toggle" />
</div>
</template>

<script>
import Light from '~/components/Light.vue'
import Lamp from '~/components/Lamp.vue'

export default {
	data: function () {
		return {
			red: true,
			green: false,
			yellow: false,
			lamp: false,
			repeat: null,
		}
	},
	methods: {
		async refresh() {
			const data = await this.$axios.$get('/state')
			this.red = data.red
			this.green = data.green
			this.yellow = data.yellow
			this.lamp = data.lamp
		},
		toggle(light) {
			switch (light) {
				case 'red':
					this.red = !this.red
					break
				case 'green':
					this.green = !this.green
					break
				case 'yellow':
					this.yellow = !this.yellow
					break
				case 'lamp':
					this.lamp = !this.lamp
					break
			}
			this.$axios.$post('/state', {
				red: this.red,
				green: this.green,
				yellow: this.yellow,
				lamp: this.lamp,
			}).then(data => {
				this.red = data.red
				this.green = data.green
				this.yellow = data.yellow
				this.lamp = data.lamp
			})
		}
	},
	mounted: function() {
		this.refresh()
		this.repeat = setInterval(()=>{
			this.refresh()
		}, 60*1000)
	},
	beforeDestroy: function() {
		clearInterval(this.repeat)
	},
	components: {
		Light, Lamp
	}
}
</script>

<style>
.container {
	display: flex;
	align-items: center;
}

.container .traffic-light {
	margin-right: 40px;
}


</style>
