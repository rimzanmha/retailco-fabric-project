"""
RetailCo Live Event Generator  (Module 12 - Real-Time Analytics)
-----------------------------------------------------------------
Pushes synthetic retail clickstream/order events to a Microsoft Fabric
Eventstream "Custom Endpoint" (Event Hub-compatible) so participants can
see data land in an Eventhouse / KQL DB in real time.

USAGE
-----
1. In Fabric: create an Eventstream -> add source "Custom Endpoint" ->
   copy the Event Hub-compatible CONNECTION STRING and EVENT HUB NAME.
2. pip install azure-eventhub
3. Set the two env vars below (or paste inline) and run:
       python live_event_generator.py
   Each second it sends a small batch of events. Ctrl-C to stop.

If you don't want to stream live, you can instead upload
'realtime_events_sample.jsonl' directly as a one-off file source.
"""
import os, json, random, time, datetime as dt

# ---- CONFIG: paste your Eventstream custom-endpoint values here -------------
CONN_STR = os.getenv("FABRIC_EVENTSTREAM_CONN", "<PASTE_CONNECTION_STRING>")
HUB_NAME = os.getenv("FABRIC_EVENTSTREAM_HUB",  "<PASTE_EVENTHUB_NAME>")
EVENTS_PER_SECOND = 5
# -----------------------------------------------------------------------------

CATEGORIES = ["Electronics","Home","Apparel","Grocery","Beauty"]
EVENT_TYPES = ["page_view","add_to_cart","checkout","purchase","search"]

def make_event(i):
    cat = random.choice(CATEGORIES)
    etype = random.choices(EVENT_TYPES, weights=[40,20,10,10,20])[0]
    return {
        "event_id": f"evt-live-{int(time.time())}-{i}",
        "event_time": dt.datetime.utcnow().isoformat(),
        "event_type": etype,
        "customer_id": random.randint(1,200),
        "product_id": random.randint(101,127),
        "category": cat,
        "channel": random.choice(["Online","App"]),
        "amount": round(random.uniform(149,18999),2) if etype=="purchase" else 0,
    }

def main():
    try:
        from azure.eventhub import EventHubProducerClient, EventData
    except ImportError:
        raise SystemExit("Run: pip install azure-eventhub")

    if "<PASTE" in CONN_STR:
        raise SystemExit("Set CONN_STR and HUB_NAME first (see header).")

    producer = EventHubProducerClient.from_connection_string(CONN_STR, eventhub_name=HUB_NAME)
    print("Streaming events... Ctrl-C to stop.")
    i = 0
    with producer:
        while True:
            batch = producer.create_batch()
            for _ in range(EVENTS_PER_SECOND):
                i += 1
                batch.add(EventData(json.dumps(make_event(i))))
            producer.send_batch(batch)
            print(f"sent {EVENTS_PER_SECOND} events (total {i})")
            time.sleep(1)

if __name__ == "__main__":
    main()
