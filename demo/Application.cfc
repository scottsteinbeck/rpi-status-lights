component{
    this.name = "lightstatus";

    function onApplicationStart(){

        var numOfLights = javacast('int',50);
        var freq = javacast('int',800000);
        var DMA = javacast('int',5);
        var pin = javacast('int',18);
        var brightness = javacast('int',200); //0-255
        var stripType = createObject("java","com.diozero.ws281xj.StripType");
        application.ledController = createObject("java","com.diozero.ws281xj.rpiws281x.WS281x").init(freq,DMA,pin,brightness,numofLights,stripType.WS2811_RGB);
    }
	
}