import { Kafka } from 'kafkajs';

// Create a new Kafka instance
const kafka = new Kafka({
    clientId: 'my-producer',
    brokers: ['localhost:29092']
});
// Create a Kafka producer
const producer = kafka.producer();

async function run(start,end) {
    // Connect the producer
    await producer.connect();
    console.log('Kafka producer connected.');

    // Function to generate a message
    let id=1;
    const generateMessage = () => {
        id++;
        return {
            id: id,
            order_id:  start + Math.floor(Math.random() * (end-start)),
            status: 'cooked', // Static status for the example
            updated_at: Math.floor(Date.now() / 1000) // Current timestamp in seconds
        };
    };

    // Send a message every second
    setInterval(async () => {
        const message = generateMessage();
        try {
            await producer.send({
                topic: 'order_updates', // Replace with your Kafka topic name
                messages: [
                    { value: JSON.stringify(message) }
                ]
            });
            console.log(`Message sent: ${JSON.stringify(message)}`);
        } catch (error) {
            console.error('Error sending message:', error);
        }
    }, 5000);
}



(async function () {
    try {
        var args = process.argv.slice(2);
        run(+args[0],+args[1]).catch(console.error);
    } catch (err) {
        console.error("Error inserting data: ", err);
    }
})();