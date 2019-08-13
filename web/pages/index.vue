<template>
<div class="container">
	<light :red="red" :green="green" :yellow="yellow" @toggle="toggle" />
</div>
</template>

<script>
import Light from '~/components/Light.vue'

export default {
	data: function () {
		return {
			red: true,
			green: false,
			yellow: false
		}
	},
	methods: {
		async refresh() {
			const data = await this.$axios.$get('/state')
			this.red = data.red
			this.green = data.green
			this.yellow = data.yellow
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
			}
			this.$axios.$post('/state', {
				red: this.red,
				green: this.green,
				yellow: this.yellow,
			}).then(data => {
				this.red = data.red
				this.green = data.green
				this.yellow = data.yellow
			})
		}
	},
	mounted: function() {
		this.refresh()
	},
	components: {
		Light
	}
}
</script>

<style>
.container {
margin: 0 auto;
min-height: 100vh;
display: flex;
}

.title {
font-family: 'Quicksand', 'Source Sans Pro', -apple-system, BlinkMacSystemFont,
'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
display: block;
font-weight: 300;
font-size: 100px;
color: #35495e;
letter-spacing: 1px;
}

.subtitle {
font-weight: 300;
font-size: 42px;
color: #526488;
word-spacing: 5px;
padding-bottom: 15px;
}

.links {
padding-top: 15px;
}
</style>
