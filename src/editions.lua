
SMODS.Shader({ key = 'cyan', path = 'cyan.fs' })
SMODS.Shader({ key = 'red', path = 'red.fs' })
SMODS.Shader({ key = 'ionized', path = 'ionized.fs' })
SMODS.Shader({ key = 'gilded', path = 'gilded.fs' })
SMODS.Shader({ key = 'yellow', path = 'yellow.fs' })
SMODS.Shader({ key = 'green', path = 'green.fs' })
SMODS.Shader({ key = 'purple', path = 'purple.fs' })


SMODS.Edition {
    key = 'obsessive',
    shader = 'cyan',
    config = { extra = { retriggers = 1 } },
    in_shop = true,
    weight = 3,
    extra_cost = 5,
    apply_to_float = true,
    loc_txt = {
        name = 'Obsessive',
        label = 'Obsessive',
        text = {
            'Retrigger this card'
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.extra.retriggers } }
    end,
    calculate = function(self, card, context)
        if context.repetition_only or (context.retrigger_joker_check and context.other_card == card) then
            return {
                repetitions = card.edition.extra.retriggers,
                card = card,
                colour = G.C.GREEN,
                message = localize('k_again_ex')
            }     
        end
    end
}



SMODS.Edition {
    key = 'florid',
    shader = 'gilded',
    config = { extra = { dollars = 1 } },
    in_shop = true,
    weight = 3,
    extra_cost = 5,
    apply_to_float = true,
    loc_txt = {
        name = 'Florid',
        label = 'Florid',
        text = {
            'If present on round end,',
            'Gain {C:money}$#1#{}'
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.extra.dollars } }
    end,
    calculate = function(self, card, context)
        if (card.ability.set == 'Joker' and context.end_of_round and context.main_eval)
            or (context.playing_card_end_of_round and context.cardarea == G.hand) then
            return {
                dollars = card.edition.extra.dollars
            }   
        end
    end
}



SMODS.Edition {
    key = 'devious',
    shader = 'red',
    config = { extra = { dollars = 1 } },
    in_shop = true,
    weight = 3,
    extra_cost = -2,
    apply_to_float = true,
    loc_txt = {
        name = 'Devious',
        label = 'Devious',
        text = {
            'If present after defeating',
            'a {C:attention}Boss Blind{}, add a',
            '{C:red}Devilish{} card to your deck,',
            'then remove this edition'
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    calculate = function(self, card, context)
        if G.GAME.blind.boss then 
            if (card.ability.set == 'Joker' and context.end_of_round and context.main_eval)
            or (context.playing_card_end_of_round and context.cardarea == G.hand) then
                local card_front = pseudorandom_element(G.P_CARDS, pseudoseed('add_card_hand'))
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
                        card:set_edition(nil)
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.deck.config.card_limit = G.deck.config.card_limit + 1
                                return true
                            end
                        }))
                        draw_card(G.play, G.deck, 90, 'up')
                        SMODS.calculate_context({ playing_card_added = true, cards = { base_card } })
                    end,
                    message = "Purified!"
                }
            end
        end
    end
}



SMODS.Edition {
    key = 'ambitious',
    shader = 'ionized',
    config = { extra = { pow_mult = 1.05 } },
    in_shop = true,
    weight = 3,
    extra_cost = 5,
    apply_to_float = true,
    loc_txt = {
        name = 'Ambitious',
        label = 'Ambitious',
        text = {
            '{X:dark_edition,C:white}^#1#{} Mult'
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.extra.pow_mult, mult } }
    end,
    calculate = function(self, card, context)
        if context.pre_joker or (context.main_scoring and context.cardarea == G.play) then
            return {
                pow_mult = card.edition.extra.pow_mult
            }
        end
    end
}



SMODS.Edition {
    key = 'avid',
    shader = 'yellow',
    config = { extra = { chips = 25, mult = 5, xmult = 1.25 } },
    in_shop = true,
    weight = 3,
    extra_cost = 5,
    apply_to_float = true,
    loc_txt = {
        name = 'Avid',
        label = 'Avid',
        text = {
            '{C:chips}+#1#{} Chips',
            '{C:mult}+#2#{} Mult',
            '{X:mult,C:white}X#3#{} Mult'
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.extra.chips, self.config.extra.mult, self.config.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.pre_joker or (context.main_scoring and context.cardarea == G.play) then
            return {
                chips = card.edition.extra.chips,
                mult = card.edition.extra.mult,
                xmult = card.edition.extra.xmult
            }
        end
    end
}



SMODS.Edition {
    key = 'gambler',
    shader = 'green',
    config = { extra = { cost = 1 } },
    in_shop = true,
    weight = 3,
    extra_cost = 5,
    apply_to_float = true,
    loc_txt = {
        name = 'Gambler',
        label = 'Gambler',
        text = {
            'If present on round end,',
            'Spend {C:money}$#1#{} to gain',
            'a random {C:tarot}Tarot{} card'
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.extra.cost } }
    end,
    calculate = function(self, card, context)
        if (card.ability.set == 'Joker' and context.end_of_round and context.main_eval)
            or (context.playing_card_end_of_round and context.cardarea == G.hand) then
                if G.GAME.dollars > G.GAME.bankrupt_at and G.consumeables.config.card_limit ~= #G.consumeables.cards then
                    return {
                        dollars = card.edition.extra.cost * -1,
                        extra = {
                            func = function()
                                for i = 1, math.min(1, G.consumeables.config.card_limit - #G.consumeables.cards) do
                                    G.E_MANAGER:add_event(Event({
                                        trigger = 'before',
                                        delay = 0.0,
                                        func = function()
                                            play_sound('timpani')
                                            SMODS.add_card({ set = 'Tarot', })                            
                                            card:juice_up(0.3, 0.5)
                                            return true
                                        end
                                    }))
                                end
                                delay(0.6)
                                
                                if created_consumable then
                                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_plus_tarot'), colour = G.C.PURPLE})
                                end
                                return true
                            end,
                            colour = G.C.PURPLE
                        }
                    }
                end
        end
    end
}



SMODS.Edition {
    key = 'speculative',
    shader = 'purple',
    config = { extra = { decrease_percent = 5 } },
    in_shop = true,
    weight = 3,
    extra_cost = 5,
    apply_to_float = true,
    loc_txt = {
        name = 'Speculative',
        label = 'Speculative',
        text = {
            'Decrease {C:attention}Blind{} size',
            'by {C:attention}#1#%{}'
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.extra.decrease_percent } }
    end,
    calculate = function(self, card, context)
        if context.pre_joker or (context.main_scoring and context.cardarea == G.play) then
            return {
                func = function()
                    card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "X"..tostring(0.95).." Blind Size", colour = G.C.GREEN})
                    G.GAME.blind.chips = G.GAME.blind.chips * ((100 - self.config.extra.decrease_percent) / 100)
                    G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                    G.HUD_blind:recalculate()
                    return true
                end
            }
        end
    end
}