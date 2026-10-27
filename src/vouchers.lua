SMODS.Voucher {
    key = 'reorganizing_my_mind',
    atlas = 'vouchers',
    pos = { x = 0, y = 0 },
    config = { extra = { Xchips = 2.5}},
    requires = { 'v_cloverpit_help' },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xchips } }
    end,
    calculate = function(self, card, context)
        if context.final_scoring_step then
            return {
                x_chips = card.ability.extra.Xchips,
            }
        end
    end
}


------------------------------------------------------------


SMODS.Voucher {
    key = 'patterns_in_my_behaviour',
    atlas = 'vouchers',
    pos = { x = 1, y = 0 },
    config = { extra = { pow_mult = 1.2}},
    requires = { 'v_cloverpit_help' },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.pow_mult } }
    end,
    calculate = function(self, card, context)
        if context.final_scoring_step then
            return {
                pow_mult = card.ability.extra.pow_mult,
            }
        end
    end
}


------------------------------------------------------------


SMODS.Voucher {
    key = 'energetic_recently',
    atlas = 'vouchers',
    pos = { x = 2, y = 0 },
    config = { extra = { charge = 1}},
    requires = { 'v_cloverpit_help' },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'cloverpit_chargeable', set = 'Other' }
        return { vars = { card.ability.extra.charge } }
    end,
    calculate = function(self, card, context)
        if context.other_joker and context.other_joker.config.center.chargeable then
            if context.other_joker.ability.extra.current_charge < context.other_joker.ability.extra.charge then
                context.other_joker.ability.extra.current_charge = context.other_joker.ability.extra.current_charge + 1
                if context.other_joker.ability.extra.current_charge == context.other_joker.ability.extra.charge then
                    local eval = function(card) return context.other_joker.ability.extra.current_charge == context.other_joker.ability.extra.charge and not G.RESET_JIGGLES end
                    juice_card_until(context.other_joker, eval, true)
                    return {
                        message = 'Ready!'
                    }
                end
            end
        end

    end
}


------------------------------------------------------------



SMODS.Voucher {
    key = 'heal_myself',
    atlas = 'vouchers',
    pos = { x = 3, y = 0 },
    config = { },
    requires = { 'v_cloverpit_help' },
    loc_vars = function(self, info_queue, card)
        return { }
    end,
    redeem = function(self, card)
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.I.CARD) do
                    if v.set_cost then v:set_cost() end
                end
                return true
            end
        }))
    end
}

local card_set_cost_ref = Card.set_cost
function Card:set_cost()
    card_set_cost_ref(self)
    if next(SMODS.find_card("v_cloverpit_heal_myself")) then
        if (self.ability.set == 'Joker' or (self.ability.set == 'Booster' and self.config.center.kind == 'Buffoon')) then self.cost = 0 end
        self.sell_cost = math.max(1, math.floor(self.cost / 2)) + (self.ability.extra_value or 0)
        self.sell_cost_label = self.facing == 'back' and '?' or self.sell_cost
    end
end


------------------------------------------------------------


SMODS.Voucher {
    key = 'being_constant',
    atlas = 'vouchers',
    pos = { x = 4, y = 0 },
    config = { extra = { retriggers = 1}},
    requires = { 'v_cloverpit_help' },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.retriggers } }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            return {
                repetitions = card.ability.extra.retriggers,
            }
        end
    end
}


------------------------------------------------------------


SMODS.Voucher {
    key = 'help',
    atlas = 'vouchers',
    pos = { x = 5, y = 0 },
    config = { extra = {enhancement_1 = 'm_cloverpit_devilish', enhancement_2 = 'm_cloverpit_heavenly'} },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.extra.enhancement_1]
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.extra.enhancement_2]
        return { vars = {localize { type = 'name_text', set = 'Enhanced', key = card.ability.extra.enhancement_1 },
                         localize { type = 'name_text', set = 'Enhanced', key = card.ability.extra.enhancement_2 }} }
    end,

    calculate = function(self, card, context)
        if context.discard then
            if SMODS.get_enhancements(context.other_card)["m_cloverpit_devilish"] == true then
                context.other_card:set_ability(self.config.extra.enhancement_2)
            end
        end

    end
}


------------------------------------------------------------


SMODS.Voucher {
    key = 'address_some_stuff',
    atlas = 'vouchers',
    pos = { x = 6, y = 0 },
    config = { extra = { levels = 1}},
    requires = { 'v_cloverpit_help' },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.levels } }
    end,
    calculate = function(self, card, context)
        if context.skip_blind then
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
        end
    end
}


------------------------------------------------------------


SMODS.Voucher {
    key = 'control_of_my_life',
    atlas = 'vouchers',
    pos = { x = 7, y = 0 },
    config = { extra = { levels = 1}},
    requires = { 'v_cloverpit_help' },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.levels } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval then
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
        end
    end
}