

SMODS.Enhancement {
    key = 'devilish',
    pos = { x = 0, y = 0 },
    config = {
        mult = -6,
        h_mult = -6,
        bonus = -66,
        h_chips = -66
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.mult, card.ability.h_mult, card.ability.bonus, card.ability.h_bonus } }
    end,
    any_suit = false,
    replace_base_card = true,
    no_rank = true,
    no_suit = true,
    always_scores = true,
    unlocked = true,
    discovered = true,
    no_collection = false,
    weight = 5,
    atlas = 'Enhancements',
    calculate = function(self, card, context)
        if context.discard and context.other_card == card then
            local target_joker = nil
            for i = #G.jokers.cards, 1, -1 do
                local joker = G.jokers.cards[i]
                if not joker.ability.eternal and not joker.getting_sliced then
                    target_joker = joker
                    break
                end
            end
            
            if target_joker then
                target_joker.getting_sliced = true
                G.E_MANAGER:add_event(Event({
                    func = function()
                        target_joker:start_dissolve({G.C.RED}, nil, 1.6)
                        return true
                    end
                }))
            end
            return {
                message = "Sacrificed!"
            }
        end
    end
}


------------------------------------------------------

-- TODO do not appear in standard pack
SMODS.Enhancement {
    key = 'heavenly',
    pos = { x = 1, y = 0 },
    config = {
        mult = 9,
        bonus = 99,
        decrease_percent = 9
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.mult, card.ability.bonus, card.ability.decrease_percent } }
    end,
    unlocked = true,
    discovered = true,
    no_collection = false,
    weight = 0,
    atlas = 'Enhancements',

    calculate = function(self, card, context)
        if context.pre_joker or (context.main_scoring and context.cardarea == G.play) then
            return {
                func = function()
                    card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "X"..tostring(0.91).." Blind Size", colour = G.C.BLUE})
                    G.GAME.blind.chips = G.GAME.blind.chips * ((100 - self.config.decrease_percent) / 100)
                    G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                    G.HUD_blind:recalculate()
                    return true
                end
            }
        end
    end
}
