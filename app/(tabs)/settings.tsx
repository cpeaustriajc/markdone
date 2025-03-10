import Head from 'expo-router/head';
import { Fragment } from 'react';
import { View, Text } from 'react-native';

export default function Index() {
    return (
        <Fragment>
            <Head>
                <title>Markdone</title>
            </Head>
            <View style={{ flex: 1 }}>
                <Text>Settings View</Text>
            </View>
        </Fragment>
    );
}
