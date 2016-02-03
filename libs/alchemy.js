/**
 * Created by patrickcremin on 1/22/16.
 */


var Alchemy = function()
{
    var _host = "http://bob0101.mybluemix.net/";

    this.uploadPic = function()
    {
        this.get("http://bob0101.mybluemix.net/" );
    };

    this.get = function ( requestUrl, callback )
    {
        //var accessToken = this.getAccessToken();

        return fetch( requestUrl)
            .then( ( response ) =>
            {
                response.text().then( function ( text )
                {
                    var json = text != '' ? JSON.parse( text ) : {};

                    callback( json, response.status );
                } );

                response.json().then( function ( xx )
                {
                    console.log( xx )
                } )
            } )
            .catch( ( error ) =>
            {
                console.log( "SPOTIFY GET ERROR: " + error );
            } );
    };

    this.post = function ( requestUrl, body, callback )
    {
        //var accessToken = this.getAccessToken();
        return fetch( requestUrl, {
            method: 'POST',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
            },
            body: JSON.stringify( body )
        } )
            .then( ( response ) =>
            {
                return response.json()
            } )
            .then( ( responseJson ) =>
            {
                callback && callback( responseJson )
            } )
            .catch( ( error ) =>
            {
                console.warn( error );
            } );
    };

    this.put = function ( requestUrl, body, callback )
    {
        //var accessToken = this.getAccessToken();

        return fetch( requestUrl, {
            method: 'PUT',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + accessToken
            },
            body: JSON.stringify( body )
        } )
            .then( ( response ) =>
            {
                callback(null, response.status);
            } )
            .catch( ( error ) =>
            {
                callback(error);
                console.log( "SPOTIFY PUT ERROR: " + error );
            } );
    };
};


module.exports = new Alchemy();