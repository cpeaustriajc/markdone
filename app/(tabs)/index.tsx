import { View, TextInput } from 'react-native';
import Head from 'expo-router/head';
import { Fragment, useState } from 'react';

export default function Index() {
    const [text, setText] = useState<string>('');

    return (
        <Fragment>
            <Head>
                <title>Markdone</title>
            </Head>
            <View style={{ flex: 1 }}>
                <TextInput
                    onChangeText={setText}
                    value={text}
                />
            </View>
        </Fragment>
    );
}
