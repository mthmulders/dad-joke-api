package jokes

import (
	"math/rand"
	"time"
)

var jokes [14]string
var seed int64

func init() {
	if len(jokes[0]) != 0 {
		return
	}

	rand.Seed(time.Now().UTC().UnixNano())

	jokes[0] = "My sweater had a lot of static electricity. The store gave me a new one, free of charge."
	jokes[1] = "There was a man that couldn't see that well, so he fell into it."
	jokes[2] = "How does Bono spell \"Color\"? With or without u?"
	jokes[3] = "A man sued an airline after it lost his luggage. Sadly, he lost his case."
	jokes[4] = "What's the fastest growing city on earth? The capital of Ireland, it's Dublin every day."
	jokes[5] = "My friend didn't understand cloning. That makes two of us."
	jokes[6] = "If you put your left shoe on the wrong foot, it's on the right foot."
	jokes[7] = "I tried to organize a Hide and Seek tournament, but I eventually gave up. Good players are hard to find."
	jokes[8] = "Why do programmers prefer dark mode? Because light attracts bugs."
	jokes[9] = "Why did the hipster burn his mouth? He drank the coffee before it was cool."
	jokes[10] = "Why do programmers always mix up Christmas and Halloween? Because Dec 25 is Oct 31."
	jokes[11] = "If I had 50 cents for every time I failed a math test, I'd have € 7.20 right now."
	jokes[12] = "Scientists studied the earth's rotation. After 24 hours, they called it a day."
	jokes[13] = "I got arrested for downloading the whole of Wikipedia. I said: \"Wait, I can explain everything!\""
}

// GetRandomJoke returns a pseudo-random joke from the collection.
func GetRandomJoke() string {
	idx := rand.Intn(len(jokes))
	return jokes[idx]
}
