import { View } from 'react-native';
import Head from 'expo-router/head';
import { MarkdownTextInput } from '@expensify/react-native-live-markdown';
import { Fragment, useState } from 'react';

export default function Index() {
    const [text, setText] = useState<string>('');

    return (
        <Fragment>
            <Head>
                <title>Markdone</title>
            </Head>
            <View style={{ flex: 1 }}>
                <MarkdownTextInput
                    multiline
                    value={text}
                    onChangeText={setText}
                    style={{
                        padding: 8,
                        borderWidth: 0,
                    }}
                    placeholder="Start writing here..."
                />
            </View>
        </Fragment>
    );
}
