const mqtt = require('mqtt');
const { Kafka, logLevel } = require('kafkajs');

const mqttClient = mqtt.connect('mqtt://localhost:1883', {
  // username: 'mqttuser',
  // password: '',
  // rejectUnauthorized: false,
});

const mqtt = require('mqtt');


const kafka = new Kafka({
  clientId: 'kafka-producer-local',
  brokers: ['localhost:9092'],
  // ssl: true,
  // sasl: {
  //   mechanism: 'scram-sha-512', username: '',
  //   password: '',
  // },
  logLevel: logLevel.INFO,
});


mqttClient.on('connect', () => {
  console.log('Connected to MQTT broker');
  mqttClient.subscribe('#');
});
const producer = kafka.producer();

producer.connect().then(() => {
  console.log('Kafka is ready');
}).catch((err) => {
  console.error('Kafka connection error:', err);
})

mqttClient.on('message', (topic, message) => {
  let payload;
  try {
    payload = JSON.parse(message.toString());
  } catch (e) {
    payload = { data: message.toString() };
  }
  payload.receivedAt = new Date().toISOString();
  // console.log(payload);
  producer.send({ topic: 'kafka-topic', messages: [ { value: JSON.stringify(payload) }] }).then(() => {
  }).catch((err) => {
      if (err) console.error('Kafka error:', err);
  });
});
