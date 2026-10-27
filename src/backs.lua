SMODS.Back {
    key = "desperate_search",
    pos = { x = 0, y = 0 },
    atlas = 'Decks',
    config = { extra = {card_slot = -1, rerolls = 5} },
    atlas = 'Decks',
    loc_vars = function(self, info_queue, back)
        return { vars = { self.config.extra.card_slot, self.config.extra.rerolls } }
    end,

    apply = function(self, back)
        SMODS.change_free_rerolls(self.config.extra.rerolls)
        G.E_MANAGER:add_event(Event({
            func = function()
                change_shop_size(self.config.extra.card_slot)
                return true
            end
        }))
    end
}


------------------------------------------------------------

SMODS.Back {
    key = "fixation",
    pos = { x = 1, y = 0 },
    atlas = 'Decks',
    config = { extra = {hands = 3, discards = 4} },
    loc_vars = function(self, info_queue, back)
        return { vars = { self.config.extra.hands, self.config.extra.discards } }
    end,

    calculate = function(self, card, context)
        if context.before then
            return {
                func = function()
                    ease_discard(-1)
                    return true
                end
            }
        end
        if context.pre_discard then
            return {
                func = function()
                    ease_hands_played(-1)
                    return true
                end
            }
        end

        if context.discard and G.GAME.current_round.hands_left == 1 then 
            return {
                func = function()
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.5,
                        func = function()
                            if G.STAGE == G.STAGES.RUN then 
                                G.STATE = G.STATES.GAME_OVER
                                G.STATE_COMPLETE = false
                            end
                        end
                    }))
                    return true
                end
            }
        
        end
    end,

    apply = function(self, back)
        G.GAME.starting_params.hands = G.GAME.starting_params.hands + self.config.extra.hands
        G.GAME.starting_params.discards = G.GAME.starting_params.discards + self.config.extra.discards
    end
}


------------------------------------------------------------


SMODS.Back {
    key = "screen_addiction",
    pos = { x = 2, y = 0 },
    atlas = 'Decks',
    config = { extra = {hands = 31, start_hands = 35, extra_hand_bonus = 0, extra_discard_bonus = 1, hand_refresh = 7} },
    loc_vars = function(self, info_queue, back)
        return { vars = { self.config.extra.start_hands, self.config.extra.extra_hand_bonus, 
            self.config.extra.extra_discard_bonus, self.config.extra.hand_refresh } }
    end,

    calculate = function(self, card, context)
   
        if context.starting_shop or context.setting_blind then 
            local hands_played = (function() local total = 0; for hand, data in pairs(G.GAME.hands) do total = total + data.played end; return total end)()
            G.GAME.current_round.hands_left = G.GAME.current_round.hands_left - hands_played + (7 * G.GAME.skips)
        end 

    end,

    apply = function(self, back)
        G.GAME.starting_params.hands = G.GAME.starting_params.hands + self.config.extra.hands
        G.GAME.modifiers.money_per_hand = self.config.extra.extra_hand_bonus
        G.GAME.modifiers.money_per_discard = self.config.extra.extra_discard_bonus
    end
}


------------------------------------------------------------


SMODS.Back {
    key = "cold_affection",
    pos = { x = 3, y = 0 },
    atlas = 'Decks',
    config = { extra = {dollars = 16, interest = 1} },
    loc_vars = function(self, info_queue, back)
        return { vars = { self.config.extra.dollars } }
    end,

    apply = function(self, back)
        G.GAME.starting_params.dollars = G.GAME.starting_params.dollars + self.config.extra.dollars
        G.GAME.interest_amount = G.GAME.interest_amount + self.config.extra.interest
        G.GAME.modifiers.no_blind_reward = G.GAME.modifiers.no_blind_reward or {}
        G.GAME.modifiers.no_blind_reward.Small = true
        G.GAME.modifiers.no_blind_reward.Big = true
        G.GAME.modifiers.no_blind_reward.Boss = true
    end
}


------------------------------------------------------------


SMODS.Back {
    key = "old_wounds",
    pos = { x = 4, y = 0 },
    atlas = 'Decks',
    config = { extra = {ante_scaling = 0.5, dollars = 0, ready = false} },
    loc_vars = function(self, info_queue, back)
        return { vars = { self.config.extra.ante_scaling, self.config.extra.dollars } }
    end,

    calculate = function(self, back, context)
        if context.round_eval and G.GAME.last_blind and G.GAME.last_blind.boss then
            self.config.extra.ready = true 
        end

        if context.starting_shop and self.config.extra.ready then
            self.config.extra.ready = false 
            return {
                func = function()
                    local current_dollars = G.GAME.dollars
                    local target_dollars = self.config.extra.dollars
                    local dollar_value = target_dollars - current_dollars
                    ease_dollars(dollar_value)
                    return true
                end
            }
        end
    end,

    apply = function(self, back)
        G.GAME.starting_params.ante_scaling = self.config.extra.ante_scaling
    end
}


------------------------------------------------------------


SMODS.Back({
    key = "bullies_favorite",
    pos = { x = 5, y = 0 },
    atlas = 'Decks',
    config = { extra = {joker_slot = 2}  },

    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.extra.joker_slot } }
    end,

    calculate = function(self, back, context)
        if context.setting_blind and context.blind.boss then
            local destructable_jokers = {}
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] ~= card and not SMODS.is_eternal(G.jokers.cards[i], card) and not G.jokers.cards[i].getting_sliced then
                    destructable_jokers[#destructable_jokers + 1] =
                        G.jokers.cards[i]
                end
            end
            local joker_to_destroy = pseudorandom_element(destructable_jokers, 'bullies_favorite')

            if joker_to_destroy then
                joker_to_destroy.getting_sliced = true
                G.E_MANAGER:add_event(Event({
                    func = function()
                        joker_to_destroy:start_dissolve({ G.C.RED }, nil, 1.6)
                        return true
                    end
                }))
            end
        end
    end,

    apply = function(self, back)
        G.GAME.starting_params.joker_slots = G.GAME.starting_params.joker_slots + self.config.extra.joker_slot
    end
})


------------------------------------------------------------


SMODS.Back {
    key = "delusions_of_grandeur",
    pos = { x = 6, y = 0 },
    atlas = 'Decks',
    config = { extra = {ante_scaling = 2} },
    loc_vars = function(self, info_queue, back)
        return { vars = { self.config.extra.ante_scaling } }
    end,

    apply = function(self, back)
        G.GAME.starting_params.ante_scaling = self.config.extra.ante_scaling
    end
}


------------------------------------------------------------


SMODS.Back({
    key = "important_choice",
    pos = { x = 7, y = 0 },
    atlas = 'Decks',
    config = { extra = { enhancement = 'm_cloverpit_devilish' } },

    loc_vars = function(self, info_queue, card)
        -- info_queue[#info_queue + 1] = G.P_CENTERS.m_cloverpit_devilish
        return { }
    end,

    calculate = function(self, back, context)
        if context.skip_blind and not context.blueprint then
            local card_front = pseudorandom_element(G.P_CARDS, pseudoseed('important_choice'))
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
            delay(1)
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
                end
            }
        end

        if context.end_of_round and context.main_eval then 
            local devil_tally = 0
            if G.playing_cards then
                for _, playing_card in ipairs(G.playing_cards) do
                    if SMODS.has_enhancement(playing_card, self.config.extra.enhancement) then devil_tally = devil_tally + 1 end
                end
            end
            if devil_tally > 0 then
                ease_dollars(devil_tally, true)
            end
        end
    end
})


------------------------------------------------------------


SMODS.Back({
    key = "recovery_attempts",
    pos = { x = 8, y = 0 },
    atlas = 'Decks',
    config = { voucher = 'v_cloverpit_help' },

    loc_vars = function(self, info_queue, card)
         return { }
    end,

    calculate = function(self, back, context)
        if context.before then
            for _, playing_card in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(playing_card, 'm_cloverpit_devilish') then
                    return {
                        func = function()
                            G.E_MANAGER:add_event(Event({
                                trigger = 'after',
                                delay = 0.5,
                                func = function()
                                    if G.STAGE == G.STAGES.RUN then 
                                        G.STATE = G.STATES.GAME_OVER
                                        G.STATE_COMPLETE = false
                                    end
                                end
                            }))                            
                            return true
                        end
                    }
                end
            end
        end
    end
})


------------------------------------------------------------


SMODS.Back {
    key = "life_lessons",
    pos = { x = 9, y = 0 },
    atlas = 'Decks',
    config = { extra = {edition = 'e_cloverpit_devious'} },
    loc_vars = function(self, info_queue, back)
        return { vars = { } }
    end,

    calculate = function(self, back, context)
        if context.end_of_round and context.main_eval and not G.GAME.blind.boss and next(SMODS.Edition:get_edition_cards(G.jokers, true)) then
            local editionless_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.4,
                func = function()
                    local eligible_card = pseudorandom_element(editionless_jokers, 'life_lessons')
                    eligible_card:set_edition(pseudorandom_element({'e_cloverpit_devious'}, pseudoseed('life_lessons')), true)
                    return true
                end
            }))
        end

        if context.setting_blind and G.GAME.blind.boss and next(SMODS.Edition:get_edition_cards(G.jokers, true)) then
            local editionless_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.4,
                func = function()
                    local eligible_card = pseudorandom_element(editionless_jokers, 'life_lessons')
                    eligible_card:set_edition({ negative = true })
                    return true
                end
            }))
        end
    end
}


------------------------------------------------------------


SMODS.Back({
    key = "a_new_investment",
    pos = { x = 0, y = 1 },
    atlas = 'Decks',
    config = { extra = { joker_slot = -2 , joker_mod = 1, voucher_joker_mod = -1}  },

    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.extra.joker_slot, self.config.extra.joker_mod, self.config.extra.voucher_joker_mod } }
    end,

    calculate = function(self, back, context)
        if context.buying_card and context.card.config.center.set == 'Voucher' then
            G.jokers.config.card_limit = G.jokers.config.card_limit + self.config.extra.voucher_joker_mod
        end

        if context.end_of_round and context.main_eval and G.GAME.blind.boss then
            G.jokers.config.card_limit = G.jokers.config.card_limit + self.config.extra.joker_mod
        end 
    end,

    apply = function(self, back)
        G.GAME.starting_params.joker_slots = G.GAME.starting_params.joker_slots + self.config.extra.joker_slot
    end
})


------------------------------------------------------------


SMODS.Back({
    key = "sacrifices",
    pos = { x = 1, y = 1 },
    atlas = 'Decks',
    config = { extra = {joker_slot = -1, shop_size = 1, voucher_size = 1, booster_size = 1}  },

    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.extra.joker_slot, self.config.extra.shop_size, self.config.extra.voucher_size, self.config.extra.booster_size } }
    end,

    apply = function(self, back)
        G.GAME.starting_params.joker_slots = G.GAME.starting_params.joker_slots + self.config.extra.joker_slot
        change_shop_size(self.config.extra.shop_size)
        SMODS.change_voucher_limit(self.config.extra.voucher_size)
        SMODS.change_booster_limit(self.config.extra.booster_size)
    end
})


------------------------------------------------------------


SMODS.Back({
    key = "lets_go_gambling",
    pos = { x = 2, y = 1 },
    atlas = 'Decks',
    config = { extra = { }, consumables = { 'c_ectoplasm' } },

    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,

    calculate = function (self, back, context)
		if context.end_of_round and context.main_eval then
            local edition_tally = 0
			for i=1, #G.jokers.cards do
                if G.jokers.cards[i].edition == nil then
                    G.jokers.cards[i].getting_sliced = true
                        G.E_MANAGER:add_event(Event({func = function()
                            G.jokers.cards[i]:start_dissolve({G.C.RED}, nil, 1.6)
                        return true end }))
                else
                    edition_tally = edition_tally + 1
                end
			end

			G.E_MANAGER:add_event(Event({
			func = function()
                for i = 1, G.jokers.config.card_limit - edition_tally do 
                    if G.jokers then
                        SMODS.add_card {set = 'Joker'}
                    end
                end
                return true
			end,
			}))
		end
	end
})


------------------------------------------------------------


SMODS.Back({
	key = "class_dunce",
	config = { },
    pos = { x = 3, y = 1 },
    atlas = 'Decks',
    loc_vars = function(self, info_queue, back)
        return { vars = { } }
    end,
	
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    if v:get_id() == 13 then
                        assert(SMODS.change_base(v, nil, "3"))
                    
                    elseif v:get_id() == 12 then
                        assert(SMODS.change_base(v, nil, "4"))
                    
                    elseif v:get_id() == 11 then
                        assert(SMODS.change_base(v, nil, "5"))
                    
                    elseif v:get_id() == 10 then
                        assert(SMODS.change_base(v, nil, "6"))
                    
                    elseif v:get_id() == 8 then
                        assert(SMODS.change_base(v, nil, "7"))
                                
                    elseif v:get_id() == 9 then
                        assert(SMODS.change_base(v, nil, "2"))
                    end        
                end
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    for i=#G.playing_cards, 1, -1 do
                        if G.playing_cards[i]:get_id() == 14 then
                            G.playing_cards[i]:remove()
                        end
                    end
                end
                G.GAME.starting_deck_size = #G.playing_cards
                return true
            end
        }))
    end,
})


------------------------------------------------------------


SMODS.Back({
	key = "heartbreak",
	config = { extra = {num_cards = 4}},
    pos = { x = 4, y = 1 },
    atlas = 'Decks',
    loc_vars = function(self, info_queue, back)
        return { vars = { self.config.extra.num_cards } }
    end,

    calculate = function(self, back, context)
        if context.end_of_round and context.main_eval and G.GAME.blind.boss then
            local card_front = pseudorandom_element(G.P_CARDS, pseudoseed('heartbreak'))
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
        end
    end,

	apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    if v:get_id() == 6 then
                        v:set_ability('m_cloverpit_devilish')
                    end
                end
                return true
            end
        }))
	end

})


------------------------------------------------------------


SMODS.Back({
	key = "repressed_emotions",
	config = { },
    pos = { x = 5, y = 1 },
    atlas = 'Decks',
    loc_vars = function(self, info_queue, back)
        return { vars = { } }
    end,

	apply = function(self)
		local atpref = SMODS.add_to_pool
        function SMODS.add_to_pool(prototype, args)
            if G.GAME.selected_back_key.key == "b_cloverpit_repressed_emotions" and prototype.set == "Joker" and not prototype.original_mod then
                return false
            end
            return atpref(prototype, args)
        end
	end,
})


------------------------------------------------------------


SMODS.Back({
    key = "first_love",
    pos = { x = 6, y = 1 },
    atlas = 'Decks',
    config = { extra = {shop_size = -2, voucher_size = -1, booster_size = -2}  },

    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.extra.joker_slot, self.config.extra.shop_size, self.config.extra.voucher_size, self.config.extra.booster_size } }
    end,

    calculate = function(self, back, context)
        if context.end_of_round and context.game_over == false and context.main_eval then
            G.E_MANAGER:add_event(Event({
                func = function()
                    local tag = Tag("tag_buffoon")
                    tag:set_ability()
                    add_tag(tag)
                    play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                    return true
                end
            }))
            G.E_MANAGER:add_event(Event({
                func = function()
                    local tag = Tag("tag_charm")
                    tag:set_ability()
                    add_tag(tag)
                    play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                    return true
                end
            }))
            G.E_MANAGER:add_event(Event({
                func = function()
                    local tag = Tag("tag_meteor")
                    tag:set_ability()
                    add_tag(tag)
                    play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                    return true
                end
            }))
            G.E_MANAGER:add_event(Event({
                func = function()
                    local tag = Tag("tag_standard")
                    tag:set_ability()
                    add_tag(tag)
                    play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                    return true
                end
            }))
        end
    end,

    apply = function(self, back)
        change_shop_size(self.config.extra.shop_size)
        SMODS.change_voucher_limit(self.config.extra.voucher_size)
        SMODS.change_booster_limit(self.config.extra.booster_size)
    end
})


------------------------------------------------------------


SMODS.Back({
	key = "expensive_love",
	config = { extra = {rate = 1e100}},
    pos = { x = 7, y = 1 },
    atlas = 'Decks',
    loc_vars = function(self, info_queue, back)
        return { vars = { } }
    end,

	apply = function(self)
        local cloverpit_poll_edition = poll_edition
        function poll_edition(key, _mod, _no_neg, _guaranteed, options)
            if G.GAME.selected_back_key.key == "b_cloverpit_expensive_love" then _mod = (_mod or 1) * G.GAME.selected_back.effect.config.extra.rate end
            return cloverpit_poll_edition(key, _mod, _no_neg, _guaranteed, {'e_cloverpit_ambitious', 'e_cloverpit_obsessive', 'e_cloverpit_florid', 'e_cloverpit_devious', 'e_cloverpit_avid',
                    'e_cloverpit_gambler', 'e_cloverpit_speculative', 'e_foil', 'e_holo', 'e_polychrome'})
        end
	end,
})


------------------------------------------------------------


SMODS.Back({
	key = "overdose",
	config = { discards = 1, hands = 1, joker_slot = 1, hand_size = 1, extra = {size = -1}},
    pos = { x = 8, y = 1 },
    atlas = 'Decks',
    loc_vars = function(self, info_queue, back)
        return { vars = {self.config.discards, self.config.hands, self.config.joker_slot, self.config.hand_size, self.config.extra.size} }
    end,

	apply = function(self)
        return {
            G.E_MANAGER:add_event(Event({
                func = function()
                    SMODS.change_play_limit(self.config.extra.size)
                    SMODS.change_discard_limit(self.config.extra.size)
                    return true
                end
            }))
        }
	end,
})