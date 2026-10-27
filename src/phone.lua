SMODS.ConsumableType({
    key = "cloverpit_phone",
    primary_colour = HEX('2a2ac3'),
    secondary_colour = HEX('2e2e90'),
    collection_rows = {4, 4},
    shop_rate = 0,
    loc_txt = {
        ["name"] = 'Phone Calls',
        ["collection"] = 'Phone Calls'
    }
})

SMODS.Atlas({key = 'tool', path = 'CustomConsumables.png', px = 71, py = 95})


------------------------------------------------------------


SMODS.Consumable {
    key = 'throw_my_stuff',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 0, y = 0 },
    config = {mod_edition = 'e_negative' },
    
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
        return { vars = { G.GAME.ecto_minus or 1 } }
    end,

    use = function(self, card, area, copier)
        local editionless_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                local eligible_card = pseudorandom_element(editionless_jokers, 'throw_my_stuff')
                eligible_card:set_edition({ negative = true })

                local _first_dissolve = nil
                for _, joker in pairs(G.jokers.cards) do
                    if joker ~= eligible_card and not SMODS.is_eternal(joker, card) then
                        joker:start_dissolve(nil, _first_dissolve)
                        _first_dissolve = true
                    end
                end

                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
                return true
            end
        }))
    end,
    can_use = function(self, card)
        return next(SMODS.Edition:get_edition_cards(G.jokers, true))
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'cant_quit_now',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 1, y = 0 },
    config = { extra = {levels = 4} },
    
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.levels } }
    end,

    use = function(self, card, area, copier)

        local temp_played = 0
        local temp_order = math.huge
        local target_hand = 'High Card'
        for hand, value in pairs(G.GAME.hands) do 
            if value.played > temp_played and value.visible then
                temp_played = value.played
                temp_order = value.order
                target_hand = hand
            elseif value.played == temp_played and value.visible then
                if value.order < temp_order then
                    temp_order = value.order
                    target_hand = hand
                end
            end
        end

        update_hand_text({ sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3 },
            { handname = localize(target_hand, 'poker_hands'), chips = G.GAME.hands[target_hand].chips, 
                mult = G.GAME.hands[target_hand].mult, level = G.GAME.hands[target_hand].level })
        local old_chips = G.GAME.hands[target_hand].chips
        local old_mult = G.GAME.hands[target_hand].mult
        level_up_hand(card, target_hand, true, card.ability.extra.levels)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.8, 0.5)
                G.TAROT_INTERRUPT_PULSE = true
                return true
            end
        }))
        update_hand_text({ delay = 0 }, { mult = '+'..tostring(G.GAME.hands[target_hand].mult - old_mult), StatusText = true })
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.9,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.8, 0.5)
                return true
            end
        }))
        update_hand_text({ delay = 0 }, { chips = '+'..tostring(G.GAME.hands[target_hand].chips - old_chips), StatusText = true })
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.9,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.8, 0.5)
                G.TAROT_INTERRUPT_PULSE = nil
                return true
            end
        }))
        update_hand_text({ sound = 'button', volume = 0.7, pitch = 0.9, delay = 0 }, { level = '+'..tostring(card.ability.extra.levels) })
        delay(1.3)
        
        update_hand_text({ sound = 'button', volume = 0.7, pitch = 1.1, delay = 0 },
            { handname = localize(target_hand, 'poker_hands'), chips = G.GAME.hands[target_hand].chips, 
                mult = G.GAME.hands[target_hand].mult, level = G.GAME.hands[target_hand].level })
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
                return true
            end
        }))
        delay(1)
        -- update_hand_text({ sound = 'button', volume = 0.7, pitch = 1.1, delay = 0 },
        --     { mult = 0, chips = 0, handname = '', level = '' })
    end,

    can_use = function(self, card)
        return true
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'borrow_some_green',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 2, y = 0 },
    config = { extra = { money_mult = 7, reward = 0 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money_mult } }
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        local deletable_jokers = {}
        
        for _, joker in pairs(G.jokers.cards) do
            if joker.ability.set == 'Joker' and not SMODS.is_eternal(joker, card) then
                deletable_jokers[#deletable_jokers + 1] = joker
            end
        end
        
        if #deletable_jokers > 0 then
            local temp_jokers = {}
            for _, joker in ipairs(deletable_jokers) do 
                temp_jokers[#temp_jokers + 1] = joker 
            end
            
            pseudoshuffle(temp_jokers, 42)
            joker_to_destroy = temp_jokers[1]
            card.ability.extra.reward = card.ability.extra.money_mult * joker_to_destroy.sell_cost
        end
        
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                card:juice_up(0.3, 0.5)
                card_eval_status_text(used_card, 'extra', nil, nil, nil, {message = "+"..tostring(card.ability.extra.reward).." $", colour = G.C.MONEY})
                ease_dollars(card.ability.extra.reward, true)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                used_card:juice_up(0.3, 0.5)
                return true
            end
        }))
        
        G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.75,
            func = function()
                joker_to_destroy:start_dissolve(nil, nil)
                return true
            end
        }))
        delay(0.6)
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
                return true
            end
        }))
    end,

    can_use = function(self, card)
        local deletable_jokers = {}
        for _, joker in pairs(G.jokers.cards) do
            if joker.ability.set == 'Joker' and not SMODS.is_eternal(joker, card) then
                deletable_jokers[#deletable_jokers + 1] = joker
            end
        end
        return #deletable_jokers > 0
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'eat_something',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 3, y = 0 },
    config = { extra = { tag1 = "tag_coupon", tag2 = "tag_d_six" } },
    
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.tag1, card.ability.extra.tag2 } }
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        local tag1 = Tag(card.ability.extra.tag1)
        local tag2 = Tag(card.ability.extra.tag2)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                card:juice_up(0.3, 0.5)
                -- card_eval_status_text(used_card, 'extra', nil, nil, nil, {message = "Added tag!", colour = G.C.GREEN})
                add_tag(tag1)
                add_tag(tag2)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
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
    key = 'energy_drinks',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 4, y = 0 },
    config = { extra = { decrease = 1 } },
    
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        return { vars = {card.ability.extra.decrease} }
    end,

    use = function(self, card, area, copier)
        for _, joker in ipairs(G.jokers.cards) do
            if joker.config.center.chargeable then
                if joker.ability.extra.charge > 1 then 
                    joker.ability.extra.charge = joker.ability.extra.charge - card.ability.extra.decrease
                    if joker.ability.extra.charge < joker.ability.extra.current_charge then
                        joker.ability.extra.current_charge = joker.ability.extra.charge
                    end
                    card_eval_status_text(joker, 'extra', nil, nil, nil, {message = "Improved!", colour = G.C.BLUE})
                end
            end
        end
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
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
    key = 'betting_on_green',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 5, y = 0 },
    config = {mod_edition = 'e_cloverpit_florid' },
    
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_edition]
        return { vars = {"Florid", localize { type = 'name_text', set = 'Edition', key = card.ability.mod_edition } } }
    end,

    use = function(self, card, area, copier)
        local editionless_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)
        local eligible_card = pseudorandom_element(editionless_jokers, 'florid')
        local edition = SMODS.poll_edition { key = "florid", guaranteed = true, no_negative = true, options = { card.ability.mod_edition } }
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                eligible_card:set_edition(edition, true)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return next(SMODS.Edition:get_edition_cards(G.jokers, true))
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'betting_on_yellow',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 6, y = 0 },
    config = {mod_edition = 'e_cloverpit_avid' },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_edition]
        return { vars = {"Avid", localize { type = 'name_text', set = 'Edition', key = card.ability.mod_edition } } }
    end,

    use = function(self, card, area, copier)
        local editionless_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)
        local eligible_card = pseudorandom_element(editionless_jokers, 'avid')
        local edition = SMODS.poll_edition { key = "avid", guaranteed = true, no_negative = true, options = { card.ability.mod_edition } }
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                eligible_card:set_edition(edition, true)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return next(SMODS.Edition:get_edition_cards(G.jokers, true))
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'betting_on_orange',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 7, y = 0 },
    config = {mod_edition = 'e_cloverpit_ambitious' },
    
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_edition]
        return { vars = {"Ambitious", localize { type = 'name_text', set = 'Edition', key = card.ability.mod_edition } } }
    end,

    use = function(self, card, area, copier)
        local editionless_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)
        local eligible_card = pseudorandom_element(editionless_jokers, 'ambitious')
        local edition = SMODS.poll_edition { key = "ambitious", guaranteed = true, no_negative = true, options = { card.ability.mod_edition } }
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                eligible_card:set_edition(edition, true)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return next(SMODS.Edition:get_edition_cards(G.jokers, true))
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'patterns_will_align',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 8, y = 0 },
    config = {mod_edition = 'e_cloverpit_obsessive' },
    
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_edition]
        return { vars = {"Obsessive", localize { type = 'name_text', set = 'Edition', key = card.ability.mod_edition } } }
    end,

    use = function(self, card, area, copier)
        local editionless_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)
        local eligible_card = pseudorandom_element(editionless_jokers, 'obsessive')
        local edition = SMODS.poll_edition { key = "obsessive", guaranteed = true, no_negative = true, options = { card.ability.mod_edition } }
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                eligible_card:set_edition(edition, true)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return next(SMODS.Edition:get_edition_cards(G.jokers, true))
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'kinda_fun',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 9, y = 0 },
    config = {mod_edition = 'e_cloverpit_gambler' },
    
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_edition]
        return { vars = {"Gambler", localize { type = 'name_text', set = 'Edition', key = card.ability.mod_edition } } }
    end,

    use = function(self, card, area, copier)
        local editionless_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)
        local eligible_card = pseudorandom_element(editionless_jokers, 'gambler')
        local edition = SMODS.poll_edition { key = "gambler", guaranteed = true, no_negative = true, options = { card.ability.mod_edition } }
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                eligible_card:set_edition(edition, true)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return next(SMODS.Edition:get_edition_cards(G.jokers, true))
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'value_will_rise',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 0, y = 1 },
    config = {mod_edition = 'e_cloverpit_speculative' },
    
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_edition]
        return { vars = {"Speculative", localize { type = 'name_text', set = 'Edition', key = card.ability.mod_edition } } }
    end,

    use = function(self, card, area, copier)
        local editionless_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)
        local eligible_card = pseudorandom_element(editionless_jokers, 'speculative')
        local edition = SMODS.poll_edition { key = "speculative", guaranteed = true, no_negative = true, options = { card.ability.mod_edition } }
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                eligible_card:set_edition(edition, true)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return next(SMODS.Edition:get_edition_cards(G.jokers, true))
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'gave_me_lemons',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 1, y = 1 },
    config = { extra = { rank1 = 2, rank2 = 3 } },
    
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.rank1, card.ability.extra.rank2} }
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.7,
            func = function()
                local cards = {}
                cards[0] = SMODS.add_card({ set = "Base", rank = card.ability.extra.rank1 })
                cards[1] = SMODS.add_card({ set = "Base", rank = card.ability.extra.rank2 })
                local edition1 = pseudorandom_element({'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                    'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome'}, 'lemon')
                local edition2 = pseudorandom_element({'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                    'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome'}, 'lemon')
                cards[0]:set_edition(edition1, true)
                cards[1]:set_edition(edition2, true)
                SMODS.calculate_context({ playing_card_added = true, cards = cards })
                return true
            end
        }))
        delay(0.3)
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'eat_healthy',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 2, y = 1 },
    config = { extra = { rank1 = 4, rank2 = 5 } },
    
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.rank1, card.ability.extra.rank2} }
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.7,
            func = function()
                local cards = {}
                cards[0] = SMODS.add_card({ set = "Base", rank = card.ability.extra.rank1 })
                cards[1] = SMODS.add_card({ set = "Base", rank = card.ability.extra.rank2 })
                local edition1 = pseudorandom_element({'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                    'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome'}, 'cherry')
                local edition2 = pseudorandom_element({'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                    'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome'}, 'cherry')
                cards[0]:set_edition(edition1, true)
                cards[1]:set_edition(edition2, true)
                SMODS.calculate_context({ playing_card_added = true, cards = cards })
                return true
            end
        }))
        delay(0.3)
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'lucky_day',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 3, y = 1 },
    config = { extra = { rank1 = 6, rank2 = 7 } },
    
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.rank1, card.ability.extra.rank2} }
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.7,
            func = function()
                local cards = {}
                cards[0] = SMODS.add_card({ set = "Base", rank = card.ability.extra.rank1 })
                cards[1] = SMODS.add_card({ set = "Base", rank = card.ability.extra.rank2 })
                local edition1 = pseudorandom_element({'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                    'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome'}, 'clover')
                local edition2 = pseudorandom_element({'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                    'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome'}, 'clover')
                cards[0]:set_edition(edition1, true)
                cards[1]:set_edition(edition2, true)
                SMODS.calculate_context({ playing_card_added = true, cards = cards })
                return true
            end
        }))
        delay(0.3)
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'to_be_there',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 4, y = 1 },
    config = { extra = { rank1 = 8, rank2 = 9 } },

    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.rank1, card.ability.extra.rank2} }
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.7,
            func = function()
                local cards = {}
                cards[0] = SMODS.add_card({ set = "Base", rank = card.ability.extra.rank1 })
                cards[1] = SMODS.add_card({ set = "Base", rank = card.ability.extra.rank2 })
                local edition1 = pseudorandom_element({'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                    'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome'}, 'bell')
                local edition2 = pseudorandom_element({'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                    'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome'}, 'bell')
                cards[0]:set_edition(edition1, true)
                cards[1]:set_edition(edition2, true)
                SMODS.calculate_context({ playing_card_added = true, cards = cards })
                return true
            end
        }))
        delay(0.3)
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'give_you_anything',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 5, y = 1 },
    config = { extra = { rank1 = 10, rank2 = "J" } },
    
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.rank1, card.ability.extra.rank2} }
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.7,
            func = function()
                local cards = {}
                cards[0] = SMODS.add_card({ set = "Base", rank = card.ability.extra.rank1 })
                cards[1] = SMODS.add_card({ set = "Base", rank = card.ability.extra.rank2 })
                local edition1 = pseudorandom_element({'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                    'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome'}, 'diamond')
                local edition2 = pseudorandom_element({'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                    'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome'}, 'diamond')
                cards[0]:set_edition(edition1, true)
                cards[1]:set_edition(edition2, true)
                SMODS.calculate_context({ playing_card_added = true, cards = cards })
                return true
            end
        }))
        delay(0.3)
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'need_money',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 6, y = 1 },
    config = { extra = { rank1 = "Q", rank2 = "K" } },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.rank1, card.ability.extra.rank2} }
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.7,
            func = function()
                local cards = {}
                cards[0] = SMODS.add_card({ set = "Base", rank = card.ability.extra.rank1 })
                cards[1] = SMODS.add_card({ set = "Base", rank = card.ability.extra.rank2 })
                local edition1 = pseudorandom_element({'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                    'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome'}, 'treasure')
                local edition2 = pseudorandom_element({'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                    'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome'}, 'treasure')
                cards[0]:set_edition(edition1, true)
                cards[1]:set_edition(edition2, true)
                SMODS.calculate_context({ playing_card_added = true, cards = cards })
                return true
            end
        }))
        delay(0.3)
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'hurt_anybody',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 7, y = 1 },
    config = { extra = { rank = 'A', enhancement = 'm_stone' } },
    
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_stone
        return { vars = {card.ability.extra.rank, card.ability.extra.enhancement} }
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.7,
            func = function()
                local cards = {}
                cards[0] = SMODS.add_card({ set = "Base", rank = card.ability.extra.rank1 })
                cards[1] = SMODS.add_card({ set = "Base", enhancement = card.ability.extra.enhancement })
                local edition1 = pseudorandom_element({'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                    'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome'}, 'seven')
                local edition2 = pseudorandom_element({'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                    'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome'}, 'seven')
                cards[0]:set_edition(edition1, true)
                cards[1]:set_edition(edition2, true)
                SMODS.calculate_context({ playing_card_added = true, cards = cards })
                return true
            end
        }))
        delay(0.3)
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'need_supplements',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 8, y = 1 },
    config = { extra = { suit = "Hearts" } },
    
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.suit} }
    end,

    use = function(self, card, area, copier)
        local used_tarot = copier or card
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.cards do
            if G.hand.cards[i]:is_suit(card.ability.extra.suit) then
                local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        G.hand.cards[i]:flip()
                        play_sound('card1', percent)
                        G.hand.cards[i]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
            end
        end

        for i = 1, #G.hand.cards do
            if G.hand.cards[i]:is_suit(card.ability.extra.suit) then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local seal_pool = {'Gold','Red','Blue','Purple'}
                        local random_seal = pseudorandom_element(seal_pool, 'spades')
                        G.hand.cards[i]:set_seal(random_seal, nil, true)
                        return true
                    end
                }))
            end
        end
        for i = 1, #G.hand.cards do
            if G.hand.cards[i]:is_suit(card.ability.extra.suit) then
                local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        G.hand.cards[i]:flip()
                        play_sound('tarot2', percent, 0.6)
                        G.hand.cards[i]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
            end
        end
        delay(0.5)
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'feeling_lucky',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 9, y = 1 },
    config = { extra = { suit = "Clubs" } },
    
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.suit} }
    end,

    use = function(self, card, area, copier)
        local used_tarot = copier or card
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.cards do
            if G.hand.cards[i]:is_suit(card.ability.extra.suit) then
                local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        G.hand.cards[i]:flip()
                        play_sound('card1', percent)
                        G.hand.cards[i]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
            end
        end

        for i = 1, #G.hand.cards do
            if G.hand.cards[i]:is_suit(card.ability.extra.suit) then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local seal_pool = {'Gold','Red','Blue','Purple'}
                        local random_seal = pseudorandom_element(seal_pool, 'spades')
                        G.hand.cards[i]:set_seal(random_seal, nil, true)
                        return true
                    end
                }))
            end
        end
        for i = 1, #G.hand.cards do
            if G.hand.cards[i]:is_suit(card.ability.extra.suit) then
                local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        G.hand.cards[i]:flip()
                        play_sound('tarot2', percent, 0.6)
                        G.hand.cards[i]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
            end
        end
        delay(0.5)
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'good_investment',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 0, y = 2 },
    config = { extra = { suit = "Diamonds" } },
    
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.suit} }
    end,

    use = function(self, card, area, copier)
        local used_tarot = copier or card
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.cards do
            if G.hand.cards[i]:is_suit(card.ability.extra.suit) then
                local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        G.hand.cards[i]:flip()
                        play_sound('card1', percent)
                        G.hand.cards[i]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
            end
        end

        for i = 1, #G.hand.cards do
            if G.hand.cards[i]:is_suit(card.ability.extra.suit) then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local seal_pool = {'Gold','Red','Blue','Purple'}
                        local random_seal = pseudorandom_element(seal_pool, 'spades')
                        G.hand.cards[i]:set_seal(random_seal, nil, true)
                        return true
                    end
                }))
            end
        end
        for i = 1, #G.hand.cards do
            if G.hand.cards[i]:is_suit(card.ability.extra.suit) then
                local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        G.hand.cards[i]:flip()
                        play_sound('tarot2', percent, 0.6)
                        G.hand.cards[i]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
            end
        end
        delay(0.5)
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'go_all_in',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 1, y = 2 },
    config = { extra = { suit = "Spades" } },
    
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.suit} }
    end,

    use = function(self, card, area, copier)
        local used_tarot = copier or card
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.cards do
            if G.hand.cards[i]:is_suit(card.ability.extra.suit) then
                local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        G.hand.cards[i]:flip()
                        play_sound('card1', percent)
                        G.hand.cards[i]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
            end
        end

        for i = 1, #G.hand.cards do
            if G.hand.cards[i]:is_suit(card.ability.extra.suit) then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local seal_pool = {'Gold','Red','Blue','Purple'}
                        local random_seal = pseudorandom_element(seal_pool, 'spades')
                        G.hand.cards[i]:set_seal(random_seal, nil, true)
                        return true
                    end
                }))
            end
        end
        for i = 1, #G.hand.cards do
            if G.hand.cards[i]:is_suit(card.ability.extra.suit) then
                local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        G.hand.cards[i]:flip()
                        play_sound('tarot2', percent, 0.6)
                        G.hand.cards[i]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
            end
        end
        delay(0.5)
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'some_strategies',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 2, y = 2 },
    config = { extra = {levels = 1} },
    
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.levels } }
    end,

    use = function(self, card, area, copier)
        update_hand_text({ sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3 },
            { handname = '<5 Card Hands', chips = '...', mult = '...', level = '' })
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.8, 0.5)
                G.TAROT_INTERRUPT_PULSE = true
                return true
            end
        }))
        update_hand_text({ delay = 0 }, { mult = '+', StatusText = true })
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.9,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.8, 0.5)
                return true
            end
        }))
        update_hand_text({ delay = 0 }, { chips = '+', StatusText = true })
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.9,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.8, 0.5)
                G.TAROT_INTERRUPT_PULSE = nil
                return true
            end
        }))
        update_hand_text({ sound = 'button', volume = 0.7, pitch = 0.9, delay = 0 }, { level = '+'..tostring(card.ability.extra.levels) })
        delay(1.3)
        level_up_hand(card, 'High Card', true, card.ability.extra.levels)
        level_up_hand(card, 'Pair', true, card.ability.extra.levels)
        level_up_hand(card, 'Two Pair', true, card.ability.extra.levels)
        level_up_hand(card, 'Three of a Kind', true, card.ability.extra.levels)
        level_up_hand(card, 'Four of a Kind', true, card.ability.extra.levels)
        update_hand_text({ sound = 'button', volume = 0.7, pitch = 1.1, delay = 0 },
            { mult = 0, chips = 0, handname = '', level = '' })
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
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
    key = 'winning_strategies',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 3, y = 2 },
    config = { extra = {levels = 1} },
    
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.levels } }
    end,

    use = function(self, card, area, copier)
        update_hand_text({ sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3 },
            { handname = '5 Card Hands', chips = '...', mult = '...', level = '' })
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.8, 0.5)
                G.TAROT_INTERRUPT_PULSE = true
                return true
            end
        }))
        update_hand_text({ delay = 0 }, { mult = '+', StatusText = true })
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.9,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.8, 0.5)
                return true
            end
        }))
        update_hand_text({ delay = 0 }, { chips = '+', StatusText = true })
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.9,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.8, 0.5)
                G.TAROT_INTERRUPT_PULSE = nil
                return true
            end
        }))
        update_hand_text({ sound = 'button', volume = 0.7, pitch = 0.9, delay = 0 }, { level = '+'..tostring(card.ability.extra.levels) })
        delay(1.3)
        level_up_hand(card, 'Straight', true, card.ability.extra.levels)
        level_up_hand(card, 'Flush', true, card.ability.extra.levels)
        level_up_hand(card, 'Full House', true, card.ability.extra.levels)
        level_up_hand(card, 'Straight Flush', true, card.ability.extra.levels)
        level_up_hand(card, 'Five of a Kind', true, card.ability.extra.levels)
        level_up_hand(card, 'Flush House', true, card.ability.extra.levels)
        level_up_hand(card, 'Flush Five', true, card.ability.extra.levels)
        update_hand_text({ sound = 'button', volume = 0.7, pitch = 1.1, delay = 0 },
            { mult = 0, chips = 0, handname = '', level = '' })
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_neutral')
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
    key = 'shiny_stuff',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 4, y = 2 },
    config = {extra = {mod_conv = 'm_cloverpit_devilish'}},
    
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_edition]
        return { vars = {localize { type = 'name_text', set = 'Enhanced', key = card.ability.extra.mod_conv }} }
    end,

    use = function(self, card, area, copier)

        local editionless_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)
        draw_card(G.play, G.discard, 90, 'up')
        for _, joker in ipairs(editionless_jokers) do
            edition = pseudorandom_element({'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome', 'e_negative'}, 'shiny_stuff')
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    joker:set_edition(edition, true)
                    return true
                end
            }))
            local card_front = pseudorandom_element(G.P_CARDS, pseudoseed('shiny_stuff'))
            local base_card = create_playing_card({
                front = card_front,
                center = G.P_CENTERS.m_cloverpit_devilish
            }, G.discard, true, false, nil, true) 
            G.E_MANAGER:add_event(Event({
                func = function()
                    base_card:start_materialize()
                    G.play:emplace(base_card)
                    return true
                end
            }))
            delay(1.2)
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.deck.config.card_limit = G.deck.config.card_limit + 1
                    return true
                end
            }))
            SMODS.calculate_context({ playing_card_added = true, cards = { base_card } })
        end
        
        for i = 1, #editionless_jokers do
            draw_card(G.play, G.deck, 90, 'up')
            delay(0.2)
        end 

        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_evil')
                return true
            end
        }))

    end,

    can_use = function(self, card)
        return next(SMODS.Edition:get_edition_cards(G.jokers, true))
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'cryptic_values',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 5, y = 2 },
    config = {extra = {sell_mod = 6, set_money = 0, mod_conv = 'm_cloverpit_devilish'}},
    
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_edition]
        return { vars = {card.ability.extra.sell_mod, card.ability.extra.set_money, 
            localize { type = 'name_text', set = 'Enhanced', key = card.ability.extra.mod_conv }} }
    end,

    use = function(self, card, area, copier)
        for _, chosen_joker in ipairs(G.jokers.cards) do
            local increase = (card.ability.extra.sell_mod) * (chosen_joker.sell_cost) 
            local current_cost = chosen_joker.sell_cost
            chosen_joker.ability.extra_value = 0
            chosen_joker:set_cost()
            chosen_joker.ability.extra_value = increase - chosen_joker.sell_cost
            chosen_joker:set_cost()
            card_eval_status_text(chosen_joker, 'extra', nil, nil, nil, {message = "+ $"..tostring(increase - current_cost), colour = G.C.MONEY})
        end 

        if G.GAME.dollars ~= 0 then
            ease_dollars(-G.GAME.dollars, true)
        end

        draw_card(G.play, G.discard, 90, 'up')
        local card_front = pseudorandom_element(G.P_CARDS, pseudoseed('cryptic_values'))
        local base_card = create_playing_card({
            front = card_front,
            center = G.P_CENTERS.m_cloverpit_devilish
        }, G.discard, true, false, nil, true) 
        G.E_MANAGER:add_event(Event({
            func = function()
                base_card:start_materialize()
                G.play:emplace(base_card)
                return true
            end
        }))
        delay(1.2)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                return true
            end
        }))
        draw_card(G.play, G.deck, 90, 'up')
        SMODS.calculate_context({ playing_card_added = true, cards = { base_card } })

        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_evil')
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return #G.jokers.cards > 0
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'care_about_the_price',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 6, y = 2 },
    config = { extra = { tag = "tag_negative", mod_conv = 'm_cloverpit_devilish', num_cards = 4 } },
    
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.tag, card.ability.extra.num_cards, 
            localize { type = 'name_text', set = 'Enhanced', key = card.ability.extra.mod_conv } } }
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        local tag = Tag(card.ability.extra.tag)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                card:juice_up(0.3, 0.5)
                add_tag(tag)
                add_tag(tag)
                return true
            end
        }))

        draw_card(G.play, G.discard, 90, 'up')
        for i = 1, 4 do 
            local card_front = pseudorandom_element(G.P_CARDS, pseudoseed('shiny_stuff'))
            local base_card = create_playing_card({
                front = card_front,
                center = G.P_CENTERS.m_cloverpit_devilish
            }, G.discard, true, false, nil, true) 
            G.E_MANAGER:add_event(Event({
                func = function()
                    base_card:start_materialize()
                    G.play:emplace(base_card)
                    return true
                end
            }))
            delay(0.8)
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.deck.config.card_limit = G.deck.config.card_limit + 1
                    return true
                end
            }))
            SMODS.calculate_context({ playing_card_added = true, cards = { base_card } })
        end

        for i = 1, 4 do
            draw_card(G.play, G.deck, 90, 'up')
            delay(0.2)
        end 

        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_evil')
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
    key = 'head_hurts',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 7, y = 2 },
    config = {extra = {mod_conv = 'm_cloverpit_devilish'}},
    
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_edition]
        return { vars = {localize { type = 'name_text', set = 'Enhanced', key = card.ability.extra.mod_conv }} }
    end,

    use = function(self, card, area, copier)
        local num_cards = G.consumeables.config.card_limit - #G.consumeables.cards
        draw_card(G.play, G.discard, 90, 'up')
        for i = 1, num_cards do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    play_sound('timpani')
                    SMODS.add_card({ set = 'cloverpit_phone'})    
                    return true
                end
            }))


            local card_front = pseudorandom_element(G.P_CARDS, pseudoseed('shiny_stuff'))
            local base_card = create_playing_card({
                front = card_front,
                center = G.P_CENTERS.m_cloverpit_devilish
            }, G.discard, true, false, nil, true) 
            G.E_MANAGER:add_event(Event({
                func = function()
                    base_card:start_materialize()
                    G.play:emplace(base_card)
                    return true
                end
            }))
            delay(1.2)
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.deck.config.card_limit = G.deck.config.card_limit + 1
                    return true
                end
            }))
            SMODS.calculate_context({ playing_card_added = true, cards = { base_card } })
        end
        
        for i = 1, num_cards do
            draw_card(G.play, G.deck, 90, 'up')
            delay(0.2)
        end 

        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_phone_evil')
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
    key = 'back_my_money',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 8, y = 2 },
    config = {extra = {mod_conv = 'm_cloverpit_devilish', money = 66}},
    
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_edition]
        return { vars = {localize { type = 'name_text', set = 'Enhanced', key = card.ability.extra.mod_conv }, card.ability.extra.money} }
    end,

    use = function(self, card, area, copier)
        for i = 1, #G.hand.cards do
            local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.cards[i]:flip()
                    play_sound('card1', percent)
                    G.hand.cards[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.cards do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.cards[i]:set_ability(card.ability.extra.mod_conv)
                    return true
                end
            }))
        end
        for i = 1, #G.hand.cards do
            local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.cards[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.cards[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)

        G.E_MANAGER:add_event(Event({
            func = function()
                ease_dollars(card.ability.extra.money, true)
                play_sound('cloverpit_phone_evil')
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
    key = 'but_mould',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 9, y = 2 },
    config = {extra = {mod_conv = 'm_cloverpit_devilish'}},
    
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_edition]
        return { vars = {localize { type = 'name_text', set = 'Enhanced', key = card.ability.extra.mod_conv }} }
    end,

    use = function(self, card, area, copier)
        for i = 1, #G.hand.cards do
            local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.cards[i]:flip()
                    play_sound('card1', percent)
                    G.hand.cards[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)

        for i = 1, #G.hand.cards do
            if not((G.hand.cards[i]:get_id() <= 10 and G.hand.cards[i]:get_id() >= 0 and G.hand.cards[i]:get_id() % 2 == 1) or
                (G.hand.cards[i]:get_id() == 14)) then 
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        G.hand.cards[i]:set_ability(card.ability.extra.mod_conv)
                        return true
                    end
                }))
            else 
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local seal_pool = {'Gold','Red','Blue','Purple'}
                        local enhancement_pool = {}
                        local random_seal = pseudorandom_element(seal_pool, 'mould')
                        for _, enhancement in pairs(G.P_CENTER_POOLS.Enhanced) do
                            if enhancement.key ~= 'm_cloverpit_devilish' then
                                enhancement_pool[#enhancement_pool + 1] = enhancement
                            end
                        end
                        local random_enhancement = pseudorandom_element(enhancement_pool, 'mould')
                        local edition = pseudorandom_element({'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                    'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome'}, 'mould')
                        G.hand.cards[i]:set_seal(random_seal, nil, true)
                        G.hand.cards[i]:set_ability(random_enhancement)
                        G.hand.cards[i]:set_edition(edition, true)
                        return true
                    end
                }))
            end
        end

        for i = 1, #G.hand.cards do
            local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.cards[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.cards[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)

    end,

    can_use = function(self, card)
        return true
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'day_is_it',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 0, y = 3 },
    config = {extra = {mod_conv = 'm_cloverpit_devilish'}},

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_edition]
        return { vars = {localize { type = 'name_text', set = 'Enhanced', key = card.ability.extra.mod_conv }} }
    end,

    use = function(self, card, area, copier)
        for i = 1, #G.hand.cards do
            local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.cards[i]:flip()
                    play_sound('card1', percent)
                    G.hand.cards[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)

        for i = 1, #G.hand.cards do
            if not(G.hand.cards[i]:get_id() <= 10 and G.hand.cards[i]:get_id() >= 0 and G.hand.cards[i]:get_id() % 2 == 0) then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        G.hand.cards[i]:set_ability(card.ability.extra.mod_conv)
                        return true
                    end
                }))
            else 
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local seal_pool = {'Gold','Red','Blue','Purple'}
                        local enhancement_pool = {}
                        local random_seal = pseudorandom_element(seal_pool, 'mould')
                        for _, enhancement in pairs(G.P_CENTER_POOLS.Enhanced) do
                            if enhancement.key ~= 'm_cloverpit_devilish' then
                                enhancement_pool[#enhancement_pool + 1] = enhancement
                            end
                        end
                        local random_enhancement = pseudorandom_element(enhancement_pool, 'mould')
                        local edition = pseudorandom_element({'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                    'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome'}, 'mould')
                        G.hand.cards[i]:set_seal(random_seal, nil, true)
                        G.hand.cards[i]:set_ability(random_enhancement)
                        G.hand.cards[i]:set_edition(edition, true)
                        return true
                    end
                }))
            end
        end

        for i = 1, #G.hand.cards do
            local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.cards[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.cards[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)

    end,

    can_use = function(self, card)
        return true
    end
}


------------------------------------------------------------


SMODS.Consumable {
    key = 'bet_it_all',
    atlas = 'phone',
    set = 'cloverpit_phone',
    pos = { x = 1, y = 3 },
    config = {extra = {mod_conv = 'm_cloverpit_devilish'}},
    
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_edition]
        return { vars = {localize { type = 'name_text', set = 'Enhanced', key = card.ability.extra.mod_conv }} }
    end,

    use = function(self, card, area, copier)
        for i = 1, #G.hand.cards do
            local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.cards[i]:flip()
                    play_sound('card1', percent)
                    G.hand.cards[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)

        for i = 1, #G.hand.cards do
            if not G.hand.cards[i]:is_face() then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        G.hand.cards[i]:set_ability(card.ability.extra.mod_conv)
                        return true
                    end
                }))
            else 
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local seal_pool = {'Gold','Red','Blue','Purple'}
                        local enhancement_pool = {}
                        local random_seal = pseudorandom_element(seal_pool, 'mould')
                        for _, enhancement in pairs(G.P_CENTER_POOLS.Enhanced) do
                            if enhancement.key ~= 'm_cloverpit_devilish' then
                                enhancement_pool[#enhancement_pool + 1] = enhancement
                            end
                        end
                        local random_enhancement = pseudorandom_element(enhancement_pool, 'mould')
                        local edition = pseudorandom_element({'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                    'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome'}, 'mould')
                        G.hand.cards[i]:set_seal(random_seal, nil, true)
                        G.hand.cards[i]:set_ability(random_enhancement)
                        G.hand.cards[i]:set_edition(edition, true)
                        return true
                    end
                }))
            end
        end

        for i = 1, #G.hand.cards do
            local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.cards[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.cards[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)

    end,

    can_use = function(self, card)
        return true
    end
}