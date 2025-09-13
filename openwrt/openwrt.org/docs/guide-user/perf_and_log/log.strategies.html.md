# Logging strategies

I suggest “the nerd” strategy.

## The ostrich

The ostrich doesn't need logs. In case something goes wrong, the ostrich prefers to not know, because that way, they are quasi innocent, because they “didn't know”. Of course in court this doesn't really matter, as the admin is responsible for any disturbance their system may cause. To avoid unnecessary breakdowns, an admin has to keep themself informed. The ostrich ignores that.

- Ignorance is bliss and has to be met with leniency.

## The beginner

The beginner logs to impress their friends and gain prestige in the community. Without much thinking they log a lot.

- Logs everything, uses the `logger` command to arbitrarily produce even more logs.
- Does not distinguish between useful or not, reads all logs and posts them online.
- After a while, stops reading their logs at all (too much to read...)
- Does not know what exactly the logs mean.
- Ignores the law, doesn't mind the *privacy* of other users your logs may breach.
  
  - Does not inform that they log, what they log and for how long logs are being kept, because it is a secret (you know, for security reasons)
  - Makes logs accessible to everyone, especially to people they do not concern (necessary breach of security to impress people in the forums)

It may look like certain people would like to introduce this strategy for logging every Internet activity in Germany. But that cannot be, as this would be stupid.

## The nerd

The nerd knows a little about the possibilities of the programs running on the systems. So, during *normal service* they create logs

- To WARN and *reads these logs regularly*
- Log messages that might prove useful to be able to reconstruct things, and *reads them only when needed*
- They act as *Data Protection Officer* and informs other users (whom it may concern) of the fact
  
  - That logs are being created and stored
  - *How long* logs are being stored
  - *Who* has access to the logs

Only during *debug sessions* they

- Log everything

## The professional

Pretty much the same as the nerd, but the professional gets paid for solving breakage fast. Some get important log warning per SMS or per pager. Day and night. Yay.
