<html>

<head>
	<meta name="viewport" content="width=device-width">

	<script src="https://cdn.jsdelivr.net/npm/@jaames/iro/dist/iro.min.js"></script>
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>

</head>

<body>
	<div class="colorPicker"></div>
	<div id="values"></div>
	<script>


		$(function () {

			var colorPicker = new iro.ColorPicker(".colorPicker", {
				width: 280,
				color: "rgb(255, 0, 0)",
				borderWidth: 1,
				borderColor: "#fff",
			});

			var values = document.getElementById("values");
			var changing = false;

			function getRandRange(min, max) {
				min = Math.ceil(min);
				max = Math.floor(max);
				return Math.floor(Math.random() * (max - min)) + min; //The maximum is exclusive and the minimum is inclusive
			}

			function setRandomStatus() {
				if (changing == false) {
					changing = true;

					$.get("ledColorChange.cfm", { i: getRandRange(0, 49), h: getRandRange(0, 360), s: getRandRange(50, 100), l: 30 }, function (data) {
						changing = false;
					})
				}
				setTimeout(setRandomStatus, 50);
			}
			setRandomStatus();

			// https://iro.js.org/guide.html#color-picker-events
			colorPicker.on(["color:change"], function (color) {
				console.log(changing);
				// Show the current color in different formats
				// Using the selected color: https://iro.js.org/guide.html#selected-color-api
				values.innerHTML = [
					"hex: " + color.hexString,
					"rgb: " + color.rgbString,
					"hsl: " + color.hslString,
				].join("<br>");
				if (changing == false) {
					changing = true;
					$.get("colorChange.cfm", { h: color.hsl.h, s: color.hsl.s, l: color.hsl.l }, function (data) {
						changing = false;
					})
				}

			});
		})
	</script>
</body>

</html>