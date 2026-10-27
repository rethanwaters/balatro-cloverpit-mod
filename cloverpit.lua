---------------------------------------------------------------
-------------------------- Utilities --------------------------
---------------------------------------------------------------

SMODS.current_mod.optional_features = {
    post_trigger = true,
    retrigger_joker = true
}



-- Power Mult system for Lost Edition mod - adapted from notalisman's exponential mult system
-- Helper function to check if a value is in a table
local function table_contains(tbl, element)
   for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end

if SMODS and SMODS.calculate_individual_effect then
    local originalCalcIndiv = SMODS.calculate_individual_effect
    function SMODS.calculate_individual_effect(effect, scored_card, key, amount, from_edition)
        local ret = originalCalcIndiv(effect, scored_card, key, amount, from_edition)
        if ret then
            return ret
        end

        -- Handle power mult with purple message
        if (key == 'pow_mult') and amount ~= 1 then
            if effect.card then
                juice_card(effect.card)
            end

            if mult > 0 then
                mult = mod_mult(mult ^ amount)
            else
                mult = -1 * mod_mult((-1 * mult) ^ amount)
            end

            
            update_hand_text({ delay = 0 }, { chips = hand_chips, mult = mult })
            if not effect.remove_default_message then
                card_eval_status_text(scored_card or effect.card or effect.focus, 'extra', nil, percent, nil, {
                    -- sound = 'losted_pow_sound',
                    message = "^"..tostring(amount).." Mult", 
                    colour = G.C.PURPLE
                })
            end
            return true
        end

    end
    
    -- Register the calculation keys with SMODS
    for _, v in ipairs({'pow_mult'}) do
        if not table_contains(SMODS.other_calculation_keys, v) then
            table.insert(SMODS.other_calculation_keys, v)
        end
    end
end



-- Use buttons on Joker card functionality taken from the Lobotomy Corporation mod
local use_and_sell_buttonsref = G.UIDEF.use_and_sell_buttons
function G.UIDEF.use_and_sell_buttons(card)
    local t = use_and_sell_buttonsref(card)
    if t and t.nodes[1] and t.nodes[1].nodes[2] and card.config.center.active and type(card.config.center.active) == "function" then
        table.insert(t.nodes[1].nodes[2].nodes, 
            {n=G.UIT.C, config={align = "cr"}, nodes={
                {n=G.UIT.C, config={ref_table = card, align = "cr", maxw = 1.25, padding = 0.1, r=0.08, minw = 1.25, minh = 1, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'active_ability', func = 'can_use_active'}, nodes={
                    {n=G.UIT.B, config = {w=0.1,h=0.6}},
                    {n=G.UIT.T, config={text = localize('b_use'),colour = G.C.UI.TEXT_LIGHT, scale = 0.55, shadow = true}}
                }}
            }}
        )
    end
    return t
end

G.FUNCS.can_use_active = function(e)
    local card = e.config.ref_table
    local can_use = 
    not (not skip_check and ((G.play and #G.play.cards > 0) or
    (G.CONTROLLER.locked) or
    (G.GAME.STOP_USE and G.GAME.STOP_USE > 0))) and
    G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT and
    card.area == G.jokers and not card.debuff and
    (not card.config.center.can_use_active or card.config.center:can_use_active(card))
    if can_use then 
        e.config.colour = G.C.RED
        e.config.button = 'active_ability'
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end

G.FUNCS.active_ability = function(e, mute, nosave)
    local card = e.config.ref_table

    G.E_MANAGER:add_event(Event({func = function()
        e.disable_button = nil
        e.config.button = 'active_ability'
    return true end }))

    if card.children.use_button then card.children.use_button:remove(); card.children.use_button = nil end
    if card.children.sell_button then card.children.sell_button:remove(); card.children.sell_button = nil end

    card.config.center:active(card)
    card.area:remove_from_highlighted(card)
end





-----------------------------------------------------------
-------------------------- Atlas --------------------------
-----------------------------------------------------------

SMODS.Atlas {
	key = "ModdedVanilla",
	path = "ModdedVanilla.png",
	px = 71,
	py = 95
}

SMODS.Atlas({key = 'tool', path = 'CustomConsumables.png', px = 71, py = 95})

SMODS.Atlas {
	key = "phone",
	path = "phone calls.png",
	px = 71,
	py = 95
}

SMODS.Atlas({key = 'vouchers', path = 'CustomVouchers.png', px = 71, py = 95})

SMODS.Atlas({key = 'booster', path = 'CustomBoosters.png', px = 71, py = 95})

SMODS.Atlas({key = 'Decks', path = 'CustomDecks.png', px = 71, py = 95})

SMODS.Atlas({key = 'tags', path = 'CustomTags.png', px = 34, py = 34})

SMODS.Atlas {
	key = "Enhancements",
	path = "CustomEnhancements.png",
	px = 71,
	py = 95
}

SMODS.Atlas({
    key = "modicon", 
    path = "ModIcon.png", 
    px = 32,
    py = 31,
    atlas_table = "ASSET_ATLAS"
})

SMODS.Atlas({
    key = "balatro", 
    path = "logo.png", 
    px = 512/2,
    py = 394/2,
    prefix_config = { key = false },
    atlas_table = "ASSET_ATLAS"
})







-----------------------------------------------------------
-------------------------- Sound --------------------------
-----------------------------------------------------------

SMODS.Sound({
    key = 'ankh',
    path = 'ankh.ogg'
})

SMODS.Sound({
    key = 'horseshoe',
    path = 'horseshoe.ogg'
})

SMODS.Sound({
    key = 'hamsa',
    path = 'hamsa.ogg'
})

SMODS.Sound({
    key = 'lucky_cat',
    path = 'lucky_cat.wav'
})

SMODS.Sound({
    key = 'chonky_cat',
    path = 'chonky_cat.wav'
})

SMODS.Sound({
    key = 'swole_cat',
    path = 'swole_cat.ogg'
})

SMODS.Sound({
    key = 'one_trick_pony',
    path = 'one_trick_pony.ogg'
})

SMODS.Sound({
    key = 'red_shiny_rock',
    path = 'red_shiny_rock.ogg'
})

SMODS.Sound({
    key = 'tarot_deck',
    path = 'tarot_deck.ogg'
})

SMODS.Sound({
    key = 'dung_beetle',
    path = 'dung_beetle.ogg'
})

SMODS.Sound({
    key = 'grandmas_purse',
    path = 'grandmas_purse.ogg'
})

SMODS.Sound({
    key = 'book',
    path = 'book.ogg'
})

SMODS.Sound({
    key = 'nuclear_button',
    path = 'nuclear_button.ogg'
})

SMODS.Sound({
    key = 'dear_diary',
    path = 'dear_diary.ogg'
})

SMODS.Sound({
    key = 'megaphone',
    path = 'megaphone.ogg'
})

SMODS.Sound({
    key = 'super_capacitor',
    path = 'supercapacitor.ogg'
})

SMODS.Sound({
    key = 'dynamo',
    path = 'dynamo.ogg'
})

SMODS.Sound({
    key = 'scratch_and_hope',
    path = 'scratch_and_hope.ogg'
})

SMODS.Sound({
    key = 'stonks',
    path = 'stonks.ogg'
})

SMODS.Sound({
    key = 'car_battery',
    path = 'car_battery.ogg'
})

SMODS.Sound({
    key = 'expired_meds',
    path = 'expired_meds.ogg'
})

SMODS.Sound({
    key = 'midas_touch',
    path = 'midas_touch.ogg'
})

SMODS.Sound({
    key = 'number_one',
    path = 'number_one.ogg'
})

SMODS.Sound({
    key = 'number_two',
    path = 'number_two.ogg'
})

SMODS.Sound({
    key = 'pain_killers',
    path = 'pain_killers.ogg'
})

SMODS.Sound({
    key = 'lost_wallet',
    path = 'lost_wallet.ogg'
})

SMODS.Sound({
    key = 'lost_briefcase',
    path = 'lost_briefcase.ogg'
})

SMODS.Sound({
    key = 'calendar',
    path = 'calendar.ogg'
})

SMODS.Sound({
    key = 'little_star',
    path = 'little_star.ogg'
})

SMODS.Sound({
    key = 'fortune_cookie',
    path = 'fortune_cookie.ogg'
})

SMODS.Sound({
    key = 'fidelity_card',
    path = 'fidelity_card.ogg'
})

SMODS.Sound({
    key = 'sardines',
    path = 'sardines.ogg'
})

SMODS.Sound({
    key = 'broken_calculator',
    path = 'broken_calculator.ogg'
})

SMODS.Sound({
    key = 'the_collector',
    path = 'the_collector.ogg'
})

SMODS.Sound({
    key = 'channeler_of_fortune',
    path = 'channeler_of_fortune.ogg'
})

SMODS.Sound({
    key = 'nose',
    path = 'nose.ogg'
})

SMODS.Sound({
    key = 'eye_jar',
    path = 'eye_jar.ogg'
})

SMODS.Sound({
    key = 'voicemail',
    path = 'voicemail.ogg'
})

SMODS.Sound({
    key = 'ring_bell',
    path = 'ring_bell.ogg'
})

SMODS.Sound({
    key = 'consolation_prize',
    path = 'consolation_prize.ogg'
})

SMODS.Sound({
    key = 'dark_lotus',
    path = 'dark_lotus.ogg'
})

SMODS.Sound({
    key = 'weird_clock',
    path = 'weird_clock.ogg'
})

SMODS.Sound({
    key = 'tape',
    path = 'music_tape.ogg'
})

SMODS.Sound({
    key = 'shopping_cart',
    path = 'shopping_cart.ogg'
})

SMODS.Sound({
    key = 'crowbar',
    path = 'crowbar.ogg'
})

SMODS.Sound({
    key = 'disc',
    path = 'disc.ogg'
})

SMODS.Sound({
    key = 'cigarettes',
    path = 'cigarettes.ogg'
})

SMODS.Sound({
    key = 'electricity_meter',
    path = 'electricity_meter.ogg'
})

SMODS.Sound({
    key = 'potato_battery',
    path = 'potato_battery.ogg'
})

SMODS.Sound({
    key = 'fake_coin',
    path = 'fake_coin.ogg'
})

SMODS.Sound({
    key = 'ancient_coin',
    path = 'ancient_coin.ogg'
})

SMODS.Sound({
    key = 'cat_food',
    path = 'cat_food.ogg'
})

SMODS.Sound({
    key = 'toy_train',
    path = 'toy_train.ogg'
})

SMODS.Sound({
    key = 'steam_locomotive',
    path = 'steam_locomotive.ogg'
})

SMODS.Sound({
    key = 'diesel_locomotive',
    path = 'diesel_locomotive.ogg'
})

SMODS.Sound({
    key = 'clover_voucher',
    path = 'clover_voucher.ogg'
})

SMODS.Sound({
    key = 'clover_pot',
    path = 'clover_pot.ogg'
})

SMODS.Sound({
    key = 'clover_pet',
    path = 'clover_pet.ogg'
})

SMODS.Sound({
    key = 'clover_field',
    path = 'clover_field.ogg'
})

SMODS.Sound({
    key = 'mushrooms',
    path = 'mushrooms.ogg'
})

SMODS.Sound({
    key = 'vine_soup',
    path = 'vine_soup.ogg'
})

SMODS.Sound({
    key = 'very_big_mushroom',
    path = 'very_big_mushroom.ogg'
})

SMODS.Sound({
    key = 'dark_gurgle',
    path = 'dark_gurgle.ogg'
})

SMODS.Sound({
    key = 'paper',
    path = 'paper.ogg'
})

SMODS.Sound({
    key = 'pareidolia',
    path = 'pareidolia.ogg'
})

SMODS.Sound({
    key = 'hourglass',
    path = 'hourglass.ogg'
})

SMODS.Sound({
    key = 'pepper',
    path = 'pepper.ogg'
})

SMODS.Sound({
    key = 'devil_horn',
    path = 'devil_horn.ogg'
})

SMODS.Sound({
    key = 'evil',
    path = 'evil.ogg'
})

SMODS.Sound({
    key = 'holy',
    path = 'holy.ogg'
})

SMODS.Sound({
    key = 'baphomet',
    path = 'baphomet.ogg'
})

SMODS.Sound({
    key = 'gabihbbh',
    path = 'gabihbbh.ogg'
})

SMODS.Sound({
    key = 'possessed_cellphone',
    path = 'possessed_cellphone.ogg'
})

SMODS.Sound({
    key = 'magical_tomato',
    path = 'magical_tomato.ogg'
})

SMODS.Sound({
    key = 'ritual_bell',
    path = 'ritual_bell.ogg'
})

SMODS.Sound({
    key = 'crystal_skull',
    path = 'crystal_skull.ogg'
})

SMODS.Sound({
    key = 'evil_deal',
    path = 'evil_deal.ogg'
})

SMODS.Sound({
    key = 'chastity_belt',
    path = 'chastity_belt.ogg'
})

SMODS.Sound({
    key = 'photo_book',
    path = 'photo_book.ogg'
})

SMODS.Sound({
    key = 'photo',
    path = 'photo.ogg'
})

SMODS.Sound({
    key = 'clicker',
    path = 'clicker.ogg'
})

SMODS.Sound({
    key = 'batteries',
    path = 'batteries.ogg'
})

SMODS.Sound({
    key = 'crystal_sphere',
    path = 'crystal_sphere.ogg'
})

SMODS.Sound({
    key = 'puppet',
    path = 'puppet.ogg'
})

SMODS.Sound({
    key = 'golden',
    path = 'golden.ogg'
})

SMODS.Sound({
    key = 'catan',
    path = 'catan.ogg'
})

SMODS.Sound({
    key = 'monopoly',
    path = 'monopoly.ogg'
})

SMODS.Sound({
    key = 'playing_card',
    path = 'playing_card.ogg'
})

SMODS.Sound({
    key = 'impostor',
    path = 'impostor.ogg'
})

SMODS.Sound({
    key = 'dice',
    path = 'dice.ogg'
})

SMODS.Sound({
    key = 'phone_booster_open',
    path = 'phone_booster_open.ogg'
})

SMODS.Sound({
    key = 'phone_neutral',
    path = 'phone_neutral.ogg'
})

SMODS.Sound({
    key = 'phone_good',
    path = 'phone_good.ogg'
})

SMODS.Sound({
    key = 'phone_evil',
    path = 'phone_evil.ogg'
})

SMODS.Sound({
    key = 'angels_hand',
    path = 'angels_hand.ogg'
})

SMODS.Sound({
    key = 'eye_of_god',
    path = 'eye_of_god.ogg'
})

SMODS.Sound({
    key = 'holy_spirit',
    path = 'holy_spirit.ogg'
})

SMODS.Sound({
    key = 'sacred_heart',
    path = 'sacred_heart.ogg'
})

SMODS.Sound({
    key = 'halo',
    path = 'halo.ogg'
})

SMODS.Sound({
    key = 'the_blood',
    path = 'the_blood.ogg'
})

SMODS.Sound({
    key = 'the_body',
    path = 'the_body.ogg'
})

SMODS.Sound({
    key = 'eternity',
    path = 'eternity.ogg'
})

SMODS.Sound({
    key = 'adams_ribcage',
    path = 'adams_ribcage.ogg'
})

SMODS.Sound({
    key = 'ophanim_wheels',
    path = 'ophanim_wheels.ogg'
})



----------------------------------------------------------
-------------------------- Load --------------------------
----------------------------------------------------------

assert(SMODS.load_file("src/jokers.lua"))()
assert(SMODS.load_file("src/enhancements.lua"))()
assert(SMODS.load_file("src/editions.lua"))()
assert(SMODS.load_file("src/vouchers.lua"))()
assert(SMODS.load_file("src/backs.lua"))()
assert(SMODS.load_file("src/tools.lua"))()
assert(SMODS.load_file("src/boosters.lua"))()
assert(SMODS.load_file("src/tags.lua"))()
assert(SMODS.load_file("src/phone.lua"))()
