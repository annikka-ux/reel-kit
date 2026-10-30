"""Beats for the demo video (make_demo.sh). Copy this file for each new video and rewrite build().
Rules: every graphic enters on the word it shows and leaves when the speaker moves on; a visual change
every 2-3 s; nothing decorative that the speaker isn't saying; never cover the face (keep cards in the
lower-middle band, chips at the sides). at('word', after) looks up the word's start time in WORDS.json."""


def build(g):
    at = g.at
    # "not failing because of TALENT. They are failing because of ORDER."
    g.old_vs_new('b1', at('Your'), at('Same') - 0.1, 'Talent', at('talent'), at('They'), 'Order', at('order'))
    # "Same people, same tools, but THREE things changed."
    g.big_number('b2', at('Same'), at('Answer') - 0.05, ['= Same people', '= Same tools'],
                 [at('people'), at('tools')], '3', at('three'), 'things changed')
    # the three points, each lands on its own words
    p2, p3 = at('Pause'), at('End')
    g.point('p1', at('Answer'), p2 - 0.05, 1, 'Answer first')
    g.point('p2', p2, p3 - 0.05, 2, 'Pause, don’t fill')
    g.point('p3', p3, at('Your', p3) - 0.05, 3, 'End down, not up')
    # "can I stop worrying?" as a chat
    g.chat('b3', at('Your', p3), g.BASE, 'Can I stop worrying?', at('stop', p3) - 0.3, '✓ Yes. It’s handled.', at('worrying') + 0.4)
