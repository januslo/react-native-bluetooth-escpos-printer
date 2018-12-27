import React, {Component} from 'react';
import {View,StatusBar} from 'react-native';
import NavigationExperimental  from 'react-native-deprecated-custom-components';
import Home from "./home";

export default class App extends Component {
    _navigator = null;
    constructor(props) {
        super(props);
    }
    componentDidMount() {

    }

    renderScene(route, navigator) {
        this._navigator = navigator;
        let Component = route.component;
        return <View style={{flex:1}}><StatusBar backgroundColor="lightblue" /><Component route={route} navigator={navigator} {...route.passProps}/></View>
    }

    render() {
        return (
            <NavigationExperimental.Navigator
                style={{flex: 1}}
                initialRoute={{component: Home}}
                configureScene={() => { return NavigationExperimental.Navigator.SceneConfigs.FloatFromRight; }}
                renderScene={this.renderScene}
            />
        );
    }
}
