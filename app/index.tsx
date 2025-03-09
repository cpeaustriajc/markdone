import { View } from 'react-native';
import { MarkdownTextInput } from '@expensify/react-native-live-markdown';
import { useState } from 'react';

export default function Index() {
    const [text, setText] = useState('Hello, WOrld!');

    return (
        <View
            style={{
                flex: 1,
            }}
        >
            <MarkdownTextInput
                multiline
                value={text}
                onChangeText={setText}
                style={{
                    borderWidth: 0,
                }}
                placeholder="Start writing here..."
            />
        </View>
    );
}
