import { Text, View, StyleSheet } from 'react-native';
import {  } from 'truvideo-react-turbo-video-sdk';

const result = 3;

export default function App() {
  return (
    <View style={styles.container}>
      <Text>Result: {result}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
