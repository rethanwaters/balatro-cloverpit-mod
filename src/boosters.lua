SMODS.Booster {
    key = "telephone1",
    weight = 3,
    kind = 'phone', 
    cost = 2,
    pos = { x = 0, y = 0 },
    atlas = 'booster',
    config = { extra = 3, choose = 1 },
    draw_hand = true,
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra }
        }
    end,

    ease_background_colour = function(self)
        ease_background_colour_blind(G.STATES.TAROT_PACK)
    end,

    create_card = function(self, card, i)
        if i == 1 then 
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('cloverpit_phone_booster_open')
                    return true
                end
            }))
        end
        local _card = {
            set = 'cloverpit_phone',
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true
        }
        return _card
    end
}


------------------------------------------------------


SMODS.Booster {
    key = "telephone2",
    weight = 1,
    kind = 'phone', 
    cost = 6,
    pos = { x = 1, y = 0 },
    atlas = 'booster',
    config = { extra = 5, choose = 1 },
    draw_hand = true,
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra }
        }
    end,

    ease_background_colour = function(self)
        ease_background_colour_blind(G.STATES.TAROT_PACK)
    end,

    create_card = function(self, card, i)
        if i == 1 then 
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('cloverpit_phone_booster_open')
                    return true
                end
            }))
        end
        local _card = {
            set = 'cloverpit_phone',
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true
        }
        return _card
    end
}


------------------------------------------------------


SMODS.Booster {
    key = "telephone3",
    weight = 0.25,
    kind = 'phone', 
    cost = 8,
    pos = { x = 2, y = 0 },
    atlas = 'booster',
    config = { extra = 5, choose = 2 },
    draw_hand = true,
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra }
        }
    end,

    ease_background_colour = function(self)
        ease_background_colour_blind(G.STATES.TAROT_PACK)
    end,

    create_card = function(self, card, i)
        if i == 1 then 
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('cloverpit_phone_booster_open')
                    return true
                end
            }))
        end
        local _card = {
            set = 'cloverpit_phone',
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true
        }
        return _card
    end
}