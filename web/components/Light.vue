<template>
	<div class="traffic-light">
		<div :class="{ 'on':red }" class="bulb red" @click="$emit('toggle','red')" />
		<div :class="{ 'on':yellow }" class="bulb yellow" @click="$emit('toggle','yellow')" />
		<div :class="{ 'on':green }" class="bulb green" @click="$emit('toggle','green')" />
	</div>
</template>

<style>

.traffic-light {
	background-color: orange;
	width: 100px;
	height: 200px;
	display: flex;
	flex-direction: column;
	justify-content: space-around;
	align-items: center;
}

.bulb {
	height: 40px;
	width: 40px;
	border-radius: 100%;
	opacity: 0.4;
}

.bulb.red {
	background-color: red;
}
.bulb.green {
	background-color: green;
}
.bulb.yellow {
	background-color: yellow;
}

.bulb.on {
	opacity: 1;
}

</style>

<script>
export default {
	props: ["red","green","yellow"],
}
</script>