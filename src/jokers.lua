SMODS.Joker {
    key = "ankh",
    blueprint_compat = false,
    rarity = 2,
    cost = 5,
    pos = { x = 0, y = 0 },
    config = { extra = { hands = 2 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {vars = {(G.GAME.round_resets.hands or 0), (G.GAME.round_resets.discards or 0)}}
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main and G.GAME.current_round.hands_left == 0 and G.GAME.current_round.discards_left == 0 then
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.hand_text_area.blind_chips:juice_up()
                    G.hand_text_area.game_chips:juice_up()
                    play_sound('cloverpit_ankh')
                    card:start_dissolve()
                    return true
                end
            }))
            return {
                func = function()
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Set to "..tostring(G.GAME.round_resets.hands).." Hands", colour = G.C.RED})
                    ease_hands_played(G.GAME.round_resets.hands)
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Set to "..tostring(G.GAME.round_resets.discards).." Discards", colour = G.C.BLUE})
                    ease_discard(G.GAME.round_resets.discards)
                    return true
                end
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "horseshoe",
    blueprint_compat = false,
    rarity = 1,
    cost = 2,
    pos = { x = 1, y = 0 },
    config = { extra = { odds = 0, is_active = true } } ,
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.odds, card.ability.extra.is_active } }
    end,

    can_use_active = function(self, card)
        return true
    end,

    active = function(self, card)
        card:flip()
        card.ability.extra.is_active = not card.ability.extra.is_active
        if card.ability.extra.is_active then
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Active", colour = G.C.BLUE})
        else
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Inactive", colour = G.C.RED})
        end

        play_sound('cloverpit_horseshoe')
    end,

    calculate = function(self, card, context)
        if context.mod_probability and not context.blueprint and card.ability.extra.is_active then
            return {
                numerator = context.numerator * card.ability.extra.odds
            }
        end
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "golden_horseshoe",
    blueprint_compat = false,
    rarity = 2,
    cost = 6,
    pos = { x = 2, y = 0 },
    config = { extra = { charge = 5, current_charge = 0, ready = false, odds = 4}},
	atlas = 'ModdedVanilla',
    chargeable = true,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        return { vars = { card.ability.extra.charge, card.ability.extra.current_charge, card.ability.extra.ready, card.ability.extra.odds } }
    end,

    active = function(self, card)
        card.ability.extra.current_charge = 0
        card.ability.extra.ready = true
        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Activated!", colour = G.C.GOLD})
        play_sound('cloverpit_horseshoe')
    end,

    can_use_active = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND and card.ability.extra.charge == card.ability.extra.current_charge and not card.ability.extra.ready 
    end,

    calculate = function(self, card, context)
        if context.after and card.ability.extra.current_charge < card.ability.extra.charge then
            card.ability.extra.current_charge = card.ability.extra.current_charge + 1
            if card.ability.extra.current_charge == card.ability.extra.charge then
                local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
                juice_card_until(card, eval, true)
                return {
                    message = 'Ready!'
                }
            end
        end

        if context.setting_blind and card.ability.extra.current_charge == card.ability.extra.charge then
            local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
            return {
                message = 'Ready!'
            }
        end

        if context.mod_probability and not context.blueprint and card.ability.extra.ready then
            return {
                numerator = context.numerator * card.ability.extra.odds
            }
        end

        if context.after and card.ability.extra.ready then
            card.ability.extra.ready = false
        end
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "hamsa",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    pos = { x = 3, y = 0 },
    config = { extra = { repetitions = 2 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.repetitions }}
    end,

    calculate = function(self, card, context)
        if context.before and G.GAME.current_round.hands_played == 0 and not context.blueprint then
            card:juice_up(0.3, 0.5)
            play_sound('cloverpit_hamsa')
        end

        if context.repetition and context.cardarea == G.hand 
            and G.GAME.current_round.hands_played == 0 
            and (next(context.card_effects[1]) or #context.card_effects > 1) 
            then
            return {
                repetitions = card.ability.extra.repetitions
            }
        end
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "rotated_hamsa",
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    pos = { x = 4, y = 0 },
    config = { extra = { mult = 30 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.mult }}
    end,

    calculate = function(self, card, context)
        if context.joker_main and G.GAME.current_round.hands_left == 0 then
            if context.cardarea == G.jokers and not context.blueprint then 
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_hamsa')
                        return true
                    end
                }))
            end
            
            return {
                mult = card.ability.extra.mult,
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "lucky_cat",
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    pos = { x = 5, y = 0 },
    config = { extra = { threshold = 2, mult = 30, count = 0 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.threshold, card.ability.extra.mult, card.ability.extra.count } }
    end,

    calculate = function(self, card, context)
        if context.before then
            card.ability.extra.count = 0
        end

        if context.individual and context.cardarea == G.play and not context.blueprint then
            if ((function()
                local enhancements = SMODS.get_enhancements(context.other_card)
                for k, v in pairs(enhancements) do
                    if v then
                        return true
                    end
                end
                return false end
                )() or context.other_card.edition ~= nil or context.other_card.seal ~= nil) then
                    card.ability.extra.count = card.ability.extra.count + 1
            end
        end

        if context.joker_main then
            if card.ability.extra.count >= card.ability.extra.threshold then
                if not context.blueprint then 
                    card.ability.extra.count = 0
                end
                if context.cardarea == G.jokers and not context.blueprint then 
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('cloverpit_lucky_cat')
                            return true
                        end
                    }))
                end
                return {
                    mult = card.ability.extra.mult
                }
            else
                if not context.blueprint then 
                    card.ability.extra.count = 0
                end
            end
        end

    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "chonky_cat",
    blueprint_compat = true,
    rarity = 2,
    cost = 5,
    pos = { x = 6, y = 0 },
    config = { extra = { threshold = 5, xmult = 1.5, count = 0 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.threshold, card.ability.extra.xmult, card.ability.extra.count } }
    end,

    calculate = function(self, card, context)
        if context.before then
            card.ability.extra.count = 0
        end

        if context.cardarea == G.jokers and context.joker_main then
            card.ability.extra.count = 0
            for _, playing_card in ipairs(context.scoring_hand) do
                if ((function()
                    local enhancements = SMODS.get_enhancements(playing_card)
                    for k, v in pairs(enhancements) do
                        if v then
                            return true
                        end
                    end
                    return false end
                    )() or playing_card.edition ~= nil or playing_card.seal ~= nil) then
                        card.ability.extra.count = card.ability.extra.count + 1
                end
            end 

            for _, playing_card in ipairs(G.hand.cards) do
                if ((function()
                    local enhancements = SMODS.get_enhancements(playing_card)
                    for k, v in pairs(enhancements) do
                        if v then
                            return true
                        end
                    end
                    return false end
                    )() or playing_card.edition ~= nil or playing_card.seal ~= nil) then
                        card.ability.extra.count = card.ability.extra.count + 1
                end
            end         
		end

        if context.joker_main then
            if card.ability.extra.count >= card.ability.extra.threshold then
                if not context.blueprint then 
                    card.ability.extra.count = 0
                end
                if context.cardarea == G.jokers and not context.blueprint then 
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('cloverpit_chonky_cat')
                            return true
                        end
                    }))
                end
                return {
                    xmult = card.ability.extra.xmult
                }
            else
                if not context.blueprint then 
                    card.ability.extra.count = 0
                end
            end
        end
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "swole_cat",
    blueprint_compat = true,
    rarity = 3,
    cost = 8,
    pos = { x = 7, y = 0 },
    config = { extra = { pow_mult = 1.2 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local count = 0
        local threshold = 0
        for _, playing_card in pairs(G.playing_cards or {}) do
            if next(SMODS.get_enhancements(playing_card)) or playing_card.edition ~= nil or playing_card.seal ~= nil then count = count + 1 end
            threshold = threshold + 1
        end
        if threshold % 2 == 1 then
            threshold = threshold - 1
        end
        threshold = threshold / 2
        return { vars = { threshold, card.ability.extra.pow_mult, count } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then

            local count = 0
            local threshold = 0
            for _, playing_card in pairs(G.playing_cards or {}) do
                if next(SMODS.get_enhancements(playing_card)) or playing_card.edition ~= nil or playing_card.seal ~= nil then count = count + 1 end
                threshold = threshold + 1
            end

            if threshold % 2 == 1 then
                threshold = threshold - 1
            end
            threshold = threshold / 2


            if count >= threshold then
                if context.cardarea == G.jokers and not context.blueprint then 
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('cloverpit_swole_cat')
                            return true
                        end
                    }))
                end
                return {
                    pow_mult = card.ability.extra.pow_mult
                }
            end
        end

    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "one_trick_pony",
    blueprint_compat = false,
    rarity = 1,
    cost = 5,
    pos = { x = 8, y = 0 },
    config = { extra = { pow_mult = 2 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.pow_mult }}
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            local target_joker = card
            if target_joker then
                target_joker.getting_sliced = true
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card:juice_up(0.3, 0.5)
                        play_sound('cloverpit_one_trick_pony')
                        target_joker:start_dissolve({G.C.RED}, nil, 1.6)
                        return true
                    end
                }))
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Destroyed!", colour = G.C.RED})
            end
            return {
                pow_mult = card.ability.extra.pow_mult
            }
        end
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "red_shiny_rock",
    blueprint_compat = false,
    rarity = 1,
    cost = 4,
    pos = { x = 9, y = 0 },
    config = { extra = { charge = 2, current_charge = 0, draw = 1 } },
	atlas = 'ModdedVanilla',
    chargeable = true,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        return { vars = { card.ability.extra.charge, card.ability.extra.current_charge, card.ability.extra.draw } }
    end,

    active = function(self, card)
        card.ability.extra.current_charge = 0
        SMODS.draw_cards(card.ability.extra.draw)
        play_sound('cloverpit_red_shiny_rock')
        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Drawn!", colour = G.C.BLUE})
    end,

    can_use_active = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND and card.ability.extra.charge == card.ability.extra.current_charge
    end,

    calculate = function(self, card, context)
        if context.after and card.ability.extra.current_charge < card.ability.extra.charge then
            card.ability.extra.current_charge = card.ability.extra.current_charge + 1
            if card.ability.extra.current_charge == card.ability.extra.charge then
                local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
                juice_card_until(card, eval, true)
                return {
                    message = 'Ready!'
                }
            end
        end

        if context.setting_blind and card.ability.extra.current_charge == card.ability.extra.charge then
            local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
            return {
                message = 'Ready!'
            }
        end

    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "tarot_deck",
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 0, y = 1 },
    config = { extra = { mult_gain = 2, mult = 0 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.mult_gain, card.ability.extra.mult}}
    end,

    calculate = function(self, card, context)
        if context.post_trigger and context.other_card ~= card and not context.blueprint then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
        end

        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            card.ability.extra.mult = 0
            return {
                message = localize('k_reset')
            }
        end

        if context.joker_main and card.ability.extra.mult > 0 then
            if context.cardarea == G.jokers and not context.blueprint then 
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_tarot_deck')
                        return true
                    end
                }))
            end
            return {
                mult = card.ability.extra.mult
            }    
        end
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "dung_beetle",
    blueprint_compat = true,
    rarity = 3,
    cost = 8,
    pos = { x = 1, y = 1 },
    config = { extra = { mult = 0, multmult = 3 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.mult, card.ability.extra.multmult }}
    end,

    calculate = function(self, card, context)
        if context.selling_card and not context.blueprint and context.card ~= card then
            card.ability.extra.mult = card.ability.extra.mult + (context.card.sell_cost * card.ability.extra.multmult)
            play_sound('cloverpit_dung_beetle')
            return {
                message = localize('k_upgrade_ex')
            }
        end

        if context.joker_main then 
            return {
                mult = card.ability.extra.mult
            }
        end
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "grandmas_purse",
    blueprint_compat = false,
    rarity = 1,
    cost = 5,
    pos = { x = 2, y = 1 },
    config = { extra = { money = 7, money_loss = 1 } },
	atlas = 'ModdedVanilla',

    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.money, card.ability.extra.money_loss }}
    end,

    calculate = function(self, card, context)
        if context.starting_shop then
            card.ability.extra.money = card.ability.extra.money - card.ability.extra.money_loss
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('cloverpit_grandmas_purse')
                    return true
                end
            }))
            if card.ability.extra.money  <= 0 then
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Empty!", colour = G.C.RED})
                SMODS.destroy_cards(card, nil, nil, true)
            else
                return {
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = "-$1", colour = G.C.MONEY})
                }
            end
        end
    end,

    calc_dollar_bonus = function(self, card)
        return card.ability.extra.money
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "pentacle",
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    pos = { x = 3, y = 1 },
    config = { extra = { chips_gain = 5, chips = 0 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.chips_gain, card.ability.extra.chips }}
    end,

    calculate = function(self, card, context)

        if context.joker_main and context.cardarea == G.jokers and #context.scoring_hand >= 5 and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_gain
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('cloverpit_book')
                    return true
                end
            }))
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.BLUE})
        end 

        if context.joker_main and context.cardarea == G.jokers then
            return {
                chips = card.ability.extra.chips
            }
        end

    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "property_certificate",
    blueprint_compat = false,
    rarity = 3,
    cost = 7,
    pos = { x = 4, y = 1 },
    config = { extra = { joker_slots = 2, hands = -1, discards = -1 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.joker_slots, card.ability.extra.hands, card.ability.extra.discards }}
    end,

    calculate = function(self, card, context)
        if context.setting_blind  then
            return {
                func = function()
                    ease_discard(card.ability.extra.discards, nil, true)
                    ease_hands_played(card.ability.extra.hands, nil, true)
                    return true
                end
            }
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        G.jokers.config.card_limit = G.jokers.config.card_limit + card.ability.extra.joker_slots
    end,
    
    remove_from_deck = function(self, card, from_debuff)
        G.jokers.config.card_limit = G.jokers.config.card_limit - card.ability.extra.joker_slots
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "nuclear_button",
    blueprint_compat = true,
    rarity = 3,
    cost = 8,
    pos = { x = 5, y = 1 },
    config = { extra = { xmult_mod = 0.25 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        local total_charge = 0
        for _, joker in ipairs(G.jokers and G.jokers.cards or {}) do     
            if joker.config.center.chargeable then
                total_charge = total_charge + joker.ability.extra.current_charge
            end
        end
        return { vars = { card.ability.extra.xmult_mod, 1 + card.ability.extra.xmult_mod * total_charge } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local total_charge = 0
            for _, joker in ipairs(G.jokers.cards) do
                if joker.config.center.chargeable then
                    total_charge = total_charge + joker.ability.extra.current_charge
                    if joker.ability.extra.current_charge < joker.ability.extra.charge then
                        total_charge = total_charge + 1
                    end 
                end
            end
            if context.cardarea == G.jokers and total_charge > 0 and not context.blueprint  then 
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_nuclear_button', 1, 0.4)
                        return true
                    end
                }))
            end
            return {
                xmult = 1 + card.ability.extra.xmult_mod * total_charge
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "dear_diary",
    blueprint_compat = false,
    rarity = 2,
    cost = 5,
    pos = { x = 6, y = 1 },
    config = { extra = { choices = 1 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.choices } }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.GAME.modifiers.booster_size_mod = (G.GAME.modifiers.booster_size_mod or 0) + card.ability.extra.choices
    end,
    
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.modifiers.booster_size_mod = (G.GAME.modifiers.booster_size_mod or 0) - card.ability.extra.choices
    end,

    calculate = function(self, card, context)
        if context.open_booster then
            card:juice_up(0.3, 0.5)
            play_sound('cloverpit_dear_diary')
        end
    end


}


------------------------------------------------------------


SMODS.Joker {
    key = "megaphone",
    blueprint_compat = false,
    rarity = 3,
    cost = 6,
    pos = { x = 7, y = 1 },
    config = { extra = { selections = 100 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.selections } }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.GAME.modifiers.booster_choice_mod = (G.GAME.modifiers.booster_choice_mod or 0) + card.ability.extra.selections 
    end,
    
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.modifiers.booster_choice_mod = (G.GAME.modifiers.booster_choice_mod or 0) - card.ability.extra.selections 
    end,

    calculate = function(self, card, context)
        if context.open_booster then
            card:juice_up(0.3, 0.5)
            play_sound('cloverpit_megaphone')
        end
    end
    
}


------------------------------------------------------------


SMODS.Joker {
    key = "super_capacitor",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    pos = { x = 8, y = 1 },
    config = { extra = { chips = 25 } } ,
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local chips_total = 0
        for _, joker in ipairs(G.jokers and G.jokers.cards or {}) do
            if joker.config.center.chargeable then
                if joker.ability.extra.current_charge + 1 >= joker.ability.extra.charge then
                    chips_total = chips_total + card.ability.extra.chips * joker.ability.extra.charge
                end
            end
        end

        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        return { vars = { card.ability.extra.chips, chips_total } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then 
            local chips_total = 0
            for _, joker in ipairs(G.jokers and G.jokers.cards or {}) do
                if joker.config.center.chargeable then
                    if joker.ability.extra.current_charge + 1 >= joker.ability.extra.charge then
                        chips_total = chips_total + card.ability.extra.chips * joker.ability.extra.charge
                    end
                end
            end
            if not context.blueprint and chips_total > 0 then 
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_super_capacitor')
                        return true
                    end
                }))
            end

            return {
                chips = chips_total
            }
            
        end
    end
}





------------------------------------------------------------


SMODS.Joker {
    key = "dynamo",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    pos = { x = 9, y = 1 },
    config = { extra = { odds = 2 } } ,
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'dynamo')
        return { vars = { numerator, denominator } }
    end,

    calculate = function(self, card, context)
        if context.other_joker and context.other_joker.config.center.chargeable and 
            SMODS.pseudorandom_probability(card, 'dynamo', 1, card.ability.extra.odds) then
            if context.other_joker.ability.extra.charge - 1> context.other_joker.ability.extra.current_charge then
                context.other_joker.ability.extra.current_charge = context.other_joker.ability.extra.current_charge + 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_dynamo')
                        return true
                    end
                }))
                card_eval_status_text(context.other_joker, 'extra', nil, nil, nil, {message = "Boosted!", colour = G.C.GOLD})
            end
        end
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "scratch_and_hope",
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 0, y = 2 },
    config = {  } ,
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {  } 
    end,

    calculate = function(self, card, context)
        if context.before then
            local reset = true
            local play_more_than = (G.GAME.hands[context.scoring_name].played or 0)
            for handname, values in pairs(G.GAME.hands) do
                if handname ~= context.scoring_name and values.played >= play_more_than and SMODS.is_poker_hand_visible(handname) then
                    reset = false
                    break
                end
            end
            if not reset then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_scratch_and_hope')
                        return true
                    end
                }))
                return {
                    level_up = true,
                    message = localize('k_level_up_ex')
                }
            end
        end
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "stonks",
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    pos = { x = 1, y = 2 },
    config = { extra = { percent_on = 90, percent_off = 10 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.percent_on, card.ability.extra.percent_off } }
    end,

    calculate = function(self, card, context)
        if context.setting_blind then
            card:juice_up(0.3, 0.5)
            play_sound('cloverpit_stonks')
            return {
                func = function()
                    G.GAME.blind.chips = G.GAME.blind.chips * ((100 - self.config.extra.percent_off) / 100)
                    G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                    G.HUD_blind:recalculate()
                    return true
                end
            }
        end
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "expired_meds",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    pos = { x = 2, y = 2 },
    config = { extra = { mult = 8 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            local total_mult = #context.full_hand - #context.scoring_hand
                if total_mult > 0 and not context.blueprint then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('cloverpit_expired_meds')
                            return true
                        end
                    }))
                end
            return {
                mult = total_mult * card.ability.extra.mult
            }
        end
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "midas_touch",
    blueprint_compat = false,
    rarity = 2,
    cost = 6,
    pos = { x = 3, y = 2 },
    config = { extra = { charge = 4, current_charge = 0, ready = false, chips = 77 } },
	atlas = 'ModdedVanilla',
    chargeable = true,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        return { vars = { card.ability.extra.charge, card.ability.extra.current_charge, card.ability.extra.chips, card.ability.extra.ready } }
    end,

    active = function(self, card)
        card.ability.extra.current_charge = 0
        card.ability.extra.ready = true
        play_sound('cloverpit_midas_touch')
        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Activated!", colour = G.C.BLUE})
    end,

    can_use_active = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND and card.ability.extra.charge == card.ability.extra.current_charge and not card.ability.extra.ready 
    end,

    calculate = function(self, card, context)
        if context.after and card.ability.extra.current_charge < card.ability.extra.charge then
            card.ability.extra.current_charge = card.ability.extra.current_charge + 1
            if card.ability.extra.current_charge == card.ability.extra.charge then
                local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
                juice_card_until(card, eval, true)
                return {
                    message = 'Ready!'
                }
            end
        end

        if context.setting_blind and card.ability.extra.current_charge == card.ability.extra.charge then
            local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
            return {
                message = 'Ready!'
            }
        end

        if context.individual and context.cardarea == G.play and card.ability.extra.ready then
            return {
                chips = card.ability.extra.chips
            }
        end

        if context.after and card.ability.extra.ready then
            card.ability.extra.ready = false
        end
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "number_one",
    blueprint_compat = false,
    rarity = 1,
    cost = 5,
    pos = { x = 4, y = 2 },
    config = { extra = { charge = 4, current_charge = 0, suit1 = "Hearts", suit2 = "Diamonds", ready = false, retriggers = 1 } },
	atlas = 'ModdedVanilla',
    chargeable = true,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        return { vars = { card.ability.extra.charge, card.ability.extra.current_charge, card.ability.extra.suit1, card.ability.extra.suit2, card.ability.extra.ready } }
    end,

    active = function(self, card)
        card.ability.extra.current_charge = 0
        card.ability.extra.ready = true
        play_sound('cloverpit_number_one')
        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Activated!", colour = G.C.BLUE})
    end,

    can_use_active = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND and card.ability.extra.charge == card.ability.extra.current_charge and not card.ability.extra.ready 
    end,

    calculate = function(self, card, context)
        if context.after and card.ability.extra.current_charge < card.ability.extra.charge then
            card.ability.extra.current_charge = card.ability.extra.current_charge + 1
            if card.ability.extra.current_charge == card.ability.extra.charge then
                local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
                juice_card_until(card, eval, true)
                return {
                    message = 'Ready!'
                }
            end
        end

        if context.setting_blind and card.ability.extra.current_charge == card.ability.extra.charge then
            local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
            return {
                message = 'Ready!'
            }
        end

        if context.repetition and context.cardarea == G.play and card.ability.extra.ready and 
            (context.other_card:is_suit(card.ability.extra.suit1) or context.other_card:is_suit(card.ability.extra.suit2)) then
            return {
                repetitions = card.ability.extra.retriggers
            }
        end

        if context.after and card.ability.extra.ready then
            card.ability.extra.ready = false
        end
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "number_two",
    blueprint_compat = false,
    rarity = 1,
    cost = 5,
    pos = { x = 5, y = 2 },
    config = { extra = { charge = 4, current_charge = 0, suit1 = "Spades", suit2 = "Clubs", ready = false, retriggers = 1 } },
	atlas = 'ModdedVanilla',
    chargeable = true,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        return { vars = { card.ability.extra.charge, card.ability.extra.current_charge, card.ability.extra.suit1, card.ability.extra.suit2, card.ability.extra.ready } }
    end,

    active = function(self, card)
        card.ability.extra.current_charge = 0
        card.ability.extra.ready = true
        play_sound('cloverpit_number_two')
        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Activated!", colour = G.C.BLUE})
    end,

    can_use_active = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND and card.ability.extra.charge == card.ability.extra.current_charge and not card.ability.extra.ready 
    end,

    calculate = function(self, card, context)
        if context.after and card.ability.extra.current_charge < card.ability.extra.charge then
            card.ability.extra.current_charge = card.ability.extra.current_charge + 1
            if card.ability.extra.current_charge == card.ability.extra.charge then
                local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
                juice_card_until(card, eval, true)
                return {
                    message = 'Ready!'
                }
            end
        end

        if context.setting_blind and card.ability.extra.current_charge == card.ability.extra.charge then
            local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
            return {
                message = 'Ready!'
            }
        end

        if context.repetition and context.cardarea == G.play and card.ability.extra.ready and 
            (context.other_card:is_suit(card.ability.extra.suit1) or context.other_card:is_suit(card.ability.extra.suit2)) then
            return {
                repetitions = card.ability.extra.retriggers
            }
        end

        if context.after and card.ability.extra.ready then
            card.ability.extra.ready = false
        end
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "pain_killers",
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    pos = { x = 6, y = 2 },
    config = { extra = { rank = 1 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rank } }
    end,

    calculate = function(self, card, context)

        if context.before and #context.full_hand == 1 then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    play_sound('cloverpit_pain_killers')
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    context.full_hand[1]:flip()
                    play_sound('card1')
                    context.full_hand[1]:juice_up(0.3, 0.3)
                    return true
                end
            }))

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    assert(SMODS.modify_rank(context.full_hand[1], 1))
                    return true
                end
            }))

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    context.full_hand[1]:flip()
                    play_sound('tarot2')
                    context.full_hand[1]:juice_up(0.3, 0.3)
                    return true
                end
            }))

        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "lost_wallet",
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    pos = { x = 7, y = 2 },
    config = { extra = { money = 15, repetitions = 0 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.money, math.floor(((G.GAME.dollars or 0) + (G.GAME.dollar_buffer or 0)) / card.ability.extra.money) }}
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card == context.scoring_hand[1] then
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('cloverpit_lost_wallet')
                    return true
                end
            }))
            return {
                repetitions = math.floor(((G.GAME.dollars or 0) + (G.GAME.dollar_buffer or 0)) / card.ability.extra.money)
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "calendar",
    blueprint_compat = false,
    rarity = 3,
    cost = 8,
    pos = { x = 8, y = 2 },
    config = { extra = { ready = false } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.ready } }
    end,

    calculate = function(self, card, context)
        if context.skip_blind and not card.ability.extra.ready then
            card.ability.extra.ready = true
            return {
                message = localize('k_active_ex')
            }
        end

        if context.end_of_round and context.main_eval and G.GAME.blind.boss and card.ability.extra.ready then
            local voucher_key = pseudorandom_element(G.P_CENTER_POOLS.Voucher, "calendar").key
            local voucher_card = SMODS.create_card{area = G.play, key = voucher_key}
            voucher_card:start_materialize()
            voucher_card.cost = 0
            G.play:emplace(voucher_card)
            play_sound('cloverpit_calendar')
            card:juice_up(0.3, 0.5)
            delay(0.8)
            voucher_card:redeem()
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.5,
                func = function()
                    voucher_card:start_dissolve()                
                    return true
                end
            }))
            card.ability.extra.ready = false
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "little_star",
    blueprint_compat = false,
    rarity = 1,
    cost = 6,
    pos = { x = 9, y = 2 },
    config = { extra = {  } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = {  } }
    end,

    calculate = function(self, card, context)
        if context.first_hand_drawn and not context.blueprint then
            local eval = function() return G.GAME.current_round.hands_played == 0 and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
        end

        if context.before and G.GAME.current_round.hands_played == 0 then
            local has_enhance = false
            for _, playing_card in ipairs(context.scoring_hand) do
                local enhancements = SMODS.get_enhancements(playing_card)
                for k, v in pairs(enhancements) do
                    if v then
                        has_enhance = true
                    end
                end
            end
            
            if has_enhance == false then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local enhancement_pool = {}
                        for _, enhancement in pairs(G.P_CENTER_POOLS.Enhanced) do
                            if enhancement.key ~= 'm_cloverpit_devilish' and enhancement.key ~= 'm_cloverpit_heavenly' then
                                enhancement_pool[#enhancement_pool + 1] = enhancement
                            end
                        end
                        local random_enhancement = pseudorandom_element(enhancement_pool, 'edit_card_enhancement')

                        play_sound('cloverpit_little_star')
                        context.scoring_hand[1]:juice_up(0.3, 0.5)
                        context.scoring_hand[1]:set_ability(random_enhancement)

                        return true
                    end
                }))

                return {
                    message = 'Enhanced!'
                }
            end
        end
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "fidelity_card",
    blueprint_compat = false,
    rarity = 1,
    cost = 6,
    pos = { x = 0, y = 3 },
    config = { extra = { percent = 20 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.percent }}
    end,

    add_to_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.discount_percent = G.GAME.discount_percent + card.ability.extra.percent
                for _, v in pairs(G.I.CARD) do
                    if v.set_cost then v:set_cost() end
                end
                return true
            end
        }))
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.discount_percent = G.GAME.discount_percent - card.ability.extra.percent
                for _, v in pairs(G.I.CARD) do
                    if v.set_cost then v:set_cost() end
                end
                return true
            end
        }))
    end, 

    calculate = function(self, card, context)
        if context.starting_shop then
            card:juice_up(0.3, 0.5)
            play_sound('cloverpit_fidelity_card')
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "sardines",
    blueprint_compat = false,
    rarity = 2,
    cost = 7,
    pos = { x = 1, y = 3 },
    config = { extra = { sell_value = 6 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.sell_value }}
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval  then
            local jokers = {}
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] ~= card then
                    jokers[#jokers + 1] = G.jokers.cards[i]
                end
            end
            if #jokers > 0 then
                local chosen_joker = pseudorandom_element(jokers, 'sardines')
                chosen_joker.ability.extra_value = (chosen_joker.ability.extra_value or 0) + card.ability.extra.sell_value
                chosen_joker:set_cost()
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_sardines')
                        return true
                    end
                }))
                card_eval_status_text(chosen_joker, 'extra', nil, nil, nil, {message = "+$"..tostring(card.ability.extra.sell_value).." Sell Value", colour = G.C.MONEY})
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "broken_calculator",
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 2, y = 3 },
    config = { extra = { odds = 3, repetitions = 1 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'broken_calculator')
        return { vars = { numerator, denominator, card.ability.extra.repetitions } }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and SMODS.pseudorandom_probability(card, 'broken_calculator', 1, card.ability.extra.odds) then
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('cloverpit_broken_calculator')
                    return true
                end
            }))
            return {
                repetitions = card.ability.extra.repetitions
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "the_collector",
    blueprint_compat = true,
    rarity = 3,
    cost = 7,
    pos = { x = 3, y = 3 },
    config = { extra = { xmult = 1, xmult_gain = 0.75 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_gain } }
    end,

    calculate = function(self, card, context)
        local joker_count = 0
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i].edition then
                joker_count = joker_count + 1
            end
        end
        card.ability.extra.xmult = 1 + (joker_count * card.ability.extra.xmult_gain)

        if context.joker_main then
            if context.cardarea == G.jokers and card.ability.extra.xmult > 1 then 
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_the_collector')
                        return true
                    end
                }))
            end

			return {
				xmult = card.ability.extra.xmult,
			}
		end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "channeler_of_fortune",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    pos = { x = 4, y = 3 },
    config = { extra = { triggers = 5, xmult = 1.5, tracker = 0 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.triggers, card.ability.extra.xmult, card.ability.extra.tracker } }
    end,

    calculate = function(self, card, context)
        if context.post_trigger and not context.blueprint then
            card.ability.extra.tracker = card.ability.extra.tracker + 1
        end

        if context.joker_main then
            if card.ability.extra.tracker >= card.ability.extra.triggers then 
                if not context.blueprint then 
                    card.ability.extra.tracker = -1
                end
                if context.cardarea == G.jokers then 
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('cloverpit_channeler_of_fortune')
                            return true
                        end
                    }))
                end
                    
                return {
                    xmult = card.ability.extra.xmult
                }    
            else
                if not context.blueprint then
                    card.ability.extra.tracker = 0
                end
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "nose",
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 5, y = 3 },
    config = { extra = { threshold = 3, count = 0 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.threshold, card.ability.extra.count } }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            if #context.full_hand < 4 and card.ability.extra.count < card.ability.extra.threshold and not context.blueprint then
                card.ability.extra.count = card.ability.extra.count + 1
            elseif #context.full_hand >= 4 then
                card.ability.extra.count = 0
            end

            if card.ability.extra.count == card.ability.extra.threshold then
                for i = 1, math.min(1, G.consumeables.config.card_limit - #G.consumeables.cards) do
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.4,
                        func = function()
                            play_sound('cloverpit_nose')
                            SMODS.add_card({ set = 'Tarot', edition = 'e_negative' })                            
                            card:juice_up(0.3, 0.5)
                            return true
                        end
                    }))
                end
                delay(0.6)
                return {
                    message = localize('k_plus_tarot')
                }
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "eye_jar",
    blueprint_compat = true,
    rarity = 2,
    cost = 5,
    pos = { x = 6, y = 3 },
    config = { extra = { threshold = 3, count = 0 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.threshold, card.ability.extra.count } }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            local all_face = (function()
                local count = 0
                for _, playing_card in pairs(context.full_hand or {}) do
                    if playing_card:is_face() then
                        count = count + 1
                    end
                end
                return count == 0
            end)()


            if card.ability.extra.count < 3 and all_face and not context.blueprint then
                card.ability.extra.count = card.ability.extra.count + 1
            elseif not all_face then
                card.ability.extra.count = 0
            end

            if card.ability.extra.count == 3 then
                for i = 1, math.min(1, G.consumeables.config.card_limit - #G.consumeables.cards) do
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.4,
                        func = function()
                            play_sound('cloverpit_eye_jar', 1, 0.4)
                            SMODS.add_card({ set = 'Planet', edition = 'e_negative' })                            
                            card:juice_up(0.3, 0.5)
                            return true
                        end
                    }))
                end
                delay(0.6)
                return {
                    message = localize('k_plus_planet')
                }
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "voicemail",
    blueprint_compat = true,
    rarity = 2,
    cost = 5,
    pos = { x = 7, y = 3 },
    config = { extra = { chips_mod = 10, chips = 0 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips_mod, card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.reroll_shop and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_mod
            play_sound('cloverpit_voicemail')
            return {
                message = localize('k_upgrade_ex')
            }
        end

        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "ring_bell",
    blueprint_compat = false,
    rarity = 1,
    cost = 5,
    pos = { x = 8, y = 3 },
    config = { extra = { charge = 3, current_charge = 0, mult = 0, mult_mod = 5 } },
	atlas = 'ModdedVanilla',
    chargeable = true,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        return { vars = { card.ability.extra.charge, card.ability.extra.current_charge, card.ability.extra.mult, card.ability.extra.mult_mod } }
    end,

    active = function(self, card)
        card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
        card.ability.extra.current_charge = 0
        play_sound('cloverpit_ring_bell')
        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Upgraded!", colour = G.C.RED})
    end,

    can_use_active = function(self, card)
        return card.ability.extra.charge == card.ability.extra.current_charge
    end,

    calculate = function(self, card, context)
        if context.after and card.ability.extra.current_charge < card.ability.extra.charge then
            card.ability.extra.current_charge = card.ability.extra.current_charge + 1
            if card.ability.extra.current_charge == card.ability.extra.charge then
                local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
                juice_card_until(card, eval, true)
                return {
                    message = 'Ready!'
                }
            end
        end

        if context.setting_blind and card.ability.extra.current_charge == card.ability.extra.charge then
            local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
            return {
                message = 'Ready!'
            }
        end

        if context.joker_main and card.ability.extra.mult > 0 then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "consolation_prize",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    pos = { x = 9, y = 3 },
    config = { extra = { odds = 4, mult = 0, mult_mod = 7 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'consolation_prize')
        return { vars = { numerator, denominator, card.ability.extra.mult, card.ability.extra.mult_mod } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint and SMODS.pseudorandom_probability(card, 'consolation_prize', 1, card.ability.extra.odds) then
            local has_enhance = false
            for _, playing_card in ipairs(context.scoring_hand) do
                local enhancements = SMODS.get_enhancements(playing_card)
                for k, v in pairs(enhancements) do
                    if v then
                        has_enhance = true
                    end
                end
            end
            
            if has_enhance == false then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_consolation_prize')
                        return true
                    end
                }))
                return {
                    message = localize('k_upgrade_ex')
                }
            end
        end

        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "dark_lotus",
    blueprint_compat = true,
    rarity = 3,
    cost = 7,
    pos = { x = 0, y = 4 },
    config = { extra = { xmult_mod = 0.1 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local sell_cost = 0
        for _, joker in ipairs(G.jokers and G.jokers.cards or {}) do
            if joker ~= card then
                sell_cost = sell_cost + joker.sell_cost
            end
        end
        return { vars = { card.ability.extra.xmult_mod, 1 + card.ability.extra.xmult_mod * sell_cost } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local sell_cost = 0
            for _, joker in ipairs(G.jokers.cards) do
                if joker ~= card then
                    sell_cost = sell_cost + joker.sell_cost
                end
            end
            if context.cardarea == G.jokers and sell_cost > 0 then 
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_dark_lotus')
                        return true
                    end
                }))
            end

            return {
                xmult = 1 + card.ability.extra.xmult_mod * sell_cost
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "weird_clock",
    blueprint_compat = false,
    rarity = 3,
    cost = 8,
    pos = { x = 1, y = 4 },
    config = { extra = { charge = 8, current_charge = 0, charge_increase = 8 } },
	atlas = 'ModdedVanilla',
    chargeable = true,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        return { vars = { card.ability.extra.charge, card.ability.extra.current_charge, card.ability.extra.charge_increase } }
    end,

    active = function(self, card)
        card.ability.extra.current_charge = 0
        card.ability.extra.charge = card.ability.extra.charge + card.ability.extra.charge_increase
        G.E_MANAGER:add_event(Event({
            blocking = false,
            func = function()
                play_sound('cloverpit_weird_clock')
                if G.STATE == G.STATES.SELECTING_HAND then
                    G.GAME.chips = G.GAME.blind.chips
                    G.STATE = G.STATES.HAND_PLAYED
                    G.STATE_COMPLETE = true
                    end_round()
                    return true
                end
            end
        }))
        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Win!", colour = G.C.GREEN})
    end,

    can_use_active = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND and card.ability.extra.charge == card.ability.extra.current_charge
    end,

    calculate = function(self, card, context)
        
        if context.after and card.ability.extra.current_charge < card.ability.extra.charge then
            card.ability.extra.current_charge = card.ability.extra.current_charge + 1
            if card.ability.extra.current_charge == card.ability.extra.charge then
                local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
                juice_card_until(card, eval, true)
                return {
                    message = 'Ready!'
                }
            end
        end

        if context.setting_blind and card.ability.extra.current_charge == card.ability.extra.charge then
            local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
            return {
                message = 'Ready!'
            }
        end
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "shopping_cart",
    blueprint_compat = false,
    rarity = 2,
    cost = 6,
    pos = { x = 2, y = 4 },
    config = { extra = {  } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { G.jokers and math.max(0, (G.jokers.config.card_limit - #G.jokers.cards)) or 1 } }
    end,

    calculate = function(self, card, context)
        if context.starting_shop then
            SMODS.change_free_rerolls(math.max(0, (G.jokers.config.card_limit - #G.jokers.cards)))
            play_sound('cloverpit_shopping_cart')
            card:juice_up(0.3, 0.5)
        end
        if context.ending_shop then
            SMODS.change_free_rerolls(-1 * math.max(0, (G.jokers.config.card_limit - #G.jokers.cards)))
        end
    end

}


------------------------------------------------------------

-- TODO
SMODS.Joker {
    key = "disca",
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    pos = { x = 3, y = 4 },
    config = { extra = { repetitions = 1, every = 5, turns_remaining = 5 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
				card.ability.extra.repetitions,
                card.ability.extra.every + 1,
				card.ability.extra.turns_remaining,
                localize { type = 'variable', key = (card.ability.extra.turns_remaining == 0 and 'loyalty_active' or 'loyalty_inactive'), vars = { card.ability.extra.turns_remaining } }
            }
        }
    end,
    calculate = function(self, card, context)

		if card.ability.extra.turns_remaining == 0 and context.repetition and context.cardarea == G.play then
			return {
                repetitions = card.ability.extra.repetitions
            }
        end

        if context.joker_main then
            card.ability.extra.turns_remaining = (card.ability.extra.every - 1 - (G.GAME.hands_played - card.ability.hands_played_at_create)) %
                (card.ability.extra.every + 1)
            if not context.blueprint then
                if card.ability.extra.turns_remaining == 0 then
                    local eval = function(card) return card.ability.extra.turns_remaining == 0 and not G.RESET_JIGGLES end
                    juice_card_until(card, eval, true)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('cloverpit_disc')
                            return true
                        end
                    }))
                end
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "discb",
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    pos = { x = 4, y = 4 },
    config = { extra = { chips = 77, every = 5, turns_remaining = 5 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
				card.ability.extra.chips,
                card.ability.extra.every + 1,
				card.ability.extra.turns_remaining,
                localize { type = 'variable', key = (card.ability.extra.turns_remaining == 0 and 'loyalty_active' or 'loyalty_inactive'), vars = { card.ability.extra.turns_remaining } }
            }
        }
    end,
    calculate = function(self, card, context)

		if card.ability.extra.turns_remaining == 0 and context.individual and context.cardarea == G.play then
			return {
                chips = card.ability.extra.chips
            }
        end

        if context.joker_main then
            card.ability.extra.turns_remaining = (card.ability.extra.every - 1 - (G.GAME.hands_played - card.ability.hands_played_at_create)) %
                (card.ability.extra.every + 1)
            if not context.blueprint then
                if card.ability.extra.turns_remaining == 0 then
                    local eval = function(card) return card.ability.extra.turns_remaining == 0 and not G.RESET_JIGGLES end
                    juice_card_until(card, eval, true)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('cloverpit_disc')
                            return true
                        end
                    }))
                end
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "discc",
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    pos = { x = 5, y = 4 },
    config = { extra = { consumeables = 1, every = 5, turns_remaining = 5 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
				card.ability.extra.consumeables,
                card.ability.extra.every + 1,
				card.ability.extra.turns_remaining,
                localize { type = 'variable', key = (card.ability.extra.turns_remaining == 0 and 'loyalty_active' or 'loyalty_inactive'), vars = { card.ability.extra.turns_remaining } }
            }
        }
    end,
    calculate = function(self, card, context)

		if ((not context.blueprint and card.ability.extra.turns_remaining == card.ability.extra.every) 
            or (context.blueprint and card.ability.extra.turns_remaining == 0 ) )  and context.cardarea == G.jokers and context.joker_main then
			for i = 1, math.min(card.ability.extra.consumeables, G.consumeables.config.card_limit - #G.consumeables.cards) do
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.4,
                    func = function()
                        play_sound('timpani')
                        local sets = {'Tarot', 'Planet', 'Spectral'}
                        local random_set = pseudorandom_element(sets, 'random_consumable_set')
                        SMODS.add_card({ set = random_set, })                            
                        card:juice_up(0.3, 0.5)
                        return true
                    end
                }))
            end
            delay(0.6)
        end

        if context.joker_main then
            card.ability.extra.turns_remaining = (card.ability.extra.every - 1 - (G.GAME.hands_played - card.ability.hands_played_at_create)) %
                (card.ability.extra.every + 1)
            if not context.blueprint then
                if card.ability.extra.turns_remaining == 0 then
                    local eval = function(card) return card.ability.extra.turns_remaining == 0 and not G.RESET_JIGGLES end
                    juice_card_until(card, eval, true)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('cloverpit_disc')
                            return true
                        end
                    }))
                end
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "cardboard_house",
    blueprint_compat = false,
    rarity = 1,
    cost = 2,
    pos = { x = 6, y = 4 },
    config = { extra = { joker_slots = 1 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.joker_slots }}
    end,

    add_to_deck = function(self, card, from_debuff)
        G.jokers.config.card_limit = G.jokers.config.card_limit + card.ability.extra.joker_slots
    end,
    
    remove_from_deck = function(self, card, from_debuff)
        G.jokers.config.card_limit = G.jokers.config.card_limit - card.ability.extra.joker_slots
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "electricity_meter",
    blueprint_compat = true,
    rarity = 3,
    cost = 8,
    pos = { x = 7, y = 4 },
    config = { extra = { } } ,
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        return { vars = { } }
    end,

    calculate = function(self, card, context)
        if context.reroll_shop then
            local valid_jokers = {}
            for i, joker in ipairs(G.jokers.cards) do
                if joker ~= card and joker.config.center.chargeable then
                    if joker.ability.extra.current_charge < joker.ability.extra.charge then
                        table.insert(valid_jokers, joker)
                    end
                end
            end

            local target_joker = #valid_jokers > 0 and pseudorandom_element(valid_jokers, pseudoseed('electricity_meter')) or nil
            local add_charge = 0
            if target_joker then
                play_sound('cloverpit_electricity_meter')
                card:juice_up(0.3, 0.5)
                if (target_joker.ability.extra.charge - target_joker.ability.extra.current_charge) % 2 == 1 then 
                    add_charge = (target_joker.ability.extra.charge - target_joker.ability.extra.current_charge + 1) / 2
                else 
                    add_charge = (target_joker.ability.extra.charge - target_joker.ability.extra.current_charge) / 2
                end

                target_joker.ability.extra.current_charge = target_joker.ability.extra.current_charge + add_charge
                card_eval_status_text(target_joker, 'extra', nil, nil, nil, {message = "+"..tostring(add_charge).." Charge", colour = G.C.ORANGE})

                if target_joker.ability.extra.current_charge == target_joker.ability.extra.charge then
                    local eval = function(target_joker) return target_joker.ability.extra.current_charge == target_joker.ability.extra.charge and not G.RESET_JIGGLES end
                    juice_card_until(target_joker, eval, true)
                    card_eval_status_text(target_joker, 'extra', nil, nil, nil, {message = "Ready!"})
                end
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "potato_battery",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    pos = { x = 8, y = 4 },
    config = { extra = { charge_add = 1 } } ,
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        return { vars = { card.ability.extra.charge_add } }
    end,

    calculate = function(self, card, context)
        if context.pre_discard then
            local valid_jokers = {}
            for i, joker in ipairs(G.jokers.cards) do
                if joker ~= card and joker.config.center.chargeable then
                    if joker.ability.extra.current_charge < joker.ability.extra.charge then
                        table.insert(valid_jokers, joker)
                    end
                end
            end

            local target_joker = #valid_jokers > 0 and pseudorandom_element(valid_jokers, pseudoseed('potato_battery')) or nil
            if target_joker then
                play_sound('cloverpit_potato_battery')
                card:juice_up(0.3, 0.5)
                target_joker.ability.extra.current_charge = target_joker.ability.extra.current_charge + card.ability.extra.charge_add
                card_eval_status_text(target_joker, 'extra', nil, nil, nil, {message = "+"..tostring(card.ability.extra.charge_add).." Charge", colour = G.C.ORANGE})

                if target_joker.ability.extra.current_charge == target_joker.ability.extra.charge then
                    local eval = function(target_joker) return target_joker.ability.extra.current_charge == target_joker.ability.extra.charge and not G.RESET_JIGGLES end
                    juice_card_until(target_joker, eval, true)
                    card_eval_status_text(target_joker, 'extra', nil, nil, nil, {message = "Ready!"})
                end
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "fake_coin",
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    pos = { x = 9, y = 4 },
    config = { extra = { odds = 9, hands = 1, mult = 50 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'fake_coin')
        return { vars = { numerator, denominator, card.ability.extra.hands, card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main and SMODS.pseudorandom_probability(card, 'fake_coin', 1, card.ability.extra.odds) then
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('cloverpit_hamsa')
                    return true
                end
            }))
            SMODS.calculate_effect({
                func = function()
                    card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "+"..tostring(card.ability.extra.hands).." Hands", colour = G.C.GREEN})
                    ease_hands_played(card.ability.extra.hands)
                    return true
                end}, card)
            return {
                mult = card.ability.extra.mult
            }
        end
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "ancient_coin",
    blueprint_compat = false,
    rarity = 2,
    cost = 6,
    pos = { x = 0, y = 5 },
    config = { extra = { charge = 1, current_charge = 0, odds = 8, discards = 1 } },
	atlas = 'ModdedVanilla',
    chargeable = true,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'ancient_coin')
        return { vars = { card.ability.extra.charge, card.ability.extra.current_charge, numerator, denominator, card.ability.extra.discards } }
    end,

    active = function(self, card)
        card.ability.extra.current_charge = 0
        play_sound('cloverpit_ancient_coin')
        ease_discard(card.ability.extra.discards)
        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "+1 Discard", colour = G.C.RED})
        if SMODS.pseudorandom_probability(card, 'ancient_coin', 1, card.ability.extra.odds) then
            local target_joker = card
            if target_joker then
                target_joker.getting_sliced = true
                G.E_MANAGER:add_event(Event({
                    func = function()
                        target_joker:start_dissolve({G.C.RED}, nil, 1.6)
                        return true
                    end
                }))
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Destroyed!", colour = G.C.RED})
            end
        end
    end,

    can_use_active = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND and card.ability.extra.charge == card.ability.extra.current_charge and not card.ability.extra.ready 
    end,

    calculate = function(self, card, context)
        if context.after and card.ability.extra.current_charge < card.ability.extra.charge then
            card.ability.extra.current_charge = card.ability.extra.current_charge + 1
            if card.ability.extra.current_charge == card.ability.extra.charge then
                local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
                juice_card_until(card, eval, true)
                return {
                    message = 'Ready!'
                }
            end
        end

        if context.setting_blind and card.ability.extra.current_charge == card.ability.extra.charge then
            local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
            return {
                message = 'Ready!'
            }
        end
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "cat_food",
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    pos = { x = 1, y = 5 },
    config = { extra = { hands = 1 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.hands}}
    end,

    calculate = function(self, card, context)
        if context.setting_blind  then
            return {
                func = function()
                    ease_hands_played(card.ability.extra.hands)
                    card:juice_up(0.3, 0.5)
                    play_sound('cloverpit_cat_food')
                    return true
                end,
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "depression",
    blueprint_compat = false,
    rarity = 4,
    cost = 20,
    pos = { x = 2, y = 5 },
    config = {  } ,
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {  }
    end,

    calculate = function(self, card, context)
        if context.mod_probability and not context.blueprint then
            return {
                numerator = context.denominator
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "toy_train",
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    pos = { x = 3, y = 5 },
    config = { extra = { mult = 10 } } ,
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if G.GAME.hands[context.scoring_name] and G.GAME.hands[context.scoring_name].played_this_round == 1 then
                if context.cardarea == G.jokers then 
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('cloverpit_toy_train')
                            return true
                        end
                    }))
                end
                return {
                    mult = card.ability.extra.mult
                }
            end
        end
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "steam_locomotive",
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 4, y = 5 },
    config = { extra = { xchips = 1, xchips_mod = 0.1, all_unique = true } } ,
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xchips, card.ability.extra.xchips_mod, card.ability.extra.all_unique } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if G.GAME.hands[context.scoring_name] and G.GAME.hands[context.scoring_name].played_this_round ~= 1 then
                card.ability.extra.all_unique = false
            end

            if card.ability.extra.xchips > 1 then
                return {
                    xchips = card.ability.extra.xchips
                }
            end
        end

        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            if card.ability.extra.all_unique then
                card.ability.extra.xchips = card.ability.extra.xchips + card.ability.extra.xchips_mod
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_steam_locomotive')
                        return true
                    end
                }))
                returns {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.CHIPS
                }
            else
                card.ability.extra.all_unique = true 
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "diesel_locomotive",
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 5, y = 5 },
    config = { extra = { chips = 0, chips_mod = 20, all_unique = true } } ,
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.chips_mod, card.ability.extra.all_unique } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if G.GAME.hands[context.scoring_name] and G.GAME.hands[context.scoring_name].played_this_round ~= 1 then
                card.ability.extra.all_unique = false
            end

            if card.ability.extra.chips > 1 then
                return {
                    chips = card.ability.extra.chips
                }
            end
        end

        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            if card.ability.extra.all_unique then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_mod
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_diesel_locomotive')
                        return true
                    end
                }))
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.CHIPS
                }
            else
                card.ability.extra.all_unique = true 
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'cloverpot',
    blueprint_compat = false,
    rarity = 1,
    cost = 5,
    pos = { x = 6, y = 5 },
    config = {  } ,
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {vars = {(G.GAME.round_resets.ante or 0)}}
    end,

    calc_dollar_bonus = function(card)
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('cloverpit_clover_pot')
                return true
            end
        }))
        local blind_reward = 0
        blind_reward = blind_reward + math.max(G.GAME.round_resets.ante, 0)
        if blind_reward > 0 then
            return blind_reward
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'cloverpet',
    blueprint_compat = true,
	rarity = 2,
    cost = 6,
    pos = { x = 7, y = 5 },
    config = { extra = { xmult_starting = 1, xmult = 0.02, dollars = 1} },
    atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.dollars, card.ability.extra.xmult_starting + card.ability.extra.xmult * math.floor(((G.GAME.dollars or 0) + (G.GAME.dollar_buffer or 0)) / card.ability.extra.dollars) } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if context.cardarea == G.jokers and math.floor(((G.GAME.dollars or 0) + (G.GAME.dollar_buffer or 0)) / card.ability.extra.dollars) > 0 then 
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_clover_pet')
                        return true
                    end
                }))
            end
            return {
                xmult = card.ability.extra.xmult_starting + card.ability.extra.xmult * math.floor(((G.GAME.dollars or 0) + (G.GAME.dollar_buffer or 0)) / card.ability.extra.dollars)
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "cloverfield",
    blueprint_compat = false,
    rarity = 1,
    cost = 5,
    pos = { x = 8, y = 5 },
    config = { extra = { money = 3 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money } }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint and #G.consumeables.cards > 0 then
            for _, other_card in ipairs(G.consumeables.cards) do
                if other_card.set_cost then
                    other_card.ability.extra_value = (other_card.ability.extra_value or 0) +
                        card.ability.extra.money
                    other_card:set_cost()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('cloverpit_clover_field')
                            card:juice_up(0.3, 0.5)
                            return true
                        end
                    }))
                    card_eval_status_text(other_card, 'extra', nil, nil, nil, {message = localize('k_val_up'), colour = G.C.MONEY})
                end
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'mushrooms',
	config = { extra = { mult = 1, mult_mod = 1 } },
	rarity = 1,
    cost = 4,
	atlas = 'ModdedVanilla',
	pos = { x = 9, y = 5 },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, card.ability.extra.mult_mod } }
	end,

	calculate = function(self, card, context)
        if context.after then
            card.ability.extra.mult = 1
            if context.cardarea == G.jokers then 
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_mushrooms', 1, 0.4)
                        return true
                    end
                }))
            end
            return {
                message = localize('k_reset')
            }
        end

		if context.individual and context.cardarea == G.play then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
            return {
                mult = card.ability.extra.mult - 1
            }
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
    key = "vines_soup",
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    pos = { x = 0, y = 6 },
    config = { extra = { threshold = 6, mult = 40, counter = 0 } } ,
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.threshold, card.ability.extra.mult, card.ability.extra.counter } }
    end,

    calculate = function(self, card, context)
        if context.before then 
            card.ability.extra.counter = 0
        end

        if context.individual and context.cardarea == G.play and not context.blueprint then
            card.ability.extra.counter = card.ability.extra.counter + 1
        end

        if context.joker_main then
            if card.ability.extra.counter >= card.ability.extra.threshold then
                if context.cardarea == G.jokers then 
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('cloverpit_vine_soup')
                            return true
                        end
                    }))
                end
                return {
                    mult = card.ability.extra.mult
                }
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "very_big_mushroom",
    blueprint_compat = true,
    rarity = 3,
    cost = 8,
    pos = { x = 1, y = 6 },
    config = { extra = { threshold = 12, pow_mult = 1.2, counter = 0 } } ,
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.threshold, card.ability.extra.pow_mult, card.ability.extra.counter } }
    end,

    calculate = function(self, card, context)
        if context.before then 
            card.ability.extra.counter = 0
        end

        if context.individual and context.cardarea == G.play and not context.blueprint  then
            card.ability.extra.counter = card.ability.extra.counter + 1
        end

        if context.joker_main then
            if card.ability.extra.counter >= card.ability.extra.threshold then
                if context.cardarea == G.jokers then 
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('cloverpit_very_big_mushroom')
                            return true
                        end
                    }))
                end
                return {
                    pow_mult = card.ability.extra.pow_mult
                }
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "abyssu",
    blueprint_compat = false,
    rarity = 1,
    cost = 4,
    pos = { x = 2, y = 6 },
    config = { },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local last = G.GAME.last_tag_sold and G.P_CENTERS[G.GAME.last_tag_sold] or nil
        local last_tag_sold = last and localize { type = 'name_text', key = last.key, set = last.set } or
            localize('k_none')
        return { vars = { G.GAME.last_tag_added or localize('k_none') } }
    end,

    calculate = function(self, card, context)
        if context.tag_added then
            G.GAME.last_tag_added = context.tag_added.key
        end
	end,

    can_use_active = function(self, card)
        return G.GAME.last_tag_added
    end,

    active = function(self, card)
        G.E_MANAGER:add_event(Event({
            func = function()
                local tag = Tag(G.GAME.last_tag_added)
                if tag.name == "Orbital Tag" then
                    local _poker_hands = {}
                    for k, v in pairs(G.GAME.hands) do
                        if v.visible then
                            _poker_hands[#_poker_hands + 1] = k
                        end
                    end
                    tag.ability.orbital_hand = pseudorandom_element(_poker_hands, "abyssu")
                end
                tag:set_ability()
                add_tag(tag)
                play_sound('cloverpit_dark_gurgle')
                play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                return true
            end
        }))

        local target_joker = card
        if target_joker then
            target_joker.getting_sliced = true
            G.E_MANAGER:add_event(Event({
                func = function()
                    target_joker:start_dissolve({G.C.RED}, nil, 1.6)
                    return true
                end
            }))
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Destroyed!", colour = G.C.RED})
        end
        return true
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "vorago",
    blueprint_compat = false,
    rarity = 1,
    cost = 6,
    pos = { x = 3, y = 6 },
    config = { },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local last = G.GAME.last_joker_sold and G.P_CENTERS[G.GAME.last_joker_sold] or nil
        local last_joker_sold = last and localize { type = 'name_text', key = last.key, set = last.set } or
            localize('k_none')
        return { vars = { last_joker_sold } }
    end,

    calculate = function(self, card, context)
        if context.selling_card and context.card.config.center.set == 'Joker' and context.card.config.center_key ~= 'j_cloverpit_vorago' then
            G.GAME.last_joker_sold = context.card.config.center_key
        end
	end,

    can_use_active = function(self, card)
        if card.edition then
            if card.edition.negative then
                return G.GAME.last_joker_sold and #G.jokers.cards < G.jokers.config.card_limit
            else
                return  G.GAME.last_joker_sold
            end
        else
            return G.GAME.last_joker_sold
        end
    end,

    active = function(self, card)
        local created_joker = false
        created_joker = true
        G.GAME.joker_buffer = G.GAME.joker_buffer + 1
        G.E_MANAGER:add_event(Event({
            func = function()
                local joker_card = SMODS.add_card({ set = 'Joker', key = G.GAME.last_joker_sold })
                G.GAME.joker_buffer = 0
                return true
            end
        }))
        card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_plus_joker'), colour = G.C.BLUE})

        local target_joker = card
        if target_joker then
            target_joker.getting_sliced = true
            G.E_MANAGER:add_event(Event({
                func = function()
                    target_joker:start_dissolve({G.C.RED}, nil, 1.6)
                    return true
                end
            }))
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Destroyed!", colour = G.C.RED})
        end
        play_sound('cloverpit_dark_gurgle')
        return true
    end
    
}


------------------------------------------------------------


SMODS.Joker {
    key = "barathrum",
    blueprint_compat = false,
    rarity = 1,
    cost = 4,
    pos = { x = 4, y = 6 },
    config = { },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local last = G.GAME.last_consumable and G.P_CENTERS[G.GAME.last_consumable] or nil
        local last_consumable = last and localize { type = 'name_text', key = last.key, set = last.set } or
            localize('k_none')
        return { vars = { last_consumable } }
    end,

    calculate = function(self, card, context)
        if context.consumeable then
            G.GAME.last_consumable = context.consumeable.config.center_key
        end
	end,

    can_use_active = function(self, card)
        return G.GAME.last_consumable and G.consumeables.config.card_limit > #G.consumeables.cards
    end,

    active = function(self, card)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                SMODS.add_card({ key = G.GAME.last_consumable})                            
                card:juice_up(0.3, 0.5)
                return true
            end
        }))

        local target_joker = card
        if target_joker then
            target_joker.getting_sliced = true
            G.E_MANAGER:add_event(Event({
                func = function()
                    target_joker:start_dissolve({G.C.RED}, nil, 1.6)
                    return true
                end
            }))
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Destroyed!", colour = G.C.RED})
        end
        play_sound('cloverpit_dark_gurgle')
        return true
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "stain",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    pos = { x = 5, y = 6 },
    config = { extra = { type = 'Three of a Kind', chips = 50 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { localize(card.ability.extra.type, 'poker_hands'), card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.joker_main and not next(context.poker_hands[card.ability.extra.type]) then
            if context.cardarea == G.jokers then 
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_paper')
                        return true
                    end
                }))
            end

            return {
                chips = card.ability.extra.chips
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "abstract_painting",
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 6, y = 6 },
    config = { extra = { type = 'Flush', xmult = 2 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { localize(card.ability.extra.type, 'poker_hands'), card.ability.extra.xmult } }
    end,

    calculate = function(self, card, context)
        if context.joker_main and not next(context.poker_hands[card.ability.extra.type]) then
            if context.cardarea == G.jokers then 
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_paper')
                        return true
                    end
                }))
            end
            return {
                xmult = card.ability.extra.xmult
            }
        end

    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "pareidolia",
    blueprint_compat = true,
    rarity = 3,
    cost = 7,
    pos = { x = 7, y = 6 },
    config = { extra = { type = 'Four of a Kind' } } ,
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { localize(card.ability.extra.type, 'poker_hands') } }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            if next(context.poker_hands[card.ability.extra.type]) then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_pareidolia')
                        return true
                    end
                }))

                update_hand_text({ sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3 },
                    { handname = localize('k_all_hands'), chips = '...', mult = '...', level = '' })
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
                update_hand_text({ sound = 'button', volume = 0.7, pitch = 0.9, delay = 0 }, { level = '+1' })
                SMODS.upgrade_poker_hands({ instant = true })
                update_hand_text({ sound = 'button', volume = 0.7, pitch = 1.1, delay = 0 },
                    { mult = 0, chips = 0, handname = '', level = '' })
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "hourglass",
    blueprint_compat = true,
    rarity = 2,
    cost = 5,
    pos = { x = 8, y = 6 },
    config = { extra = { xmult = 1, xchips = 1, xmult_mod = 0.1, xchips_mod = 0.1 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xchips, card.ability.extra.xmult_mod, card.ability.extra.xchips_mod } }
    end,

    calculate = function(self, card, context)
        if context.skip_blind and not context.blueprint then
            card.ability.extra.xchips = card.ability.extra.xchips + card.ability.extra.xchips_mod
            play_sound('cloverpit_hourglass')
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS 
            }
        end

        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_mod
            play_sound('cloverpit_hourglass')
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.MULT 
            }
        end

        if context.cardarea == G.jokers and context.joker_main then
            return {
                xmult = card.ability.extra.xmult,
                xchips = card.ability.extra.xchips
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "fruit_basket",
    blueprint_compat = true,
    rarity = 2,
    cost = 5,
    pos = { x = 9, y = 6 },
    config = { extra = { retriggers = 1, suit = 'Hearts' } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.retriggers, localize(card.ability.extra.suit, 'suits_singular') } }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card:is_suit(card.ability.extra.suit) and G.GAME.current_round.hands_played == 0 then
            return {
                repetitions = card.ability.extra.retriggers
            }
        end
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "seven_sins_stone",
    blueprint_compat = true,
    rarity = 2,
    cost = 5,
    pos = { x = 0, y = 7 },
    config = { extra = { threshold = 7, suit = 'Spades', mult = 7, mult_mod = 7 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.threshold, localize(card.ability.extra.suit, 'suits_singular'),
                          card.ability.extra.mult, card.ability.extra.mult_mod } }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main and not context.blueprint then
            local suit_count = 0
            for _, playing_card in ipairs(context.scoring_hand) do
                if playing_card:is_suit(card.ability.extra.suit) then
                    suit_count = suit_count + 1
                end
            end

            for _, playing_card in ipairs(G.hand.cards) do
                if playing_card:is_suit(card.ability.extra.suit) then
                    suit_count = suit_count + 1
                end
            end          

            if suit_count >= 7 then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
                return {
                    message = localize('k_upgrade_ex')
                }
            end
		end

        if context.individual and context.cardarea == G.play and card.ability.extra.mult > 0 and
            context.other_card:is_suit(card.ability.extra.suit) then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "necklace",
    blueprint_compat = true,
    rarity = 2,
    cost = 5,
    pos = { x = 1, y = 7 },
    config = { extra = { retriggers = 2, suit = 'Diamonds' } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.retriggers, localize(card.ability.extra.suit, 'suits_singular') } }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.hand and (next(context.card_effects[1]) or #context.card_effects > 1)
            and context.other_card:is_suit(card.ability.extra.suit) then
            return {
                repetitions = card.ability.extra.retriggers
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "cloverbell",
    blueprint_compat = false,
    rarity = 2,
    cost = 5,
    pos = { x = 2, y = 7 },
    config = { extra = { threshold = 5, suit = 'Clubs', rerolls = 0, suit_count = 0 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.threshold, localize(card.ability.extra.suit, 'suits_singular'), card.ability.extra.rerolls } }
    end,

    calculate = function(self, card, context)
        if context.before then
            card.ability.extra.suit_count = 0
        end

        if context.individual and context.cardarea == G.play and context.other_card:is_suit(card.ability.extra.suit) then
            card.ability.extra.suit_count = card.ability.extra.suit_count + 1
        end

        if context.after and not context.blueprint then
            if card.ability.extra.suit_count >= card.ability.extra.threshold then
                card.ability.extra.rerolls = card.ability.extra.rerolls + 1
                return {
                    message = 'Free reroll!'
                }
            end
        end

        if context.starting_shop then
            SMODS.change_free_rerolls(card.ability.extra.rerolls)
        end

        if context.ending_shop then
            SMODS.change_free_rerolls(-1 * card.ability.extra.rerolls)
            card.ability.extra.rerolls = 0
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "red_pepper",
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    pos = { x = 3, y = 7 },
    config = { extra = { odds = 4, mult = 30 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'red_pepper')
        return { vars = { numerator, denominator, card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main and SMODS.pseudorandom_probability(card, 'red_pepper', 1, card.ability.extra.odds) then
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('cloverpit_pepper')
                    return true
                end
            }))
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "green_pepper",
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    pos = { x = 4, y = 7 },
    config = { extra = { odds = 4, chips = 120 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'green_pepper')
        return { vars = { numerator, denominator, card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main and SMODS.pseudorandom_probability(card, 'green_pepper', 1, card.ability.extra.odds) then
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('cloverpit_pepper')
                    return true
                end
            }))
            return {
                chips = card.ability.extra.chips
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "rotten_pepper",
    blueprint_compat = true,
    rarity = 2,
    cost = 5,
    pos = { x = 5, y = 7 },
    config = { extra = { odds = 4, chips = 10, chip_mod = 10, type = 'Pair' } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'rotten_pepper')
        return { vars = { numerator, denominator, card.ability.extra.chips, card.ability.extra.chip_mod, localize(card.ability.extra.type, 'poker_hands') } }
    end,

    calculate = function(self, card, context)
        if context.joker_main and not next(context.poker_hands['Pair']) and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
            return {
                message = localize('k_upgrade_ex')
            }
        end

        if context.cardarea == G.jokers and context.joker_main and SMODS.pseudorandom_probability(card, 'rotten_pepper', 1, card.ability.extra.odds) then
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('cloverpit_pepper')
                    return true
                end
            }))
            return {
                chips = card.ability.extra.chips
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "bell_pepper",
    blueprint_compat = true,
    rarity = 2,
    cost = 5,
    pos = { x = 6, y = 7 },
    config = { extra = { odds = 4, xmult = 1.1, xmult_mod = 0.1 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'bell_pepper')
        return { vars = { numerator, denominator, card.ability.extra.xmult, card.ability.extra.xmult_mod } }
    end,

    calculate = function(self, card, context)
        if context.reroll_shop and not context.blueprint then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_mod
            return {
                message = localize('k_upgrade_ex')
            }
        end

        if context.cardarea == G.jokers and context.joker_main and SMODS.pseudorandom_probability(card, 'bell_pepper', 1, card.ability.extra.odds) then
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('cloverpit_pepper')
                    return true
                end
            }))
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "golden_pepper",
    blueprint_compat = true,
    rarity = 2,
    cost = 5,
    pos = { x = 7, y = 7 },
    config = { extra = { odds = 4, mult = 25, mult_mod = 25 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'golden_pepper')
        return { vars = { numerator, denominator, card.ability.extra.mult, card.ability.extra.mult_mod } }
    end,

    calculate = function(self, card, context)
        if context.skip_blind and not context.blueprint then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
            return {
                message = localize('k_upgrade_ex')
            }
        end

        if context.cardarea == G.jokers and context.joker_main and SMODS.pseudorandom_probability(card, 'bell_pepper', 1, card.ability.extra.odds) then
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('cloverpit_pepper')
                    return true
                end
            }))
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "demons_horn",
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 8, y = 7 },
    config = { },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_cloverpit_devilish
        return { vars = { } }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            local has_devil = false
            for _, playing_card in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(playing_card, 'm_cloverpit_devilish') then
                    has_devil = true
                end
            end

            if has_devil == true then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_devil_horn')
                        return true
                    end
                }))
                return {
                    message = localize('k_level_up_ex'),
                    level_up = true
                }
            end
		end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "necronomicon",
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 9, y = 7 },
    config = { extra = { xmult_starting = 1, xmult = 0.3 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_cloverpit_devilish
        local devil_tally = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_cloverpit_devilish') then devil_tally = devil_tally + 1 end
            end
        end
        return {vars = { card.ability.extra.xmult, 1 + card.ability.extra.xmult * devil_tally }}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local devil_tally = 0
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_cloverpit_devilish') then devil_tally = devil_tally + 1 end
            end
            if devil_tally > 0 and context.cardarea == G.jokers then 
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_evil')
                        return true
                    end
                }))
            end

            return {
                Xmult = 1 + card.ability.extra.xmult * devil_tally,
            }
        end
    end,

    in_pool = function(self, args) 
        for _, playing_card in ipairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(playing_card, 'm_cloverpit_devilish') then
                return true
            end
        end
        return false
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "holy_bible",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    pos = { x = 0, y = 8 },
    config = { extra = { odds = 2 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_cloverpit_devilish
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'holy_bible')
        return { vars = { numerator, denominator } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local has_devil = false
            for _, playing_card in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(playing_card, 'm_cloverpit_devilish') then
                    has_devil = true
                end
            end

            if has_devil == true and SMODS.pseudorandom_probability(card, 'holy_bible', 1, card.ability.extra.odds) then
                for i = 1, math.min(1, G.consumeables.config.card_limit - #G.consumeables.cards) do
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.4,
                        func = function()
                            play_sound('cloverpit_holy')
                            SMODS.add_card({ set = 'Spectral', })                            
                            card:juice_up(0.3, 0.5)
                            return true
                        end
                    }))
                end
                delay(0.6)
                return {
                    message = created_consumable and localize('k_plus_spectral') or nil
                }
            end
            return true
		end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "baphomet",
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 1, y = 8 },
    config = { extra = { chips = 0, mult = 0, chips_sub = -11, mult_sub = -1 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_cloverpit_devilish
        return {vars = { card.ability.extra.chips, card.ability.extra.mult, card.ability.extra.chips_sub, card.ability.extra.mult_sub }}
    end,
    calculate = function(self, card, context)
        if ((context.individual and context.cardarea == G.play) or (context.individual and context.cardarea == G.hand and not context.end_of_round)) and not context.blueprint then
            if SMODS.has_enhancement(context.other_card, 'm_cloverpit_devilish') then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_sub
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_sub
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_baphomet')
                        card:juice_up(0.3, 0.5)
                        return true
                    end
                }))
            end
        end

        if context.joker_main then 
            return {
                chips = card.ability.extra.chips,
                mult = card.ability.extra.mult
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "cross",
    blueprint_compat = true,
    rarity = 3,
    cost = 6,
    pos = { x = 2, y = 8 },
    config = { extra = { charge = 2, current_charge = 0, chips = -666, xmult = 3, mult = -66, xchips = 3, state = 1} },
	atlas = 'ModdedVanilla',
    chargeable = true,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_cloverpit_devilish
        return { vars = { card.ability.extra.charge, card.ability.extra.current_charge, card.ability.extra.xchips, card.ability.extra.mult,
                          card.ability.extra.chips, card.ability.extra.xmult, card.ability.extra.state } }
    end,

    active = function(self, card)
        card.ability.extra.current_charge = 0
        card.ability.extra.state = 3 - card.ability.extra.state
        card_eval_status_text(card, 'extra', nil, nil, nil, {message = 'Flipped!', colour = G.C.RED})
        if card.ability.extra.state == 1 then 
            play_sound('cloverpit_evil')
        else 
            play_sound('cloverpit_holy')
        end
    end,

    can_use_active = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND and card.ability.extra.charge == card.ability.extra.current_charge
    end,

    calculate = function(self, card, context)
        if context.after and card.ability.extra.current_charge < card.ability.extra.charge and not context.blueprint then
            card.ability.extra.current_charge = card.ability.extra.current_charge + 1
            if card.ability.extra.current_charge == card.ability.extra.charge then
                local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
                juice_card_until(card, eval, true)
                return {
                    message = 'Ready!'
                }
            end
        end

        if context.setting_blind and card.ability.extra.current_charge == card.ability.extra.charge and not context.blueprint then
            local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
            return {
                message = 'Ready!'
            }
        end

        if context.joker_main then 
            if card.ability.extra.state == 1 then
                return {
                    xchips = card.ability.extra.xchips,
                    mult = card.ability.extra.mult
                }
            else
                return {
                    chips = card.ability.extra.chips,
                    xmult = card.ability.extra.xmult
                }
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "rosary",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    pos = { x = 3, y = 8 },
    config = { extra = { odds = 3 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_cloverpit_devilish
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'rosary')
        return { vars = { numerator, denominator } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play  then
            if SMODS.has_enhancement(context.other_card, 'm_cloverpit_devilish') and SMODS.pseudorandom_probability(card, 'rosary', 1, card.ability.extra.odds)  then
                local card_front = pseudorandom_element(G.P_CARDS, pseudoseed('rosary'))
                local base_card = create_playing_card({
                    front = card_front,
                    center = G.P_CENTERS.c_base
                }, G.discard, true, false, nil, true)
                
                base_card:set_edition(pseudorandom_element({'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                    'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome'}, pseudoseed('rosary')), true)
                
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
                        play_sound('cloverpit_holy')
                        return true
                    end
                }))
                return {
                    message = "Added Card!"
                }
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "book_of_shadows",
    blueprint_compat = true,
    rarity = 3,
    cost = 6,
    pos = { x = 4, y = 8 },
    config = { extra = { hands = 1 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_cloverpit_devilish
        return { vars = { card.ability.extra.hands } }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            local has_devil = false
            for _, playing_card in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(playing_card, 'm_cloverpit_devilish') then
                    has_devil = true
                end
            end

            if has_devil == true then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_evil')
                        card:juice_up(0.3, 0.5)
                        return true
                    end
                }))
                return {
                    func = function()
                        ease_hands_played(card.ability.extra.hands)
                        card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "+"..tostring(card.ability.extra.hands).." Hands", colour = G.C.GREEN})
                        return true
                    end
                }
            end
		end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "gabihbbh",
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    pos = { x = 5, y = 8 },
    config = { extra = { xmult = 3 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_cloverpit_devilish
        return { vars = { card.ability.extra.xmult } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local has_devil = false
            for _, playing_card in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(playing_card, 'm_cloverpit_devilish') then
                    has_devil = true
                end
            end

            if has_devil then
                if context.cardarea == G.jokers then 
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('cloverpit_gabihbbh')
                            return true
                        end
                    }))
                end
                return {
                    xmult = card.ability.extra.xmult,
                }
            end
		end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "possessed_cell_phone",
    blueprint_compat = false,
    rarity = 2,
    cost = 6,
    pos = { x = 6, y = 8 },
    config = { extra = { charge = 6, current_charge = 0} },
	atlas = 'ModdedVanilla',
    chargeable = true,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        info_queue[#info_queue + 1] = G.P_CENTERS.m_cloverpit_devilish
        return { vars = { card.ability.extra.charge, card.ability.extra.current_charge, card.ability.extra.draw } }
    end,

    active = function(self, card)
        card.ability.extra.current_charge = 0
        local card_front = pseudorandom_element(G.P_CARDS, pseudoseed('possessed_cell_phone'))
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
        play_sound('cloverpit_possessed_cellphone')
        card_eval_status_text(card, 'extra', nil, nil, nil, {message = 'Called!', colour = G.C.RED})
        
    end,

    can_use_active = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND and card.ability.extra.charge == card.ability.extra.current_charge
    end,

    calculate = function(self, card, context)
        if context.after and card.ability.extra.current_charge < card.ability.extra.charge then
            card.ability.extra.current_charge = card.ability.extra.current_charge + 1
            if card.ability.extra.current_charge == card.ability.extra.charge then
                local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
                juice_card_until(card, eval, true)
                return {
                    message = 'Ready!'
                }
            end
        end

        if context.setting_blind and card.ability.extra.current_charge == card.ability.extra.charge then
            local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
            return {
                message = 'Ready!'
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "magical_tomato",
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    pos = { x = 7, y = 8 },
    config = { extra = { repetitions = 1 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_cloverpit_devilish
        local devil_tally = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_cloverpit_devilish') then devil_tally = devil_tally + 1 end
            end
        end
        return {vars = { card.ability.extra.minus_mult,  devil_tally }}
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and (
                context.other_card:get_id() == 2 or
                context.other_card:get_id() == 3 or
                context.other_card:get_id() == 4 or
                context.other_card:get_id() == 5 ) then
            local devil_tally = 0
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_cloverpit_devilish') then devil_tally = devil_tally + 1 end
            end
            play_sound('cloverpit_magical_tomato')
            card:juice_up(0.3, 0.5)
            return {
                repetitions = devil_tally
            }
        end
        
    end,

    in_pool = function(self, args) 
        for _, playing_card in ipairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(playing_card, 'm_cloverpit_devilish') then
                return true
            end
        end
        return false
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "ritual_bell",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    pos = { x = 8, y = 8 },
    config = { extra = { dollars_played = 2, dollars_held = 3 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_cloverpit_devilish
        return {vars = { card.ability.extra.dollars_played, card.ability.extra.dollars_held }}
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if SMODS.has_enhancement(context.other_card, 'm_cloverpit_devilish') then
                G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars_played
                return {
                    dollars = card.ability.extra.dollars_played,
                    func = function() 
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.GAME.dollar_buffer = 0
                                play_sound('cloverpit_ritual_bell')
                                return true
                            end
                        }))
                    end
                }
            end
        end
        if context.individual and context.cardarea == G.hand and not context.end_of_round  then
            if SMODS.has_enhancement(context.other_card, 'm_cloverpit_devilish') then
                G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars_held
                return {
                    dollars = card.ability.extra.dollars_held,
                    func = function() 
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.GAME.dollar_buffer = 0
                                play_sound('cloverpit_ritual_bell')
                                return true
                            end
                        }))
                    end
                }
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "crystal_skull",
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    pos = { x = 9, y = 8 },
    config = { extra = { minus_mult = -6 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_cloverpit_devilish
        local devil_tally = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_cloverpit_devilish') then devil_tally = devil_tally + 1 end
            end
        end
        return {vars = { card.ability.extra.minus_mult, card.ability.extra.minus_mult * devil_tally }}
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_face() then
            local devil_tally = 0
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_cloverpit_devilish') then devil_tally = devil_tally + 1 end
            end
            if devil_tally > 0 then 
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.GAME.dollar_buffer = 0
                        play_sound('cloverpit_crystal_skull', 1, 0.4)
                        return true
                    end
                }))
            end
            return {
                mult = card.ability.extra.minus_mult * devil_tally
            }
        end
        
    end,

    in_pool = function(self, args) 
        for _, playing_card in ipairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(playing_card, 'm_cloverpit_devilish') then
                return true
            end
        end
        return false
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "evil_deal",
    blueprint_compat = true,
    rarity = 4,
    cost = 20,
    pos = { x = 0, y = 9 },
    config = { extra = { xchips = 2, xmult = 3, dollars = 6, rerolls = 2 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_cloverpit_devilish
        return { vars = { card.ability.extra.xchips, card.ability.extra.xmult, card.ability.extra.dollars, card.ability.extra.rerolls } }
    end,

    calc_dollar_bonus = function(self, card)
        return card.ability.extra.dollars
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.GAME.dollar_buffer = 0
                    play_sound('cloverpit_evil_deal')
                    return true
                end
            }))
            return {
                xmult = card.ability.extra.xmult,
                xchips = card.ability.extra.xchips
            }
        end

        if context.end_of_round and context.main_eval and not context.blueprint then
            local card_front = pseudorandom_element(G.P_CARDS, pseudoseed('evil_deal'))
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
            return {
                func = function()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.deck.config.card_limit = G.deck.config.card_limit + 1
                            return true
                        end
                    }))
                    draw_card(G.play, G.deck, 90, 'up')
                    SMODS.calculate_context({ playing_card_added = true, cards = { base_card } })
                end,
                message = "Added Card!"
            }
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        SMODS.change_free_rerolls(card.ability.extra.rerolls)
    end,
    
    remove_from_deck = function(self, card, from_debuff)
        SMODS.change_free_rerolls(-(card.ability.extra.rerolls))
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "chastity_belt",
    blueprint_compat = true,
    rarity = 3,
    cost = 6,
    pos = { x = 1, y = 9 },
    config = { extra = { xmult = 1, xmult_mod = 0.66 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_mod } }
    end,

    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            if SMODS.get_enhancements(context.other_card)["m_cloverpit_devilish"] == true then
                card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_mod
                play_sound('cloverpit_chastity_belt')
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.MULT
                }
            end
        end

        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "lemon_picture",
    blueprint_compat = false,
    rarity = 1,
    cost = 4,
    pos = { x = 2, y = 9 },
    config = { extra = { charge = 4, current_charge = 0, rank1 = 2, rank2 = 3 } },
	atlas = 'ModdedVanilla',
    chargeable = true,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        return { vars = { card.ability.extra.charge, card.ability.extra.current_charge, card.ability.extra.rank1, card.ability.extra.rank2 } }
    end,

    active = function(self, card)
        local _card = SMODS.create_card { set = "Base", rank = pseudorandom_element({card.ability.extra.rank1, card.ability.extra.rank2}, pseudoseed("lemon_picture")) }
        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
        _card.playing_card = G.playing_card
        table.insert(G.playing_cards, _card)
        play_sound('cloverpit_photo')

        G.E_MANAGER:add_event(Event({
            func = function()
                G.hand:emplace(_card)
                _card:start_materialize()
                G.GAME.blind:debuff_card(_card)
                G.hand:sort()
                card:juice_up()
                SMODS.calculate_context({ playing_card_added = true, cards = { _card } })
                save_run()
                return true
            end
        }))
        card.ability.extra.current_charge = 0

    end,

    can_use_active = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND and card.ability.extra.charge == card.ability.extra.current_charge
    end,

    calculate = function(self, card, context)
        if context.after and card.ability.extra.current_charge < card.ability.extra.charge then
            card.ability.extra.current_charge = card.ability.extra.current_charge + 1
            if card.ability.extra.current_charge == card.ability.extra.charge then
                local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
                juice_card_until(card, eval, true)
                return {
                    message = 'Ready!'
                }
            end
        end

        if context.setting_blind and card.ability.extra.current_charge == card.ability.extra.charge then
            local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
            return {
                message = 'Ready!'
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "cherry_picture",
    blueprint_compat = false,
    rarity = 1,
    cost = 4,
    pos = { x = 3, y = 9 },
    config = { extra = { charge = 4, current_charge = 0, rank1 = 4, rank2 = 5 } },
	atlas = 'ModdedVanilla',
    chargeable = true,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        return { vars = { card.ability.extra.charge, card.ability.extra.current_charge, card.ability.extra.rank1, card.ability.extra.rank2 } }
    end,

    active = function(self, card)
        local _card = SMODS.create_card { set = "Base", rank = pseudorandom_element({card.ability.extra.rank1, card.ability.extra.rank2}, pseudoseed("cherry_picture")) }
        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
        _card.playing_card = G.playing_card
        table.insert(G.playing_cards, _card)
        play_sound('cloverpit_photo')

        G.E_MANAGER:add_event(Event({
            func = function()
                G.hand:emplace(_card)
                _card:start_materialize()
                G.GAME.blind:debuff_card(_card)
                G.hand:sort()
                card:juice_up()
                SMODS.calculate_context({ playing_card_added = true, cards = { _card } })
                save_run()
                return true
            end
        }))
        card.ability.extra.current_charge = 0
    end,

    can_use_active = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND and card.ability.extra.charge == card.ability.extra.current_charge
    end,

    calculate = function(self, card, context)
        if context.after and card.ability.extra.current_charge < card.ability.extra.charge then
            card.ability.extra.current_charge = card.ability.extra.current_charge + 1
            if card.ability.extra.current_charge == card.ability.extra.charge then
                local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
                juice_card_until(card, eval, true)
                return {
                    message = 'Ready!'
                }
            end
        end

        if context.setting_blind and card.ability.extra.current_charge == card.ability.extra.charge then
            local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
            return {
                message = 'Ready!'
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "clover_picture",
    blueprint_compat = false,
    rarity = 1,
    cost = 5,
    pos = { x = 4, y = 9 },
    config = { extra = { charge = 4, current_charge = 0, rank1 = 6, rank2 = 7 } },
	atlas = 'ModdedVanilla',
    chargeable = true,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        return { vars = { card.ability.extra.charge, card.ability.extra.current_charge, card.ability.extra.rank1, card.ability.extra.rank2 } }
    end,

    active = function(self, card)
        local _card = SMODS.create_card { set = "Base", rank = pseudorandom_element({card.ability.extra.rank1, card.ability.extra.rank2}, pseudoseed("clover_picture")) }
        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
        _card.playing_card = G.playing_card
        table.insert(G.playing_cards, _card)
        play_sound('cloverpit_photo')

        G.E_MANAGER:add_event(Event({
            func = function()
                G.hand:emplace(_card)
                _card:start_materialize()
                G.GAME.blind:debuff_card(_card)
                G.hand:sort()
                card:juice_up()
                SMODS.calculate_context({ playing_card_added = true, cards = { _card } })
                save_run()
                return true
            end
        }))
        card.ability.extra.current_charge = 0
    end,

    can_use_active = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND and card.ability.extra.charge == card.ability.extra.current_charge
    end,

    calculate = function(self, card, context)
        if context.after and card.ability.extra.current_charge < card.ability.extra.charge then
            card.ability.extra.current_charge = card.ability.extra.current_charge + 1
            if card.ability.extra.current_charge == card.ability.extra.charge then
                local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
                juice_card_until(card, eval, true)
                return {
                    message = 'Ready!'
                }
            end
        end

        if context.setting_blind and card.ability.extra.current_charge == card.ability.extra.charge then
            local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
            return {
                message = 'Ready!'
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "bell_picture",
    blueprint_compat = false,
    rarity = 1,
    cost = 5,
    pos = { x = 5, y = 9 },
    config = { extra = { charge = 4, current_charge = 0, rank1 = 8, rank2 = 9 } },
	atlas = 'ModdedVanilla',
    chargeable = true,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        return { vars = { card.ability.extra.charge, card.ability.extra.current_charge, card.ability.extra.rank1, card.ability.extra.rank2 } }
    end,

    active = function(self, card)
        local _card = SMODS.create_card { set = "Base", rank = pseudorandom_element({card.ability.extra.rank1, card.ability.extra.rank2}, pseudoseed("bell_picture")) }
        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
        _card.playing_card = G.playing_card
        table.insert(G.playing_cards, _card)
        play_sound('cloverpit_photo')

        G.E_MANAGER:add_event(Event({
            func = function()
                G.hand:emplace(_card)
                _card:start_materialize()
                G.GAME.blind:debuff_card(_card)
                G.hand:sort()
                card:juice_up()
                SMODS.calculate_context({ playing_card_added = true, cards = { _card } })
                save_run()
                return true
            end
        }))
        card.ability.extra.current_charge = 0
    end,

    can_use_active = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND and card.ability.extra.charge == card.ability.extra.current_charge
    end,

    calculate = function(self, card, context)
        if context.after and card.ability.extra.current_charge < card.ability.extra.charge then
            card.ability.extra.current_charge = card.ability.extra.current_charge + 1
            if card.ability.extra.current_charge == card.ability.extra.charge then
                local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
                juice_card_until(card, eval, true)
                return {
                    message = 'Ready!'
                }
            end
        end

        if context.setting_blind and card.ability.extra.current_charge == card.ability.extra.charge then
            local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
            return {
                message = 'Ready!'
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "diamond_picture",
    blueprint_compat = false,
    rarity = 1,
    cost = 5,
    pos = { x = 6, y = 9 },
    config = { extra = { charge = 4, current_charge = 0, rank1 = 10, rank2 = 11 } },
	atlas = 'ModdedVanilla',
    chargeable = true,
    loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        return { vars = { card.ability.extra.charge, card.ability.extra.current_charge, card.ability.extra.rank1, card.ability.extra.rank2 } }
    end,

    active = function(self, card)
        local _card = SMODS.create_card { set = "Base", rank = pseudorandom_element({card.ability.extra.rank1, card.ability.extra.rank2}, pseudoseed("diamond_picture")) }
        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
        _card.playing_card = G.playing_card
        table.insert(G.playing_cards, _card)
        play_sound('cloverpit_photo')

        G.E_MANAGER:add_event(Event({
            func = function()
                G.hand:emplace(_card)
                _card:start_materialize()
                G.GAME.blind:debuff_card(_card)
                G.hand:sort()
                card:juice_up()
                SMODS.calculate_context({ playing_card_added = true, cards = { _card } })
                save_run()
                return true
            end
        }))
        card.ability.extra.current_charge = 0
    end,

    can_use_active = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND and card.ability.extra.charge == card.ability.extra.current_charge
    end,

    calculate = function(self, card, context)
        if context.after and card.ability.extra.current_charge < card.ability.extra.charge then
            card.ability.extra.current_charge = card.ability.extra.current_charge + 1
            if card.ability.extra.current_charge == card.ability.extra.charge then
                local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
                juice_card_until(card, eval, true)
                return {
                    message = 'Ready!'
                }
            end
        end

        if context.setting_blind and card.ability.extra.current_charge == card.ability.extra.charge then
            local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
            return {
                message = 'Ready!'
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "treasure_picture",
    blueprint_compat = false,
    rarity = 1,
    cost = 6,
    pos = { x = 7, y = 9 },
    config = { extra = { charge = 4, current_charge = 0, rank1 = 12, rank2 = 13 } },
	atlas = 'ModdedVanilla',
    chargeable = true,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        return { vars = { card.ability.extra.charge, card.ability.extra.current_charge, card.ability.extra.rank1, card.ability.extra.rank2 } }
    end,

    active = function(self, card)
        local _card = SMODS.create_card { set = "Base", rank = pseudorandom_element({card.ability.extra.rank1, card.ability.extra.rank2}, pseudoseed("treasure_picture")) }
        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
        _card.playing_card = G.playing_card
        table.insert(G.playing_cards, _card)
        play_sound('cloverpit_photo')

        G.E_MANAGER:add_event(Event({
            func = function()
                G.hand:emplace(_card)
                _card:start_materialize()
                G.GAME.blind:debuff_card(_card)
                G.hand:sort()
                card:juice_up()
                SMODS.calculate_context({ playing_card_added = true, cards = { _card } })
                save_run()
                return true
            end
        }))
        card.ability.extra.current_charge = 0
    end,

    can_use_active = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND and card.ability.extra.charge == card.ability.extra.current_charge
    end,

    calculate = function(self, card, context)
        if context.after and card.ability.extra.current_charge < card.ability.extra.charge then
            card.ability.extra.current_charge = card.ability.extra.current_charge + 1
            if card.ability.extra.current_charge == card.ability.extra.charge then
                local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
                juice_card_until(card, eval, true)
                return {
                    message = 'Ready!'
                }
            end
        end

        if context.setting_blind and card.ability.extra.current_charge == card.ability.extra.charge then
            local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
            return {
                message = 'Ready!'
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "seven_picture",
    blueprint_compat = false,
    rarity = 1,
    cost = 6,
    pos = { x = 8, y = 9 },
    config = { extra = { charge = 4, current_charge = 0, rank = 14, enhancement = 'm_stone' } },
	atlas = 'ModdedVanilla',
    chargeable = true,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_stone
        return { vars = { card.ability.extra.charge, card.ability.extra.current_charge, card.ability.extra.rank, card.ability.extra.enhancement } }
    end,

    active = function(self, card)
        local card1 = SMODS.create_card { set = "Base", rank = card.ability.extra.rank, enhancement = card.ability.extra.enhancement }
        local card2 = SMODS.create_card { set = "Base", rank = card.ability.extra.rank }
        local _card = pseudorandom_element({card1, card2}, pseudoseed("seven_picture"))

        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
        _card.playing_card = G.playing_card
        table.insert(G.playing_cards, _card)
        play_sound('cloverpit_photo')

        G.E_MANAGER:add_event(Event({
            func = function()
                G.hand:emplace(_card)
                _card:start_materialize()
                G.GAME.blind:debuff_card(_card)
                G.hand:sort()
                card:juice_up()
                SMODS.calculate_context({ playing_card_added = true, cards = { _card } })
                save_run()
                return true
            end
        }))

        card.ability.extra.current_charge = 0
    end,

    can_use_active = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND and card.ability.extra.charge == card.ability.extra.current_charge
    end,

    calculate = function(self, card, context)
        if context.after and card.ability.extra.current_charge < card.ability.extra.charge then
            card.ability.extra.current_charge = card.ability.extra.current_charge + 1
            if card.ability.extra.current_charge == card.ability.extra.charge then
                local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
                juice_card_until(card, eval, true)
                return {
                    message = 'Ready!'
                }
            end
        end

        if context.setting_blind and card.ability.extra.current_charge == card.ability.extra.charge then
            local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
            return {
                message = 'Ready!'
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "clicker",
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    pos = { x = 9, y = 9 },
    config = { extra = { odds = 3, repetitions = 1 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'clicker')
        return { vars = { numerator, denominator, card.ability.extra.repetitions } }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and SMODS.pseudorandom_probability(card, 'clicker', 1, card.ability.extra.odds) then
            if (context.other_card:get_id() <= 10 and
                    context.other_card:get_id() >= 0 and
                    context.other_card:get_id() % 2 == 1) or
                (context.other_card:get_id() == 14) then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_clicker')
                        return true
                    end
                }))
                return {
                    repetitions = card.ability.extra.repetitions
                }
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "aa_batteries",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    pos = { x = 0, y = 10 },
    config = { extra = { odds = 3 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'aa_batteries')
        return { vars = { numerator, denominator} }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and SMODS.pseudorandom_probability(card, 'aa_batteries', 1, card.ability.extra.odds) then
            if context.other_card:get_id() <= 10 and
                context.other_card:get_id() >= 0 and
                context.other_card:get_id() % 2 == 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_clicker')
                        card:juice_up(0.3, 0.5)
                        return true
                    end
                }))

                for _, joker in ipairs(G.jokers.cards) do
                    if joker.config.center.chargeable then
                        if joker.ability.extra.current_charge < joker.ability.extra.charge then

                            joker.ability.extra.current_charge = joker.ability.extra.current_charge + 1
                            card_eval_status_text(joker, 'extra', nil, nil, nil, {message = "Charged!", colour = G.C.BLUE})
                            if joker.ability.extra.current_charge == joker.ability.extra.charge then
                                local eval = function(joker) return joker.ability.extra.current_charge == joker.ability.extra.charge and not G.RESET_JIGGLES end
                                juice_card_until(joker, eval, true)
                                card_eval_status_text(joker, 'extra', nil, nil, nil, {message = "Ready!"})
                            end
                        end
                    end
                end
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "crystal_sphere",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    pos = { x = 1, y = 10 },
    config = { extra = { odds = 3 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'crystal_sphere')
        return { vars = { numerator, denominator } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_face() 
            and SMODS.pseudorandom_probability(card, 'crystal_sphere', 1, card.ability.extra.odds) then
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('cloverpit_crystal_sphere')
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
            local available_hands = {}
            for hand, value in pairs(G.GAME.hands) do
                if value.visible and value.level >= 1 then
                    table.insert(available_hands, hand)
                end
            end
            local target_hand = #available_hands > 0 and pseudorandom_element(available_hands, pseudoseed('crystal_sphere')) or "High Card"
            level_up_hand(card, target_hand, true, 1)
            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "Level Up "..tostring(target_hand), colour = G.C.GREEN})
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "naughty_dealer",
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 2, y = 10 },
    config = { extra = { odds = 25, num = 1, xchips = 1.5, poker_hand = 'High Card' } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, card.ability.extra.num, card.ability.extra.odds, 'naughty_dealer')
        return { vars = { numerator, denominator, card.ability.extra.xchips, localize(card.ability.extra.poker_hand, 'poker_hands')} }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and SMODS.pseudorandom_probability(card, 'naughty_dealer', 1, card.ability.extra.odds) then
            return {
                xchips = card.ability.extra.xchips
            }
        end

        if context.before and context.scoring_name == card.ability.extra.poker_hand and not context.blueprint then
            card.ability.extra.num = card.ability.extra.num + 1
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('cloverpit_puppet')
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
            return {
                message = localize('k_upgrade_ex')
            }
        end

        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            local _poker_hands = {}
            for handname, _ in pairs(G.GAME.hands) do
                if SMODS.is_poker_hand_visible(handname) and handname ~= card.ability.extra.poker_hand then
                    _poker_hands[#_poker_hands + 1] = handname
                end
            end
            card.ability.extra.poker_hand = pseudorandom_element(_poker_hands, 'naughty_dealer')
            return {
                message = localize('k_reset')
            }
        end
    end,

    set_ability = function(self, card, initial, delay_sprites)
        local _poker_hands = {}
        for handname, _ in pairs(G.GAME.hands) do
            if SMODS.is_poker_hand_visible(handname) and handname ~= card.ability.extra.poker_hand then
                _poker_hands[#_poker_hands + 1] = handname
            end
        end
        card.ability.extra.poker_hand = pseudorandom_element(_poker_hands, 'naughty_dealer')
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "greedy_king",
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 3, y = 10 },
    config = { extra = { odds = 15, num = 1, mult = 1, mult_mod = 1 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, card.ability.extra.num, card.ability.extra.odds, 'raging_capitalist')
        return { vars = { numerator, denominator, card.ability.extra.mult, card.ability.extra.mult_mod } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and SMODS.pseudorandom_probability(card, 'raging_capitalist', 1, card.ability.extra.odds) then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
            return {
                mult = card.ability.extra.mult - 1
            }
        end

        if context.skipping_booster and not context.blueprint and card.ability.extra.odds > 1 and not context.blueprint then
            card.ability.extra.num = card.ability.extra.num + 1
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('cloverpit_puppet')
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
            return {
                message = localize('k_upgrade_ex')
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "raging_capitalist",
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 4, y = 10 },
    config = { extra = { odds = 25, num = 1, dollars = 1 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, card.ability.extra.num, card.ability.extra.odds, 'raging_capitalist')
        return { vars = { numerator, denominator, card.ability.extra.dollars } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and SMODS.pseudorandom_probability(card, 'raging_capitalist', 1, card.ability.extra.odds) then
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
            return {
                dollars = card.ability.extra.dollars,
                func = function() 
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.GAME.dollar_buffer = 0
                            return true
                        end
                    }))
                end
            }
        end

        if (context.buying_card or context.open_booster) and card.ability.extra.odds > 1 and not context.blueprint then
            card.ability.extra.num = card.ability.extra.num + 1
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('cloverpit_puppet')
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
            return {
                message = localize('k_upgrade_ex')
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "personal_trainer",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    pos = { x = 5, y = 10 },
    config = { extra = { odds = 3, repetitions = 1, limit = 25 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'personal_trainer')
        return { vars = { numerator, denominator, card.ability.extra.repetitions, card.ability.extra.limit } }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and SMODS.pseudorandom_probability(card, 'personal_trainer', 1, card.ability.extra.odds) then 
            if card.ability.extra.limit - 1 > 0 then
                if not context.blueprint then 
                    card.ability.extra.limit = card.ability.extra.limit - 1
                end
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_puppet')
                        card:juice_up(0.3, 0.5)
                        return true
                    end
                }))
                return {
                    repetitions = card.ability.extra.repetitions
                }
            else 
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Fired!", colour = G.C.RED})
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.hand_text_area.blind_chips:juice_up()
                        G.hand_text_area.game_chips:juice_up()
                        play_sound('tarot1')
                        card:start_dissolve()
                        return true
                    end
                }))
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "electrician",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    pos = { x = 6, y = 10 },
    config = { extra = { odds = 3, limit = 20 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'electrician')
        return { vars = { numerator, denominator, card.ability.extra.limit } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and SMODS.pseudorandom_probability(card, 'electrician', 1, card.ability.extra.odds) then 
            if card.ability.extra.limit - 1 > 0 then
                if not context.blueprint then 
                    card.ability.extra.limit = card.ability.extra.limit - 1
                end
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_puppet')
                        card:juice_up(0.3, 0.5)
                        return true
                    end
                }))
                for _, joker in ipairs(G.jokers.cards) do
                    if joker.config.center.chargeable then
                        if joker.ability.extra.current_charge < joker.ability.extra.charge then
                            joker.ability.extra.current_charge = joker.ability.extra.current_charge + 1
                            card_eval_status_text(joker, 'extra', nil, nil, nil, {message = "Charged!", colour = G.C.BLUE})
                            if joker.ability.extra.current_charge == joker.ability.extra.charge then
                                local eval = function(joker) return joker.ability.extra.current_charge == joker.ability.extra.charge and not G.RESET_JIGGLES end
                                juice_card_until(joker, eval, true)
                                card_eval_status_text(joker, 'extra', nil, nil, nil, {message = "Ready!"})
                            end
                        end
                    end
                end
            else 
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Fired!", colour = G.C.RED})
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.hand_text_area.blind_chips:juice_up()
                        G.hand_text_area.game_chips:juice_up()
                        play_sound('tarot1')
                        card:start_dissolve()
                        return true
                    end
                }))
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "fortune_teller",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    pos = { x = 7, y = 10 },
    config = { extra = { odds = 5, limit = 15 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'fortune_teller')
        return { vars = { numerator, denominator, card.ability.extra.limit } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and SMODS.pseudorandom_probability(card, 'fortune_teller', 1, card.ability.extra.odds) then 
            if card.ability.extra.limit - 1 > 0 then
                if not context.blueprint then 
                    card.ability.extra.limit = card.ability.extra.limit - 1
                end
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_puppet')
                        card:juice_up(0.3, 0.5)
                        return true
                    end
                }))
                local available_hands = {}
                for hand, value in pairs(G.GAME.hands) do
                    if value.visible and value.level >= 1 then
                        table.insert(available_hands, hand)
                    end
                end
                local target_hand = #available_hands > 0 and pseudorandom_element(available_hands, pseudoseed('fortune_teller')) or "High Card"
                level_up_hand(card, target_hand, true, 1)
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "Level Up "..tostring(target_hand), colour = G.C.GREEN})
            else 
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Fired!", colour = G.C.RED})
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.hand_text_area.blind_chips:juice_up()
                        G.hand_text_area.game_chips:juice_up()
                        play_sound('tarot1')
                        card:start_dissolve()
                        return true
                    end
                }))
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'golden_lemon',
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 8, y = 10 },
	config = { extra = { mult = 1, mult_mod = 1, rank1 = 2, rank2 = 3 } },
	atlas = 'ModdedVanilla',
	
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, card.ability.extra.mult_mod, card.ability.extra.rank1, card.ability.extra.rank2} }
	end,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card:get_id() == card.ability.extra.rank1 or context.other_card:get_id() == card.ability.extra.rank2 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_golden')
                        return true
                    end
                }))
                if not context.blueprint then 
				    card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
                    return {
					    mult = card.ability.extra.mult - 1,
				    }
                else 
                    return {
					    mult = card.ability.extra.mult,
				    }
                end
			end
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'golden_cherry',
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 9, y = 10 },
	config = { extra = { mult = 1, mult_mod = 1, rank1 = 4, rank2 = 5 } },
	atlas = 'ModdedVanilla',

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, card.ability.extra.mult_mod, card.ability.extra.rank1, card.ability.extra.rank2} }
	end,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card:get_id() == card.ability.extra.rank1 or context.other_card:get_id() == card.ability.extra.rank2 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_golden')
                        return true
                    end
                }))
                if not context.blueprint then 
				    card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
                    return {
					    mult = card.ability.extra.mult - 1,
				    }
                else 
                    return {
					    mult = card.ability.extra.mult,
				    }
                end
			end
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'golden_clover',
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 0, y = 11 },
	config = { extra = { mult = 1, mult_mod = 1, rank1 = 6, rank2 = 7 } },
	atlas = 'ModdedVanilla',

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, card.ability.extra.mult_mod, card.ability.extra.rank1, card.ability.extra.rank2} }
	end,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card:get_id() == card.ability.extra.rank1 or context.other_card:get_id() == card.ability.extra.rank2 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_golden')
                        return true
                    end
                }))
                if not context.blueprint then 
				    card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
                    return {
					    mult = card.ability.extra.mult - 1,
				    }
                else 
                    return {
					    mult = card.ability.extra.mult,
				    }
                end
			end
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'golden_bell',
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 1, y = 11 },
	config = { extra = { mult = 1, mult_mod = 1, rank1 = 8, rank2 = 9 } },
	atlas = 'ModdedVanilla',

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, card.ability.extra.mult_mod, card.ability.extra.rank1, card.ability.extra.rank2} }
	end,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card:get_id() == card.ability.extra.rank1 or context.other_card:get_id() == card.ability.extra.rank2 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_golden')
                        return true
                    end
                }))
                if not context.blueprint then 
				    card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
                    return {
					    mult = card.ability.extra.mult - 1,
				    }
                else 
                    return {
					    mult = card.ability.extra.mult,
				    }
                end
			end
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'golden_diamond',
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 2, y = 11 },
	config = { extra = { mult = 1, mult_mod = 1, rank1 = 10, rank2 = 11 } },
	atlas = 'ModdedVanilla',


	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, card.ability.extra.mult_mod, card.ability.extra.rank1, card.ability.extra.rank2} }
	end,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card:get_id() == card.ability.extra.rank1 or context.other_card:get_id() == card.ability.extra.rank2 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_golden')
                        return true
                    end
                }))
                if not context.blueprint then 
				    card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
                    return {
					    mult = card.ability.extra.mult - 1,
				    }
                else 
                    return {
					    mult = card.ability.extra.mult,
				    }
                end
			end
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'golden_treasure',
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 3, y = 11 },
	config = { extra = { mult = 1, mult_mod = 1, rank1 = 12, rank2 = 13 } },
	atlas = 'ModdedVanilla',


	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, card.ability.extra.mult_mod, card.ability.extra.rank1, card.ability.extra.rank2} }
	end,
    
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card:get_id() == card.ability.extra.rank1 or context.other_card:get_id() == card.ability.extra.rank2 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_golden')
                        return true
                    end
                }))
                if not context.blueprint then 
				    card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
                    return {
					    mult = card.ability.extra.mult - 1,
				    }
                else 
                    return {
					    mult = card.ability.extra.mult,
				    }
                end
			end
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'golden_seven',
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 4, y = 11 },
	config = { extra = { mult = 1, mult_mod = 1, rank = 14, enhancement = 'm_stone' } },
	atlas = 'ModdedVanilla',

	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_stone
		return { vars = { card.ability.extra.mult, card.ability.extra.mult_mod, card.ability.extra.rank, card.ability.extra.enhancement } }
	end,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card:get_id() == card.ability.extra.rank or SMODS.has_enhancement(context.other_card, 'm_stone') then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_golden')
                        return true
                    end
                }))
                if not context.blueprint then 
				    card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
                    return {
					    mult = card.ability.extra.mult - 1,
				    }
                else 
                    return {
					    mult = card.ability.extra.mult,
				    }
                end
			end
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'bricks',
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 5, y = 11 },
	config = { extra = { xchips = 1.25, rank1 = 2, rank2 = 3 } },
	atlas = 'ModdedVanilla',

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xchips, card.ability.extra.rank1, card.ability.extra.rank2} }
	end,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card:get_id() == card.ability.extra.rank1 or context.other_card:get_id() == card.ability.extra.rank2 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_catan')
                        return true
                    end
                }))
                return {
					xchips = card.ability.extra.xchips
				}
			end
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'wood',
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 6, y = 11 },
	config = { extra = { xchips = 1.25, rank1 = 4, rank2 = 5 } },
	atlas = 'ModdedVanilla',

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xchips, card.ability.extra.rank1, card.ability.extra.rank2} }
	end,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card:get_id() == card.ability.extra.rank1 or context.other_card:get_id() == card.ability.extra.rank2 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_catan')
                        return true
                    end
                }))
                return {
					xchips = card.ability.extra.xchips
				}
			end
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'sheep',
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 7, y = 11 },
	config = { extra = { xchips = 1.25, rank1 = 6, rank2 = 7 } },
	atlas = 'ModdedVanilla',

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xchips, card.ability.extra.rank1, card.ability.extra.rank2} }
	end,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == card.ability.extra.rank1 or context.other_card:get_id() == card.ability.extra.rank2 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_catan')
                        return true
                    end
                }))
				return {
					xchips = card.ability.extra.xchips
				}
			end
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'wheat',
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 8, y = 11 },
	config = { extra = { xchips = 1.25, rank1 = 8, rank2 = 9 } },
	atlas = 'ModdedVanilla',

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xchips, card.ability.extra.rank1, card.ability.extra.rank2} }
	end,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == card.ability.extra.rank1 or context.other_card:get_id() == card.ability.extra.rank2 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_catan')
                        return true
                    end
                }))
				return {
					xchips = card.ability.extra.xchips
				}
			end
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'stone',
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 9, y = 11 },
	config = { extra = { xchips = 1.25, rank1 = 10, rank2 = 11 } },
	atlas = 'ModdedVanilla',

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xchips, card.ability.extra.rank1, card.ability.extra.rank2} }
	end,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == card.ability.extra.rank1 or context.other_card:get_id() == card.ability.extra.rank2 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_catan')
                        return true
                    end
                }))
				return {
					xchips = card.ability.extra.xchips
				}
			end
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'harbor',
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 0, y = 12 },
	config = { extra = { xchips = 1.25, rank1 = 12, rank2 = 13 } },
	atlas = 'ModdedVanilla',

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xchips, card.ability.extra.rank1, card.ability.extra.rank2} }
	end,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == card.ability.extra.rank1 or context.other_card:get_id() == card.ability.extra.rank2 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_catan')
                        return true
                    end
                }))
				return {
					xchips = card.ability.extra.xchips
				}
			end
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'thief',
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 1, y = 12 },
	config = { extra = { xchips = 1.25, rank = 14, enhancement = 'm_stone' } },
	atlas = 'ModdedVanilla',

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xchips, card.ability.extra.rank, card.ability.extra.enhancement } }
	end,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == card.ability.extra.rank or SMODS.has_enhancement(context.other_card, 'm_stone') then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_catan')
                        return true
                    end
                }))
				return {
					xchips = card.ability.extra.xchips
				}
			end
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'wheelbarrow',
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 2, y = 12 },
	config = { extra = { dollars = 2, rank1 = 2, rank2 = 3 } },
	atlas = 'ModdedVanilla',

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.dollars, card.ability.extra.rank1, card.ability.extra.rank2} }
	end,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card:get_id() == card.ability.extra.rank1 or context.other_card:get_id() == card.ability.extra.rank2 then
                G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_monopoly')
                        return true
                    end
                }))
                return {
                    dollars = card.ability.extra.dollars,
                    func = function() 
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.GAME.dollar_buffer = 0
                                return true
                            end
                        }))
                    end
                }
			end
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'shoe',
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 3, y = 12 },
	config = { extra = { dollars = 2, rank1 = 4, rank2 = 5 } },
	atlas = 'ModdedVanilla',

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.dollars, card.ability.extra.rank1, card.ability.extra.rank2} }
	end,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card:get_id() == card.ability.extra.rank1 or context.other_card:get_id() == card.ability.extra.rank2 then
                G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_monopoly')
                        return true
                    end
                }))
                return {
                    dollars = card.ability.extra.dollars,
                    func = function() 
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.GAME.dollar_buffer = 0
                                return true
                            end
                        }))
                    end
                }
			end
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'thimble',
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 4, y = 12 },
	config = { extra = { dollars = 2, rank1 = 6, rank2 = 7 } },
	atlas = 'ModdedVanilla',

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.dollars, card.ability.extra.rank1, card.ability.extra.rank2} }
	end,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card:get_id() == card.ability.extra.rank1 or context.other_card:get_id() == card.ability.extra.rank2 then
                G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_monopoly')
                        return true
                    end
                }))
                return {
                    dollars = card.ability.extra.dollars,
                    func = function() 
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.GAME.dollar_buffer = 0
                                return true
                            end
                        }))
                    end
                }
			end
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'iron',
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 5, y = 12 },
	config = { extra = { dollars = 2, rank1 = 8, rank2 = 9 } },
	atlas = 'ModdedVanilla',

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.dollars, card.ability.extra.rank1, card.ability.extra.rank2} }
	end,
    
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card:get_id() == card.ability.extra.rank1 or context.other_card:get_id() == card.ability.extra.rank2 then
                G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_monopoly')
                        return true
                    end
                }))
                return {
                    dollars = card.ability.extra.dollars,
                    func = function() 
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.GAME.dollar_buffer = 0
                                return true
                            end
                        }))
                    end
                }
			end
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'car',
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 6, y = 12 },
	config = { extra = { dollars = 2, rank1 = 10, rank2 = 11 } },
	atlas = 'ModdedVanilla',

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.dollars, card.ability.extra.rank1, card.ability.extra.rank2} }
	end,
    
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card:get_id() == card.ability.extra.rank1 or context.other_card:get_id() == card.ability.extra.rank2 then
                G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_monopoly')
                        return true
                    end
                }))
                return {
                    dollars = card.ability.extra.dollars,
                    func = function() 
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.GAME.dollar_buffer = 0
                                return true
                            end
                        }))
                    end
                }
			end
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'ship',
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 7, y = 12 },
	config = { extra = { dollars = 2, rank1 = 12, rank2 = 13 } },
	atlas = 'ModdedVanilla',

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.dollars, card.ability.extra.rank1, card.ability.extra.rank2} }
	end,
    
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card:get_id() == card.ability.extra.rank1 or context.other_card:get_id() == card.ability.extra.rank2 then
                G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_monopoly')
                        return true
                    end
                }))
                return {
                    dollars = card.ability.extra.dollars,
                    func = function() 
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.GAME.dollar_buffer = 0
                                return true
                            end
                        }))
                    end
                }
			end
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
	key = 'tuba_hat',
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    pos = { x = 8, y = 12 },
	config = { extra = { dollars = 2, rank = 14, enhancement = 'm_stone' } },
	atlas = 'ModdedVanilla',

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.dollars, card.ability.extra.rank, card.ability.extra.enhancement } }
	end,
    
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card:get_id() == card.ability.extra.rank or SMODS.has_enhancement(context.other_card, 'm_stone') then
                G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_monopoly')
                        return true
                    end
                }))
                return {
                    dollars = card.ability.extra.dollars,
                    func = function() 
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.GAME.dollar_buffer = 0
                                return true
                            end
                        }))
                    end
                }
			end
		end
	end
}


------------------------------------------------------------


SMODS.Joker {
    key = "ace_of_hearts",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    pos = { x = 9, y = 12 },
    config = { extra = { threshold = 6, suit = 'Hearts', chips = 5, chips_mod = 5, count = 0 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.threshold, localize(card.ability.extra.suit, 'suits_singular'),
                          card.ability.extra.chips, card.ability.extra.chips_mod, card.ability.extra.count } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if not context.blueprint then 
                card.ability.extra.count = card.ability.extra.count + 1
            end 

            if context.other_card:is_suit(card.ability.extra.suit) and card.ability.extra.chips > 0 then
                return {
                    chips = card.ability.extra.chips
                }
            end
        end

        if context.after and card.ability.extra.count >= card.ability.extra.threshold and not context.blueprint then
            if context.cardarea == G.jokers then 
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_playing_card')
                        return true
                    end
                }))
            end
            card.ability.extra.count = 0
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_mod
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS 
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "ace_of_clubs",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    pos = { x = 0, y = 13 },
    config = { extra = { suit = 'Clubs', chips = 5, chips_mod = 5 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { localize(card.ability.extra.suit, 'suits_singular'),
                          card.ability.extra.chips, card.ability.extra.chips_mod } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit(card.ability.extra.suit) and card.ability.extra.chips > 0 then
                return {
                    chips = card.ability.extra.chips
                }
            end
        end

        if context.selling_card and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_mod
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('cloverpit_playing_card')
                    return true
                end
            }))
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS 
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "ace_of_diamonds",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    pos = { x = 1, y = 13 },
    config = { extra = { suit = 'Diamonds', chips = 5, chips_mod = 10 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { localize(card.ability.extra.suit, 'suits_singular'),
                          card.ability.extra.chips, card.ability.extra.chips_mod } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit(card.ability.extra.suit) and card.ability.extra.chips > 0 then
                return {
                    chips = card.ability.extra.chips
                }
            end
        end

        if context.cardarea == G.jokers and context.joker_main and not context.blueprint then
            if ((function()
                local count = 0
                for _, playing_card in pairs(context.scoring_hand or {}) do
                    if playing_card:is_face() then
                        count = count + 1
                    end
                end
                return count >= 1
            end)() and (function()
                local count = 0
                for _, playing_card in pairs(context.scoring_hand or {}) do
                    if (playing_card:get_id() == 2 or playing_card:get_id() == 4 or playing_card:get_id() == 6 or playing_card:get_id() == 8 or playing_card:get_id() == 10) then
                        count = count + 1
                    end
                end
                return count >= 1
            end)() and (function()
                local count = 0
                for _, playing_card in pairs(context.scoring_hand or {}) do
                    if (playing_card:get_id() == 14 or playing_card:get_id() == 3 or playing_card:get_id() == 5 or playing_card:get_id() == 7 or playing_card:get_id() == 9) then
                        count = count + 1
                    end
                end
                return count >= 1
            end)()) then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_playing_card')
                        return true
                    end
                }))
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_mod
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.CHIPS 
                }
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "ace_of_spades",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    pos = { x = 2, y = 13 },
    config = { extra = { threshold = 4, suit = 'Spades', chips = 5, chips_mod = 5, count = 0 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.threshold, localize(card.ability.extra.suit, 'suits_singular'),
                          card.ability.extra.chips, card.ability.extra.chips_mod, card.ability.extra.count } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit(card.ability.extra.suit) and card.ability.extra.chips > 0 then
                return {
                    chips = card.ability.extra.chips
                }
            end
        end

        if context.post_trigger and not context.blueprint then
            card.ability.extra.count = card.ability.extra.count + 1
        end

        if context.after and card.ability.extra.count > card.ability.extra.threshold and not context.blueprint then
            if context.cardarea == G.jokers then 
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_playing_card')
                        return true
                    end
                }))
            end
            card.ability.extra.count = 0
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_mod
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS 
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "jimbo",
    blueprint_compat = true,
    rarity = 3,
    cost = 7,
    pos = { x = 3, y = 13 },
    config = { extra = {  } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = {  } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if context.cardarea == G.jokers then 
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_impostor')
                        return true
                    end
                }))
            end
            local choice = pseudorandom_element({1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13}, pseudoseed("jimbo"))
            if choice == 1 then
                return {mult = 50}
            elseif choice == 2 then
                return {chips = 200}
            elseif choice == 3 then
                return {xmult = 3}
            elseif choice == 4 then
                return {xchips = 3}
            elseif choice == 5 then
                return {pow_mult = 1.2}
            elseif choice == 6 then
                return {dollars = 5}
            elseif choice == 7 then
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "X"..tostring(0.9).." Blind Size", colour = G.C.GREEN})
                G.GAME.blind.chips = G.GAME.blind.chips * 0.9
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                G.HUD_blind:recalculate()
                return true
            elseif choice == 8 then
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "+"..tostring(1).." Discards", colour = G.C.GREEN})
                G.GAME.current_round.discards_left = G.GAME.current_round.discards_left + 1
                return true
            elseif choice == 9 then 
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "+"..tostring(1).." Hands", colour = G.C.GREEN})
                G.GAME.current_round.hands_left = G.GAME.current_round.hands_left + 1
                return true
            elseif choice == 10 then
                if G.consumeables.config.card_limit > #G.consumeables.cards + G.GAME.consumeable_buffer then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                end
                play_sound('timpani')
                SMODS.add_card({ set = 'Tarot', edition = 'e_negative', })                            
                card:juice_up(0.3, 0.5)
                return true
            elseif choice == 11 then
                if G.consumeables.config.card_limit > #G.consumeables.cards + G.GAME.consumeable_buffer then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                end
                play_sound('timpani')
                SMODS.add_card({ set = 'Planet', edition = 'e_negative', })                            
                card:juice_up(0.3, 0.5)
                return true
            elseif choice == 12 then
                return {balance = true}
            elseif choice == 13 then
                return {
                    level_up = true,
                    message = localize('k_level_up_ex')
                }
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "d4",
    blueprint_compat = false,
    rarity = 1,
    cost = 5,
    pos = { x = 4, y = 13 },
    config = { extra = { size = 1, draw = 4 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.extra.size, self.config.extra.draw } }
    end,

    calculate = function(self, card, context)
        if context.pre_discard and #context.full_hand == self.config.extra.size then
            if G.hand and #G.hand.cards > 0 then
                SMODS.draw_cards(self.config.extra.draw)
                card:juice_up(0.3, 0.5)
                play_sound('cloverpit_dice')
            end
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "d6",
    blueprint_compat = false,
    rarity = 2,
    cost = 6,
    pos = { x = 5, y = 13 },
    config = { extra = { slots = 1 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.slots } }
    end,

    add_to_deck = function(self, card, from_debuff)
        change_shop_size(card.ability.extra.slots)
    end,
    
    remove_from_deck = function(self, card, from_debuff)
        change_shop_size(-card.ability.extra.slots)
    end,

    calculate = function(self, card, context)
        if context.starting_shop then
            card:juice_up(0.3, 0.5)
            play_sound('cloverpit_dice')
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "d20",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    pos = { x = 6, y = 13 },
    config = { extra = { creates = 1 } },
	atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.creates } }
    end,

    calculate = function(self, card, context)
        if context.setting_blind and #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
            local jokers_to_create = math.min(card.ability.extra.creates,
                G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer))
            G.GAME.joker_buffer = G.GAME.joker_buffer + jokers_to_create
            G.E_MANAGER:add_event(Event({
                func = function()
                    for _ = 1, jokers_to_create do
                        SMODS.add_card {
                            set = 'Joker',
                            key_append = 'd20' 
                        }
                        G.GAME.joker_buffer = 0
                    end
                    play_sound('cloverpit_dice')
                    return true
                end
            }))
            return {
                message = localize('k_plus_joker'),
                colour = G.C.BLUE,
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "angels_hand",
    blueprint_compat = false,
    rarity = 3,
    cost = 9,
    pos = { x = 7, y = 13 },
    config = { extra = { charge = 9, current_charge = 0, charge_increase = 2, size = 1 } },
    chargeable = true,
    atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        return { vars = { card.ability.extra.charge, card.ability.extra.current_charge, card.ability.extra.size, card.ability.extra.charge_increase } }
    end,

    active = function(self, card)
        card.ability.extra.current_charge = 0
        card.ability.extra.charge = card.ability.extra.charge * card.ability.extra.charge_increase
        SMODS.change_play_limit(card.ability.extra.size)
        SMODS.change_discard_limit(card.ability.extra.size)
        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Blessed!", colour = G.C.BLUE})
        play_sound('cloverpit_angels_hand')
    end,

    can_use_active = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND and card.ability.extra.charge == card.ability.extra.current_charge
    end,

    calculate = function(self, card, context)
        if context.after and card.ability.extra.current_charge < card.ability.extra.charge then
            card.ability.extra.current_charge = card.ability.extra.current_charge + 1
            if card.ability.extra.current_charge == card.ability.extra.charge then
                local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
                juice_card_until(card, eval, true)
                return {
                    message = 'Ready!'
                }
            end
        end

        if context.setting_blind and card.ability.extra.current_charge == card.ability.extra.charge then
            local eval = function(card) return card.ability.extra.current_charge == card.ability.extra.charge and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
            return {
                message = 'Ready!'
            }
        end
    end,

    in_pool = function(self, args) 
        return G.GAME.used_vouchers["v_cloverpit_help"]
    end

}


------------------------------------------------------------


SMODS.Joker {
    key = "eye_of_god",
    blueprint_compat = true,
    rarity = 3,
    cost = 9,
    pos = { x = 8, y = 13 },
    config = { extra = {poker_hand = 'High Card', xmult = 9} },
    atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.poker_hand, card.ability.extra.xmult } }
    end,

    calculate = function(self, card, context)
        if context.joker_main and context.scoring_name == card.ability.extra.poker_hand then
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('cloverpit_eye_of_god', 1, 0.4)
                    return true
                end
            }))
            return {
                xmult = card.ability.extra.xmult
            }
        end

        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            local _poker_hands = {}
            for handname, _ in pairs(G.GAME.hands) do
                if SMODS.is_poker_hand_visible(handname) and handname ~= card.ability.extra.poker_hand then
                    _poker_hands[#_poker_hands + 1] = handname
                end
            end
            card.ability.extra.poker_hand = pseudorandom_element(_poker_hands, 'eye_of_god')
            return {
                message = localize('k_reset')
            }
        end
    end,
    
    set_ability = function(self, card, initial, delay_sprites)
        local _poker_hands = {}
        for handname, _ in pairs(G.GAME.hands) do
            if SMODS.is_poker_hand_visible(handname) and handname ~= card.ability.extra.poker_hand then
                _poker_hands[#_poker_hands + 1] = handname
            end
        end
        card.ability.extra.poker_hand = pseudorandom_element(_poker_hands, 'eye_of_god')
    end,

    in_pool = function(self, args) 
        return G.GAME.used_vouchers["v_cloverpit_help"]
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "holy_spirit",
    blueprint_compat = true,
    rarity = 3,
    cost = 9,
    pos = { x = 9, y = 13 },
    config = { extra = { } },
    atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {vars = { }}
    end,
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play  then
            if context.other_card.edition == nil then
                local scored_card = context.other_card
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local edition = pseudorandom_element({'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                        'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome'}, 'holy_spirit')
                        scored_card:set_edition(edition, true)
                        play_sound('cloverpit_holy_spirit', 1, 0.4)
                        card:juice_up(0.3, 0.5)
                        return true
                    end
                }))
            end
        end
    end,

    in_pool = function(self, args) 
        return G.GAME.used_vouchers["v_cloverpit_help"]
    end,
}


------------------------------------------------------------


SMODS.Joker {
    key = "sacred_heart",
    blueprint_compat = true,
    rarity = 3,
    cost = 9,
    pos = { x = 0, y = 14 },
    config = { extra = {pow_mult = 1, pow_mult_mod = 0.05} },
    atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.pow_mult, card.ability.extra.pow_mult_mod }}
    end,
    
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            card.ability.extra.pow_mult = card.ability.extra.pow_mult + card.ability.extra.pow_mult_mod
            play_sound('cloverpit_sacred_heart', 1, 0.4)
            card:juice_up(0.3, 0.5)
        end

        if context.joker_main then 
            return {
                pow_mult = card.ability.extra.pow_mult
            }
        end

        if context.end_of_round and context.main_eval and G.GAME.blind.boss then
            card.ability.extra.pow_mult = 1
            return {
                message = localize('k_reset'),
            }
        end

    end,

    in_pool = function(self, args) 
        return G.GAME.used_vouchers["v_cloverpit_help"]
    end,
}


------------------------------------------------------------


SMODS.Joker {
    key = "halo",
    blueprint_compat = true,
    rarity = 3,
    cost = 9,
    pos = { x = 1, y = 14 },
    config = { extra = { } },
    atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return {vars = { }}
    end,
    
    calculate = function(self, card, context)
        if context.after and #context.full_hand > 1 then
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('cloverpit_halo', 1, 0.4)
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    context.full_hand[1]:flip()
                    play_sound('card1')
                    context.full_hand[1]:juice_up(0.3, 0.3)
                    return true
                end
            }))
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    context.full_hand[#context.full_hand]:flip()
                    play_sound('card1')
                    context.full_hand[#context.full_hand]:juice_up(0.3, 0.3)
                    return true
                end
            }))
            delay(0.2)
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    copy_card(context.full_hand[1], context.full_hand[#context.full_hand])
                    return true
                end
            }))
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    context.full_hand[1]:flip()
                    play_sound('tarot2')
                    context.full_hand[1]:juice_up(0.3, 0.3)
                    return true
                end
            }))
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    context.full_hand[#context.full_hand]:flip()
                    play_sound('tarot2')
                    context.full_hand[#context.full_hand]:juice_up(0.3, 0.3)
                    return true
                end
            }))
            delay(1)
        end
    end,

    in_pool = function(self, args) 
        return G.GAME.used_vouchers["v_cloverpit_help"]
    end,
}


------------------------------------------------------------


SMODS.Joker {
    key = "the_blood",
    blueprint_compat = true,
    rarity = 3,
    cost = 9,
    pos = { x = 2, y = 14 },
    config = { extra = {repetitions = 1} },
    atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        return { vars = { } }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if (context.other_card:get_id() <= 10 and
                    context.other_card:get_id() >= 0 and
                    context.other_card:get_id() % 2 == 1) or
                (context.other_card:get_id() == 14) then
                return {
                    repetitions = card.ability.extra.repetitions
                }
            end
        end

        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() <= 10 and
                context.other_card:get_id() >= 0 and
                context.other_card:get_id() % 2 == 0 then

                for _, joker in ipairs(G.jokers.cards) do
                    if joker.config.center.chargeable then
                        if joker.ability.extra.current_charge < joker.ability.extra.charge then

                            joker.ability.extra.current_charge = joker.ability.extra.current_charge + 1
                            card_eval_status_text(joker, 'extra', nil, nil, nil, {message = "Charged!", colour = G.C.BLUE})
                            if joker.ability.extra.current_charge == joker.ability.extra.charge then
                                local eval = function(joker) return joker.ability.extra.current_charge == joker.ability.extra.charge and not G.RESET_JIGGLES end
                                juice_card_until(joker, eval, true)
                                card_eval_status_text(joker, 'extra', nil, nil, nil, {message = "Ready!"})
                            end
                        end
                    end
                end
            end
        end

        if context.individual and context.cardarea == G.play and context.other_card:is_face() then
            local available_hands = {}
            for hand, value in pairs(G.GAME.hands) do
                if value.visible and value.level >= 1 then
                    table.insert(available_hands, hand)
                end
            end
            local target_hand = #available_hands > 0 and pseudorandom_element(available_hands, pseudoseed('the_blood')) or "High Card"
            level_up_hand(card, target_hand, true, 1)
            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "Level Up "..tostring(target_hand), colour = G.C.GREEN})
        end
    end,

    in_pool = function(self, args) 
        return G.GAME.used_vouchers["v_cloverpit_help"]
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "the_body",
    blueprint_compat = true,
    rarity = 3,
    cost = 9,
    pos = { x = 3, y = 14 },
    config = { extra = {xchips = 1.5, dollars = 1, mult = 1, mult_mod = 1} },
    atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xchips, card.ability.extra.dollars, card.ability.extra.mult, card.ability.extra.mult_mod  } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if (context.other_card:get_id() <= 10 and
                    context.other_card:get_id() >= 0 and
                    context.other_card:get_id() % 2 == 1) or
                (context.other_card:get_id() == 14) then
                return {
                    xchips = card.ability.extra.xchips
                }
            end
        end

        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() <= 10 and
                context.other_card:get_id() >= 0 and
                context.other_card:get_id() % 2 == 0 then
                G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
                return {
                    dollars = card.ability.extra.dollars,
                    func = function() 
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.GAME.dollar_buffer = 0
                                return true
                            end
                        }))
                    end
                }
            end
        end

        if context.individual and context.cardarea == G.play and context.other_card:is_face() then
            if not context.blueprint then 
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
                return {
                    mult = card.ability.extra.mult - 1,
                }
            else 
                return {
                    mult = card.ability.extra.mult,
                }
            end
			
		end
        
    end,

    in_pool = function(self, args) 
        return G.GAME.used_vouchers["v_cloverpit_help"]
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "eternity",
    blueprint_compat = true,
    rarity = 3,
    cost = 9,
    pos = { x = 4, y = 14 },
    config = { extra = { } },
    atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_cloverpit_heavenly
        local holy_tally = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_cloverpit_heavenly') then holy_tally = holy_tally + 1 end
            end
        end
        return {vars = { holy_tally }}
    end,
    
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            local holy_tally = 0
            if G.playing_cards then
                for _, playing_card in ipairs(G.playing_cards) do
                    if SMODS.has_enhancement(playing_card, 'm_cloverpit_heavenly') then holy_tally = holy_tally + 1 end
                end
            end
            return {
                repetitions = holy_tally
            }
        end
    end,

    in_pool = function(self, args) 
        return G.GAME.used_vouchers["v_cloverpit_help"]
    end,
}


------------------------------------------------------------


SMODS.Joker {
    key = "adams_ribcage",
    blueprint_compat = true,
    rarity = 3,
    cost = 9,
    pos = { x = 5, y = 14 },
    atlas = 'ModdedVanilla',
    config = { extra = {mult = 1, mult_mod = 0.9} },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_cloverpit_heavenly
        return {vars = { card.ability.extra.mult, card.ability.extra.mult_mod }}
    end,
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if SMODS.has_enhancement(context.other_card, 'm_cloverpit_heavenly') then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('cloverpit_adams_ribcage', 1, 0.4)
                        card:juice_up(0.3, 0.5)
                        return true
                    end
                }))
            end
        end

        if context.joker_main then 
            return {
                xmult = card.ability.extra.xmult
            }
        end

        if context.end_of_round and context.game_over == false and context.main_eval then
            card.ability.extra.mult = 1
            return {
                message = localize('k_reset'),
            }
        end

    end,

    in_pool = function(self, args) 
        return G.GAME.used_vouchers["v_cloverpit_help"]
    end,
}


------------------------------------------------------------


SMODS.Joker {
    key = "ophanim_wheels",
    blueprint_compat = true,
    rarity = 3,
    cost = 9,
    pos = { x = 6, y = 14 },
    atlas = 'ModdedVanilla',
    config = { extra = {mult = 1, mult_mod = 0.9} },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_cloverpit_heavenly
        return { vars = { } }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            local has_heavenly = false
            for _, playing_card in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(playing_card, 'm_cloverpit_heavenly') then
                    has_heavenly = true
                end
            end

            if has_heavenly == true then
                local tag = Tag(get_next_tag_key("ophanim_wheels"))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.4,
                    func = function()
                        play_sound('cloverpit_ophanim_wheels', 1, 0.4)
                        card:juice_up(0.3, 0.5)
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Added tag!", colour = G.C.GREEN})
                        if tag.name == "Orbital Tag" then
                            local _poker_hands = {}
                            for k, v in pairs(G.GAME.hands) do
                                if v.visible then
                                    _poker_hands[#_poker_hands + 1] = k
                                end
                            end
                            tag.ability.orbital_hand = pseudorandom_element(_poker_hands, pseudoseed("ophanim_wheels"))
                        end
                        add_tag(tag)
                        return true
                    end
                }))
            end
		end
    end,

    in_pool = function(self, args) 
        return G.GAME.used_vouchers["v_cloverpit_help"]
    end,
}


------------------------------------------------------------


SMODS.Joker {
    key = "left_arm",
    blueprint_compat = false,
    rarity = 2,
    cost = 2,
    pos = { x = 7, y = 14 },
    config = { extra = { increase = 20 } },
    atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.increase } }
    end,

    set_ability = function(self, card, initial)
        card:set_eternal(true)
        card:set_edition("e_negative", true)
    end,
    
    calculate = function(self, card, context)
        if context.setting_blind  then
            return {
                func = function()
                    if G.GAME.blind.in_blind then
                        G.GAME.blind.chips = G.GAME.blind.chips * (100 + card.ability.extra.increase) / 100
                        G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                        G.HUD_blind:recalculate()
                        return true
                    end
                end
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "right_arm",
    blueprint_compat = false,
    rarity = 2,
    cost = 2,
    pos = { x = 8, y = 14 },
    config = { extra = { increase = 20 } },
    atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.increase } }
    end,

    set_ability = function(self, card, initial)
        card:set_eternal(true)
        card:set_edition("e_negative", true)
    end,
    
    calculate = function(self, card, context)
        if context.setting_blind  then
            return {
                func = function()
                    if G.GAME.blind.in_blind then
                        G.GAME.blind.chips = G.GAME.blind.chips * (100 + card.ability.extra.increase) / 100
                        G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                        G.HUD_blind:recalculate()
                        return true
                    end
                end
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "left_leg",
    blueprint_compat = false,
    rarity = 2,
    cost = 2,
    pos = { x = 9, y = 14 },
    atlas = 'ModdedVanilla',
    config = { extra = { increase = 20 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.increase } }
    end,

    set_ability = function(self, card, initial)
        card:set_eternal(true)
        card:set_edition("e_negative", true)
    end,
    
    calculate = function(self, card, context)
        if context.setting_blind  then
            return {
                func = function()
                    if G.GAME.blind.in_blind then
                        G.GAME.blind.chips = G.GAME.blind.chips * (100 + card.ability.extra.increase) / 100
                        G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                        G.HUD_blind:recalculate()
                        return true
                    end
                end
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "right_leg",
    blueprint_compat = false,
    rarity = 2,
    cost = 2,
    pos = { x = 0, y = 15 },
    config = { extra = { increase = 20 } },
    atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.increase } }
    end,

    set_ability = function(self, card, initial)
        card:set_eternal(true)
        card:set_edition("e_negative", true)
    end,
    
    calculate = function(self, card, context)
        if context.setting_blind  then
            return {
                func = function()
                    if G.GAME.blind.in_blind then
                        G.GAME.blind.chips = G.GAME.blind.chips * (100 + card.ability.extra.increase) / 100
                        G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                        G.HUD_blind:recalculate()
                        return true
                    end
                end
            }
        end
    end
}


------------------------------------------------------------


SMODS.Joker {
    key = "skull",
    blueprint_compat = false,
    rarity = 1,
    cost = 2,
    pos = { x = 1, y = 15 },
    config = { extra = { pow_increase = 0.1 } },
    atlas = 'ModdedVanilla',
    loc_vars = function(self, info_queue, card)
        local corpse_pieces = 0
        if G.jokers and G.jokers.cards then
            for i, v in pairs(G.jokers.cards) do
                if v.config.center.key == "j_cloverpit_left_arm" or v.config.center.key == "j_cloverpit_right_arm" or
                    v.config.center.key == "j_cloverpit_left_leg" or v.config.center.key == "j_cloverpit_right_leg" then 
                    corpse_pieces = corpse_pieces + 1
                end 
            end
        end
        return { vars = { card.ability.extra.pow_increase, 1 + corpse_pieces * card.ability.extra.pow_increase } }
    end,
    
    calculate = function(self, card, context)
        if context.joker_main then
            local corpse_pieces = 0
            for i, v in pairs(G.jokers.cards) do
                if v.config.center.key == "j_cloverpit_left_arm" or v.config.center.key == "j_cloverpit_right_arm" or
                    v.config.center.key == "j_cloverpit_left_leg" or v.config.center.key == "j_cloverpit_right_leg" then 
                    corpse_pieces = corpse_pieces + 1
                end 
            end
            return {
                pow_mult = 1 + card.ability.extra.pow_increase * corpse_pieces
            }
        end
    end
}