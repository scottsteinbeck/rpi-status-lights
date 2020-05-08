<cfscript>
try{
    for(i=0;i<50;i++){
        application.ledController.setPixelColourHSL(i,url.h,url.s/100,url.l/100);  
    }
    application.ledController.render();
	writeOutput('{"success":true}');
} catch (e){
	writeOutput('{"success":false}');
}
</cfscript>