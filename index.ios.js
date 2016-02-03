/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';

var React = require( 'react-native' );
var {
    AppRegistry,
    StyleSheet,
    Text,
    View,
    TouchableHighlight
    } = React;

var DroneBridge = require( 'react-native' ).NativeModules.DroneBridge;

var alchemy = require('./libs/alchemy');

console.log( "Starting Drone!" )


var parrot = React.createClass( {

    jumpHigh: function ()
    {
        DroneBridge.sendJumpHigh();
    },

    jumpLong: function ()
    {
        DroneBridge.sendJumpLong();
    },

    spin: function ()
    {
        DroneBridge.spin();
    },

    test: function()
    {
        alchemy.uploadPic();
    },

    render: function ()
    {
        return (
            <View style={styles.container}>
                <TouchableHighlight
                    onPress={this.test}
                >
                    <Text>TEST</Text>
                </TouchableHighlight>
                <TouchableHighlight
                    onPress={this.jump}
                >
                    <Text>JUMP High</Text>
                </TouchableHighlight>

                <TouchableHighlight
                    onPress={this.spin}
                >
                    <Text>SPIN</Text>
                </TouchableHighlight>

            </View>
        );
    }
} );

var styles = StyleSheet.create( {
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#F5FCFF',
    },
    welcome: {
        fontSize: 20,
        textAlign: 'center',
        margin: 10,
    },
    instructions: {
        textAlign: 'center',
        color: '#333333',
        marginBottom: 5,
    },
} );

AppRegistry.registerComponent( 'parrot', () => parrot );
