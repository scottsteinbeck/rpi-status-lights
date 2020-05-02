component {


    function run(){
        classLoad( '/home/pi/Desktop/lightStatus/lib/diozero-ws281x-java-0.11.jar' );
        var numOfLights = javacast('int',50);
        var freq = javacast('int',800000);
        var DMA = javacast('int',5);
        var pin = javacast('int',18);
        var brightness = javacast('int',200); //0-255
        var stripType = createObject("java","com.diozero.ws281xj.StripType");
        var ledController = createObject("java","com.diozero.ws281xj.rpiws281x.WS281x").init(freq,DMA,pin,brightness,numofLights,stripType.WS2811_RGB);
        var hueStart = 1;
        while( true ) {
            for(var led = 0; led < 50; led++){
                var setColor = hueStart + (led * 7);
                if(setColor > 360) setColor = setColor % 360;
                print.line("#led#,#setColor#,.4,.3").toConsole();
                ledController.setPixelColourHSL(led,setColor,.7,.5);
            }
            hueStart = hueStart + 5;
            if(hueStart > 360) hueStart = hueStart % 360;
            ledController.render()
            sleep(100);

        }
    }

}