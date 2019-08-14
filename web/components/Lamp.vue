<template>
	<div :class="{ 'on': value }" @click="$emit('toggle','lamp')" class="lamp">
		<div class="lamp-wrap">
			<div class="fancy-bulb">
				<div class="left-streaks streaks"></div>
				<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
				viewBox="0 0 275.3 413.3" enable-background="new 0 0 275.3 413.3" xml:space="preserve">
					<g id="off">
						<path fill="#E2ECF1" d="M137.7,13.7C67.2,13.7,10,70.9,10,141.4c0,58.3,72.8,118.2,79.9,162.3h47.8h47.8
					c7.1-44,79.9-103.9,79.9-162.3C265.3,70.9,208.2,13.7,137.7,13.7z"/>
					</g>
					<g id="on">
						<path fill="#FFDB55" d="M137.7,13.7C67.2,13.7,10,70.9,10,141.4c0,58.3,72.8,118.2,79.9,162.3h47.8h47.8
					c7.1-44,79.9-103.9,79.9-162.3C265.3,70.9,208.2,13.7,137.7,13.7z"/>
					</g>

					<g id="outline">
						<path fill="#F1F2F2" stroke="#38434A" stroke-width="19.1022" stroke-miterlimit="10" d="M168.5,375.5h-61.7c-8.9,0-16-7.2-16-16
					v-55.8h93.8v55.8C184.6,368.3,177.4,375.5,168.5,375.5z"/>
						<path fill="#F1F2F2" stroke="#38434A" stroke-width="19.1022" stroke-miterlimit="10" d="M151.2,401.5h-27.1c-3.9,0-7-3.2-7-7v-19
					h41.1v19C158.2,398.4,155.1,401.5,151.2,401.5z"/>
						<line fill="none" stroke="#38434A" stroke-width="19.1022" stroke-miterlimit="10" x1="184.6" y1="339.6" x2="90.8" y2="339.6"/>
						<path fill="none" stroke="#38434A" stroke-width="19.1022" stroke-miterlimit="10" d="M137.7,13.7C67.2,13.7,10,70.9,10,141.4
					c0,58.3,72.8,118.2,79.9,162.3h47.8h47.8c7.1-44,79.9-103.9,79.9-162.3C265.3,70.9,208.2,13.7,137.7,13.7z"/>
					</g>
					<g id="highlight">
						<path fill="#FFDB55" stroke="#FFFFFF" stroke-width="21.0124" stroke-linecap="round" stroke-miterlimit="10" d="M207.1,89.5
					c-12.3-16.1-28.4-29.1-46.9-37.8"/>
						<path fill="#FFDB55" stroke="#FFFFFF" stroke-width="21.0124" stroke-linecap="round" stroke-miterlimit="10" d="M225,121.4
					c-0.8-2.2-1.8-4.4-2.7-6.5"/>
					</g>
				</svg>
				<div class="right-streaks streaks"></div>
			</div>
		</div>
	</div>
</template>

<style>
:root {
	--button-font-size: 1.9em;

	--bulb-width: 80px;
	--bulb-height: 80px;
	--bulb-color: lighten(crimson,5%);
	--bulb-font-size: 1.9em;

	--light-color: #FFDB55;
	--streak-vert-space: 30px; /*vertical spacing between streaks*/
	--streak-horizontal-offset: 5px; /*initial offset*/
	--streak-distance: 40px; /*distance moved by streaks*/
	--streak-stagger: 15px; /*distance between center and edge streaks*/

	--streak-rotation:34deg;
	--streak-height:4px;
	--streak-width: 35px;

	--speed:0.38s;
	--timing-function:ease-out;
	--animation-delay: 0.14s;
};

.lamp {
	/* from gist */
	background: darken(#E2ECF1,15%);
 	transition: all var(--animation-delay) ease-in;
}

.lamp.on {
	background: lighten(#E2ECF1,5%);
}

.lamp-wrap {
  width: var(--bulb-width);
}

#on {
  -webkit-transform: translate(50%, 50%) scale(0);
          transform: translate(50%, 50%) scale(0);
  opacity: 0;
}
.lamp.on #on {
  opacity: 1;
  -webkit-transform: translate(0) scale(1);
          transform: translate(0) scale(1);
  transition: all var(--animation-delay) ease-in;
}

.fancy-bulb {
  position: relative;
}

.streaks, .streaks:after, .streaks:before {
  position: absolute;
  background: var(--light-color);
  border-radius: calc(var(--streak-height)/2);
  height: var(--streak-height);
}

.streaks:after, .streaks:before {
  content: "";
  display: block;
}

.streaks:before {
  bottom: var(--streak-vert-space);
}

.streaks:after {
  top: var(--streak-vert-space);
}

.left-streaks {
  right: calc(var(--bulb-width) + var(--streak-horizontal-offset));
  top: calc((var(--bulb-height)/2)-(var(--streak-height)/2));
}
.lamp.on .left-streaks {
  -webkit-animation: move-left var(--speed) var(--timing-function), width-to-zero var(--speed) var(--timing-function);
          animation: move-left var(--speed) var(--timing-function), width-to-zero var(--speed) var(--timing-function);
  -webkit-animation-delay: var(--animation-delay);
          animation-delay: var(--animation-delay);
}
.left-streaks:before, .left-streaks:after {
  left: var(--streak-stagger);
}
.lamp.on .left-streaks:before {
  -webkit-animation: width-to-zero var(--speed) var(--timing-function), move-up var(--speed) var(--timing-function);
          animation: width-to-zero var(--speed) var(--timing-function), move-up var(--speed) var(--timing-function);
  -webkit-animation-delay: var(--animation-delay);
          animation-delay: var(--animation-delay);
}
.lamp.on .left-streaks:after {
  -webkit-animation: width-to-zero var(--speed) var(--timing-function), move-down var(--speed) var(--timing-function);
          animation: width-to-zero var(--speed) var(--timing-function), move-down var(--speed) var(--timing-function);
  -webkit-animation-delay: var(--animation-delay);
          animation-delay: var(--animation-delay);
}

.right-streaks {
  left: calc(var(--bulb-width) + var(--streak-horizontal-offset));
  top: calc((var(--bulb-height)/2)-(var(--streak-height)/2));
}
.lamp.on .right-streaks {
  -webkit-animation: move-right var(--speed) var(--timing-function), width-to-zero var(--speed) var(--timing-function);
          animation: move-right var(--speed) var(--timing-function), width-to-zero var(--speed) var(--timing-function);
  -webkit-animation-delay: var(--animation-delay);
          animation-delay: var(--animation-delay);
}
.right-streaks:before, .right-streaks:after {
  right: var(--streak-stagger);
}
.lamp.on .right-streaks:before {
  -webkit-animation: width-to-zero var(--speed) var(--timing-function), move-up var(--speed) var(--timing-function);
          animation: width-to-zero var(--speed) var(--timing-function), move-up var(--speed) var(--timing-function);
  -webkit-animation-delay: var(--animation-delay);
          animation-delay: var(--animation-delay);
}
.lamp.on .right-streaks:after {
  -webkit-animation: width-to-zero var(--speed) var(--timing-function), move-down var(--speed) var(--timing-function);
          animation: width-to-zero var(--speed) var(--timing-function), move-down var(--speed) var(--timing-function);
  -webkit-animation-delay: var(--animation-delay);
          animation-delay: var(--animation-delay);
}

.left-streaks:before, .right-streaks:after {
  -webkit-transform: rotate(var(--streak-rotation));
          transform: rotate(var(--streak-rotation));
}

.left-streaks:after, .right-streaks:before {
  -webkit-transform: rotate(calc(-1*var(--streak-rotation)));
          transform: rotate(calc(-1*var(--streak-rotation)));
}

@-webkit-keyframes move-left {
  0% {
    -webkit-transform: none;
            transform: none;
  }
  65% {
    -webkit-transform: translateX(calc(-1*var(--streak-distance)));
            transform: translateX(calc(-1*var(--streak-distance)));
  }
  100% {
    -webkit-transform: translateX(calc(-1*var(--streak-distance)));
            transform: translateX(calc(-1*var(--streak-distance)));
  }
}

@keyframes move-left {
  0% {
    -webkit-transform: none;
            transform: none;
  }
  65% {
    -webkit-transform: translateX(calc(-1*var(--streak-distance)));
            transform: translateX(calc(-1*var(--streak-distance)));
  }
  100% {
    -webkit-transform: translateX(calc(-1*var(--streak-distance)));
            transform: translateX(calc(-1*var(--streak-distance)));
  }
}
@-webkit-keyframes move-right {
  0% {
    -webkit-transform: none;
            transform: none;
  }
  65% {
    -webkit-transform: translateX(var(--streak-distance));
            transform: translateX(var(--streak-distance));
  }
  100% {
    -webkit-transform: translateX(var(--streak-distance));
            transform: translateX(var(--streak-distance));
  }
}
@keyframes move-right {
  0% {
    -webkit-transform: none;
            transform: none;
  }
  65% {
    -webkit-transform: translateX(var(--streak-distance));
            transform: translateX(var(--streak-distance));
  }
  100% {
    -webkit-transform: translateX(var(--streak-distance));
            transform: translateX(var(--streak-distance));
  }
}
@-webkit-keyframes width-to-zero {
  0% {
    width: var(--streak-width);
  }
  100% {
    width: var(--streak-height);
  }
}
@keyframes width-to-zero {
  0% {
    width: var(--streak-width);
  }
  100% {
    width: var(--streak-height);
  }
}
@-webkit-keyframes move-up {
  100% {
    bottom: calc(var(--streak-vert-space)*1.55);
  }
}
@keyframes move-up {
  100% {
    bottom: calc(var(--streak-vert-space)*1.55);
  }
}
@-webkit-keyframes move-down {
  100% {
    top: calc(var(--streak-vert-space)*1.55);
  }
}
@keyframes move-down {
  100% {
    top: calc(var(--streak-vert-space)*1.55);
  }
}


</style>

<script>
export default {
	props: ["value"]
}
</script>