<template>
	<div class="traffic-light">
		<div :class="{ 'on':red }" class="bulb red" @click="$emit('toggle','red')" />
		<div :class="{ 'on':yellow }" class="bulb yellow" @click="$emit('toggle','yellow')" />
		<div :class="{ 'on':green }" class="bulb green" @click="$emit('toggle','green')" />
	</div>
</template>

<style>
.traffic-light {
	background-color: #333;
	width: 100px;
	height: 250px;
	display: flex;
	flex-direction: column;
	justify-content: space-around;
	align-items: center;
	border-radius: 15px;
	margin: 10px;
	padding: 5px;
}

.bulb {
	height: 55px;
	width: 55px;
	border-radius: 100%;
	opacity: 0.15;
}

.bulb.on {
	opacity: 1;
}

.bulb.red {
	background-color: #b30000;
}
.bulb.green {
	background-color: #00b300;
}
.bulb.yellow {
	background-color: #b2b300;
}

.bulb.on.red {
	background-color: #ff0000;
	box-shadow: 0 0 6em #ff3333;
}

.bulb.on.yellow {
	background-color: #ffff00;
	box-shadow: 0 0 6em #ffff33;
}
.bulb.on.green {
	background-color: #00ff00;
	box-shadow: 0 0 6em #33ff33;
}

</style>

<script>
export default {
	props: ["red","green","yellow"],
}
</script>