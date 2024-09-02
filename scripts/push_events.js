import { Kafka } from '../src/node_modules/kafkajs/types';

// Create a new Kafka instance
const kafka = new Kafka({
    clientId: 'my-producer',
    brokers: ['localhost:29092']
});
const producer = kafka.producer();

async function run(start, end) {
    await producer.connect();
    console.log('Kafka producer connected.');

    // Predefined status sequence
    const statusSequence = ['received', 'preparing', 'cooked', 'delivered', 'finished'];

    const orderStatusMap = {};
    let id=0;

    const generateMessage = (orderId) => {
        const lastStatus = orderStatusMap[orderId];
        const nextStatusIndex = lastStatus ? statusSequence.indexOf(lastStatus) + 1 : 0;
        const nextStatus = statusSequence[nextStatusIndex] || statusSequence[0]; // Reset to first status if finished

        orderStatusMap[orderId] = nextStatus;

        id++;
        return {
            id:id,
            order_id: orderId,
            status: nextStatus,
            updated_at: Math.floor(Date.now() / 1000) 
        };
    };

    const getNextOrderId = () => {
        let orderId;
        do {
            orderId = start + Math.floor(Math.random() * (end - start));
        } while (orderStatusMap[orderId] === 'finished'); 
        return orderId;
    };

    setInterval(async () => {
        const orderId = getNextOrderId();
        const message = generateMessage(orderId);

        try {
            await producer.send({
                topic: 'order_updates', 
                messages: [
                    { value: JSON.stringify(message) }
                ]
            });
            console.log(`Message sent: ${JSON.stringify(message)}`);
        } catch (error) {
            console.error('Error sending message:', error);
        }

        if (orderStatusMap[orderId] === 'finished') {
            delete orderStatusMap[orderId];
        }
    }, 1000);
}



(async function () {
    try {
        var args = process.argv.slice(2);
        run(+args[0],+args[1]).catch(console.error);
    } catch (err) {
        console.error("Error inserting data: ", err);
    }
})();