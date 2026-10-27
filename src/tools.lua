

SMODS.ConsumableType({
    key = "cloverpit_tool",
    primary_colour = HEX('c32a2a'),
    secondary_colour = HEX('902e2e'),
    collection_rows = {4, 5},
    shop_rate = 2,
    loc_txt = {
        ["name"] = 'Tools',
        ["collection"] = 'Tools'
    }
})


------------------------------------------------------------


SMODS.Consumable {
    key = 'crowbar',
    atlas = 'tool',
    set = 'cloverpit_tool',
    pos = { x = 0, y = 0 },
    config = { extra = { cost = 0 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.cost } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('cloverpit_crowbar')
                card:juice_up(0.3, 0.5)
                G.GAME.current_round.reroll_cost = card.ability.extra.cost
                return true
            end
        }))
        delay(0.6)
    end,
    can_use = function(self, card)
        return G.shop
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'lost_briefcase',
    atlas = 'tool',
    set = 'cloverpit_tool',
    pos = { x = 1, y = 0 },
    config = { extra = { decrease = 30 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.decrease } }
    end,
    use = function(self, card, area, copier)
        local used_card = copier or card
        if G.GAME.blind.in_blind then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    play_sound('cloverpit_lost_briefcase')
                    card:juice_up(0.3, 0.5)
                    card_eval_status_text(used_card, 'extra', nil, nil, nil, {message = "-"..tostring(card.ability.extra.decrease).."% Blind Size", colour = G.C.GREEN})
                    G.GAME.blind.chips = G.GAME.blind.chips * (100 - card.ability.extra.decrease) / 100
                    G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                    G.HUD_blind:recalculate()
                    return true
            end
        }))
        delay(0.6)
        end
    end,
    can_use = function(self, card)
        return (G.GAME.blind.in_blind)
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'fortune_cookie',
    atlas = 'tool',
    set = 'cloverpit_tool',
    pos = { x = 2, y = 0 },
    config = { extra = { tags = 1 } },
    use = function(self, card, area, copier)
        local used_card = copier or card
        local tag = Tag(get_next_tag_key("fortune_cookie"))
        -- local tag = Tag("tag_cloverpit_phone_tag")
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('cloverpit_fortune_cookie')
                card:juice_up(0.3, 0.5)
                card_eval_status_text(used_card, 'extra', nil, nil, nil, {message = "Added tag!", colour = G.C.GREEN})
                if tag.name == "Orbital Tag" then
                    local _poker_hands = {}
                    for k, v in pairs(G.GAME.hands) do
                        if v.visible then
                            _poker_hands[#_poker_hands + 1] = k
                        end
                    end
                    tag.ability.orbital_hand = pseudorandom_element(_poker_hands, pseudoseed("fortune_cookie_hand"))
                end
                add_tag(tag)
                return true
            end
        }))
    end,        
    can_use = function(self, card)
        return true
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'music_tape',
    atlas = 'tool',
    set = 'cloverpit_tool',
    pos = { x = 3, y = 0 },
    config = { extra = { hand = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.hand } }
    end,
    use = function(self, card, area, copier)
        local used_card = copier or card
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('cloverpit_tape')
                card:juice_up(0.3, 0.5)
                card_eval_status_text(used_card, 'extra', nil, nil, nil, {message = "+"..tostring(1).." Hands", colour = G.C.GREEN})
                G.GAME.current_round.hands_left = G.GAME.current_round.hands_left + card.ability.extra.hand
                return true
            end
        }))
        delay(0.6)
    end,
    can_use = function(self, card)
        return (G.GAME.blind.in_blind)
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'clover_voucher',
    atlas = 'tool',
    set = 'cloverpit_tool',
    pos = { x = 4, y = 0 },
    config = { extra = { money = 8 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('cloverpit_clover_voucher')
                card:juice_up(0.3, 0.5)
                ease_dollars(card.ability.extra.money, true)
                return true
            end
        }))
        delay(0.6)
    end,
    can_use = function(self, card)
        return true
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'car_battery',
    atlas = 'tool',
    set = 'cloverpit_tool',
    pos = { x = 5, y = 0 },
    config = {  },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        for _, joker in ipairs(G.jokers.cards) do
            if joker.config.center.chargeable then
                joker.ability.extra.current_charge = joker.ability.extra.charge
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_car_battery')
                        return true
                    end
                }))
                card_eval_status_text(joker, 'extra', nil, nil, nil, {message = "Charged!", colour = G.C.BLUE})
            end
        end
    end,
    can_use = function(self, card)
        return true
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'cigarettes',
    atlas = 'tool',
    set = 'cloverpit_tool',
    pos = { x = 6, y = 0 },
    config = { extra = { odds = 4, blind_percent = 20 } },
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'cigarettes')
        return { vars = { numerator, denominator, card.ability.extra.blind_percent } }
    end,
    use = function(self, card, area, copier)
        local used_card = copier or card

        if SMODS.pseudorandom_probability(card, 'cigarettes', 1, card.ability.extra.odds) then
            local card_front = pseudorandom_element(G.P_CARDS, pseudoseed('cigarettes'))
            local base_card = create_playing_card({
                front = card_front,
                center = G.P_CENTERS.c_base
            }, G.discard, true, false, nil, true)
            
            
            base_card:set_edition(pseudorandom_element({'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                    'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome'}, pseudoseed('cigarettes')), true)
            
            G.playing_card = (G.playing_card and G.playing_card + 1) or 1
            local new_card = copy_card(base_card, nil, nil, G.playing_card)
            
            new_card:add_to_deck()
            
            G.deck.config.card_limit = G.deck.config.card_limit + 1
            G.deck:emplace(new_card)
            table.insert(G.playing_cards, new_card)
            
            base_card:remove()
            
            G.E_MANAGER:add_event(Event({
                func = function() 
                    new_card:start_materialize()
                    play_sound('cloverpit_cigarettes')
                    return true
                end
            }))
        else 
                        
            card_eval_status_text(used_card, 'extra', nil, nil, nil, {message = localize('k_nope_ex'), colour = G.C.GREEN})
            G.GAME.blind.chips = G.GAME.blind.chips * (1 + card.ability.extra.blind_percent/100)
            G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            G.HUD_blind:recalculate()

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    if G.consumeables.config.card_limit > #G.consumeables.cards + G.GAME.consumeable_buffer then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    end
                    play_sound('cloverpit_cigarettes')
                    local new_copy = SMODS.add_card({ set = 'tool', key = 'c_cloverpit_cigarettes'})
                    new_copy.ability.extra.odds = used_card.ability.extra.odds - 1                            
                    used_card:juice_up(0.3, 0.5)
                    return true
                end
            }))
            

        end
    end,
    can_use = function(self, card)
        return (G.GAME.blind.in_blind)
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'photo_book',
    atlas = 'tool',
    set = 'cloverpit_tool',
    pos = { x = 7, y = 0 },
    config = { extra = {  } },
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        local used_card = copier or card

        local card_front = pseudorandom_element(G.P_CARDS, pseudoseed('photo_book'))
        local base_card = create_playing_card({
            front = card_front,
            center = G.P_CENTERS.c_base
        }, G.discard, true, false, nil, true)
        
        
        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
        local new_card = copy_card(base_card, nil, nil, G.playing_card)
        play_sound('cloverpit_photo_book')
        
        new_card:add_to_deck()
        
        G.deck.config.card_limit = G.deck.config.card_limit + 1
        G.deck:emplace(new_card)
        table.insert(G.playing_cards, new_card)
        
        base_card:remove()
        
        G.E_MANAGER:add_event(Event({
            func = function() 
                new_card:start_materialize()
                return true
            end
        }))

    end,
    can_use = function(self, card)
        return true
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'wolf',
    atlas = 'tool',
    set = 'cloverpit_tool',
    pos = { x = 8, y = 0 },
    config = { max_highlighted = 1, mod_conv = 'm_cloverpit_devilish' },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted, localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end
}