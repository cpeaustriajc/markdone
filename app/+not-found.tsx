import { Link, Stack } from 'expo-router';
import Head from 'expo-router/head';
import { Fragment } from 'react';
import { View, Text } from 'react-native';

export default function NotFoundScreen() {
    return (
        <Fragment>
            <Head>
                <title>Not Found</title>
            </Head>
            <Stack.Screen options={{ title: 'Oops!' }} />
            <View>
                <Text>This screen doesn't exist.</Text>
                <Link href="/">
                    <Text>Go to home screen!</Text>
                </Link>
            </View>
        </Fragment>
    );
}
