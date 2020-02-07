--Pegasus Ultimate Challenge
--Scripted by AlphaKretin
--[[
    Credits to andré, Larry126 and edo9300 for assistance in scripting.
    Credits to pyrQ and Naim for assistance in testing.
    Credits to Larry126, Cybercatman, pyrQ and SnorlaxMonster from Yugipedia for consultation on rules and mechanics.
]]
local s, id = GetID()
local ADJUST_COUNT_MEAN = 75 --average number of adjusts between challenges
local ADJUST_COUNT_VAR = 25 --number of adjusts between challenges can be mean +- this
local DEBUG_FORCE_CHALLENGE = 0 --if not 0, will force a specific challenge for testing
local EVENT_PEGASUS_SPEAKS = EVENT_CUSTOM + id

function s.initial_effect(c)
    --enable REVERSE_DECK function
    Duel.EnableGlobalFlag(GLOBALFLAG_DECK_REVERSE_CHECK)
    --Add Extra Rule procedure
    aux.EnableExtraRules(c, s, s.init)
end
function s.init(c)
    s[0] = false
    s[1] = false
    s.adjustCount = s.getAdjustCount()
    --check for destroyed card this turn
    local ge1 = Effect.CreateEffect(c)
    ge1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ge1:SetCode(EVENT_DESTROYED)
    ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    ge1:SetOperation(s.checkop)
    Duel.RegisterEffect(ge1, 0)
    local ge2 = Effect.CreateEffect(c)
    ge2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ge2:SetCode(EVENT_TURN_END)
    ge2:SetCountLimit(1)
    ge2:SetCondition(s.clear)
    Duel.RegisterEffect(ge2, 0)
    --Apply challenges
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_PEGASUS_SPEAKS)
    e3:SetCondition(s.chalcon)
    e3:SetOperation(s.chalop)
    Duel.RegisterEffect(e3, 0)
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_ADJUST)
    e4:SetLabelObject(e3)
    e4:SetCondition(s.chalcon)
    e4:SetOperation(s.eventop)
    Duel.RegisterEffect(e4, 0)
end

s.illegal = true --enables announcing illegal card names. Crucially this includes the "Yu-Gi-Oh!" token
s.challenges = {} --table of functions that apply the challenges
s.activeChallenges = {} --table of effects for lingering challenges to be reset for the challenge that does so

function s.getAdjustCount()
    return ADJUST_COUNT_MEAN + Duel.GetRandomNumber(-ADJUST_COUNT_VAR, ADJUST_COUNT_VAR)
end

function s.eventop(e, tp)
    --if no challenge queued
    if e:GetLabelObject():GetLabel() == 0 then
        --decrement "timer" until next challenge
        s.adjustCount = s.adjustCount - 1
        --if next challenge is due
        if s.adjustCount <= 0 then
            --select a random challenge
            local challenge
            if DEBUG_FORCE_CHALLENGE > 0 and DEBUG_FORCE_CHALLENGE <= #s.challenges then
                challenge = DEBUG_FORCE_CHALLENGE
            else
                challenge = Duel.GetRandomNumber(1, #s.challenges)
            end
            --announce the challenge
            local index = challenge - 1
            local str = aux.Stringid(5000 + index // 16, index % 16)
            Duel.SelectOption(0, str)
            Duel.SelectOption(1, str)
            --queue the challenge
            e:GetLabelObject():SetLabel(challenge)
            --raise the event for the challenge to happen
            Duel.RaiseEvent(Group.CreateGroup(), EVENT_PEGASUS_SPEAKS, e, 0, 0, 0, 0)
            --reset timer
            s.adjustCount = s.getAdjustCount()
        end
    --if challenge already queued
    elseif Duel.GetCurrentChain() == 0 then
        --raise the event again without changing the challenge until the challenge happenes
        Duel.RaiseEvent(Group.CreateGroup(), EVENT_PEGASUS_SPEAKS, e, 0, 0, 0, 0)
    end
end

function s.chalcon(e)
    --check challenge not already applying, to avoid recursion where events raise adjusts
    return e:GetHandler():GetFlagEffect(id) == 0
end

function s.chalop(e)
    --if the game state is open or a chain is building (but not resolving)
    if Duel.GetCurrentChain() == 0 or Duel.CheckEvent(EVENT_CHAINING) then
        --register that challenge is applying to avoid recursion in challenges that raise adjusts
        e:GetHandler():RegisterFlagEffect(id, 0, 0, 0)
        local challenge = e:GetLabel()
        --clear the queue before challenge, also to avoid recursion
        e:SetLabel(0)
        local p = Duel.GetTurnPlayer()
        --apply the queued challenge
        s.challenges[challenge](e, p)
        e:GetHandler():ResetFlagEffect(id)
    end
end

--helper function to apply custom reset to challenges
function s.applyNewChallengeReset(e)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_FIELD)
    e1:SetCode(EVENT_PEGASUS_SPEAKS)
    e1:SetLabelObject(e)
    e1:SetOperation(s.resetop)
    Duel.RegisterEffect(e1, e:GetHandlerPlayer())
end

function s.resetop(e)
    e:GetLabelObject():Reset()
    e:Reset()
end

--helper function to "play" a card
function s.playCard(c, p)
    if c and not c:IsForbidden() then
        local canSummon = Duel.GetLocationCount(p, LOCATION_MZONE) > 0
        local canPendActivate =
            c:IsType(TYPE_PENDULUM) and
            (Duel.CheckLocation(p, LOCATION_PZONE, 0) or Duel.CheckLocation(p, LOCATION_PZONE, 1))
        if c:IsType(TYPE_MONSTER) then
            --check for monster seperately so skips next block if is monster
            if (canSummon or canPendActivate) then
                --TODO: This could be made more efficient surely
                if canSummon and not canPendActivate and Duel.SelectYesNo(p, 1152) then --Special Summon
                    --play monster to the field (skill summon!)
                    return Duel.MoveToField(c, p, p, LOCATION_MZONE, POS_FACEUP, true, 0x1f)
                elseif canPendActivate and not canSummon and Duel.SelectYesNo(p, 1160) then --Activate in PZONE
                    return Duel.MoveToField(c, p, p, LOCATION_PZONE, POS_FACEUP, true)
                elseif canSummon and canPendActivate then
                    local opt = Duel.SelectOption(p, 1203, 1152, 1160) --N/A, SS, PZone
                    if opt == 1 then
                        return Duel.MoveToField(c, p, p, LOCATION_MZONE, POS_FACEUP, true, 0x1f)
                    elseif opt == 2 then
                        return Duel.MoveToField(c, p, p, LOCATION_PZONE, POS_FACEUP, true)
                    end
                end
            end
        else
            --activate backrow
            local ae = c:GetActivateEffect()
            if ae and ae:IsActivatable(p) and Duel.SelectYesNo(p, 94) then
                --not just for show, actually helps it not crash! go figure
                if Duel.MoveToField(c, p, p, LOCATION_SZONE, POS_FACEDOWN, true, 0x1f) then
                    Duel.Activate(ae)
                    return true
                end
            end
        end
    end
    return false
end

--helper function to destroy all cards that fit a filter
function s.destroyFilter(func, loc)
    local dg = Duel.GetMatchingGroup(func, 0, loc, loc, nil) --which player doesn't matter because we get both sides
    if #dg > 0 then
        Duel.Destroy(dg, REASON_RULE)
    end
end

--1: All players reveal the top card of their deck. You may play that card immediately, starting with the turn player.
function s.playTopCard(e, tp)
    Duel.ConfirmDecktop(tp, 1)
    local turnPlayersCard = Duel.GetDecktopGroup(tp, 1):GetFirst()
    Duel.ConfirmDecktop(1 - tp, 1)
    local nonTurnPlayersCard = Duel.GetDecktopGroup(1 - tp, 1):GetFirst()
    s.playCard(turnPlayersCard, tp)
    s.playCard(nonTurnPlayersCard, 1 - tp)
end
table.insert(s.challenges, s.playTopCard)

--2: Both players play with their hands revealed.
function s.revealHands(e, tp)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_PUBLIC)
    e1:SetTargetRange(LOCATION_HAND, LOCATION_HAND)
    Duel.RegisterEffect(e1, tp)
    s.applyNewChallengeReset(e1)
end
table.insert(s.challenges, s.revealHands)

--3: Destroy all monsters with five or more stars.
function s.destroyFivePlusStar(e, tp)
    s.destroyFilter(
        function(c)
            return c:IsLevelAbove(5) or c:IsRankAbove(5)
        end,
        LOCATION_MZONE
    )
end
table.insert(s.challenges, s.destroyFivePlusStar)

--4: Everyone discard a random card from their hand.
function s.discardRandom(e, tp)
    local g = Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
    local sg = g:RandomSelect(tp, 1)
    Duel.SendtoGrave(sg, REASON_RULE + REASON_DISCARD)
    local g2 = Duel.GetFieldGroup(1 - tp, LOCATION_HAND, 0)
    local sg2 = g2:RandomSelect(1 - tp, 1)
    Duel.SendtoGrave(sg2, REASON_RULE + REASON_DISCARD)
end
table.insert(s.challenges, s.discardRandom)

--5: Everyone stop and introduce yourself to the person sitting on your right.
function s.introduce(e, tp)
    --only displays a message, as handled by chalop
end
table.insert(s.challenges, s.introduce)

--6: Lose 500 LP for each Spell and Trap Card you control.
function s.loseLPForBackrow(e, tp)
    local tpLoss = Duel.GetFieldGroupCount(tp, LOCATION_SZONE, 0) * 500
    local ntpLoss = Duel.GetFieldGroupCount(tp, 0, LOCATION_SZONE) * 500
    --Happens at same time and causes draw if appropriate
    Duel.SetLP(tp, Duel.GetLP(tp) - tpLoss)
    Duel.SetLP(1 - tp, Duel.GetLP(1 - tp) - ntpLoss)
end
table.insert(s.challenges, s.loseLPForBackrow)

--7: Shuffle your hand into your deck and then draw that many cards.
function s.mulligan(e, tp)
    local g = Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
    if #g > 0 then
        Duel.SendtoDeck(g, nil, 2, REASON_RULE)
        Duel.ShuffleDeck(tp)
        Duel.Draw(tp, #g, REASON_RULE)
    end
    local g2 = Duel.GetFieldGroup(tp, 0, LOCATION_HAND)
    if #g2 > 0 then
        Duel.SendtoDeck(g2, nil, 2, REASON_RULE)
        Duel.ShuffleDeck(1 - tp)
        Duel.Draw(1 - tp, #g2, REASON_RULE)
    end
end
table.insert(s.challenges, s.mulligan)

--8: Swap LP with your opponent.
function s.swapLP(e, tp)
    local temp = Duel.GetLP(tp)
    Duel.SetLP(tp, Duel.GetLP(1 - tp))
    Duel.SetLP(1 - tp, temp)
end
table.insert(s.challenges, s.swapLP)

--9: Destroy all monsters with 1500 or less ATK.
function s.destroy1500LessATK(e, tp)
    s.destroyFilter(
        function(c)
            return c:IsAttackBelow(1500)
        end,
        LOCATION_MZONE
    )
end
table.insert(s.challenges, s.destroy1500LessATK)

--10: If you had a card destroyed this turn, you may destroy one of your opponent's cards.
function s.paybackDestroy(e, tp)
    if s[tp] then
        local dc = Duel.SelectMatchingCard(tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, 0, 1, nil)
        if #dc > 0 then
            Duel.Destroy(dc, REASON_RULE)
        end
    end
    if s[1 - tp] then
        local dc = Duel.SelectMatchingCard(1 - tp, aux.TRUE, 1 - tp, 0, LOCATION_ONFIELD, 0, 1, nil)
        if #dc > 0 then
            Duel.Destroy(dc, REASON_RULE)
        end
    end
end
table.insert(s.challenges, s.paybackDestroy)

function s.checkop(e, tp, eg)
    for tc in aux.Next(eg) do
        s[tc:GetPreviousControler()] = true
    end
end

function s.clear(e, tp)
    s[0] = false
    s[1] = false
    return false
end

--11: Players cannot activate Spell Cards. (They could activate their effects.)
function s.noActSpell(e, tp)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetTargetRange(1, 1)
    e1:SetValue(s.aclimit)
    Duel.RegisterEffect(e1, tp)
    s.applyNewChallengeReset(e1)
end
table.insert(s.challenges, s.noActSpell)

function s.aclimit(e, re, tp)
    return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
end

--12: Remove all cards in all graveyard from the game.
function s.vanishGrave(e, tp)
    local rg = Duel.GetFieldGroup(tp, LOCATION_GRAVE, LOCATION_GRAVE)
    Duel.DisableShuffleCheck()
    Duel.SendtoDeck(rg, nil, -2, REASON_RULE)
end
table.insert(s.challenges, s.vanishGrave)

--13: Switch the ATK and DEF of all monsters on the field.
function s.switchATKDEF(e, tp)
    local g = Duel.GetFieldGroup(tp, LOCATION_MZONE, LOCATION_MZONE)
    local c = e:GetHandler()
    for tc in aux.Next(g) do
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SWAP_AD)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(e1)
        s.applyNewChallengeReset(e1)
    end
end
table.insert(s.challenges, s.switchATKDEF)

--14: Turn your deck over and then draw from the new top of the deck.
function s.reverseDeck(e, tp)
    local e1 = Effect.GlobalEffect()
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_REVERSE_DECK)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1, 1)
    Duel.RegisterEffect(e1, tp)
    --workaround to delay draw until after deck flips, credit to larry
    local e2 = Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_ADJUST)
    e2:SetOperation(s.drop)
    Duel.RegisterEffect(e2, tp)
    s.applyNewChallengeReset(e1)
end
table.insert(s.challenges, s.reverseDeck)

function s.drop(e, tp)
    Duel.Draw(tp, 1, REASON_RULE)
    Duel.Draw(1 - tp, 1, REASON_RULE)
    e:Reset()
end

--15: You cannot attack unless you say "Yu-Gi-Oh!"
function s.attackCost(e, tp)
    --attack cost
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_ATTACK_COST)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1, 1)
    e1:SetOperation(s.atop)
    Duel.RegisterEffect(e1, tp)
    s.applyNewChallengeReset(e1)
end
table.insert(s.challenges, s.attackCost)

function s.atop(e, tp)
    if Duel.IsAttackCostPaid() ~= 2 then
        local CARD_YUGIOH = 5000
        s.announce_filter = {CARD_YUGIOH, OPCODE_ISCODE}
        Duel.AnnounceCardFilter(tp, table.unpack(s.announce_filter))
        Duel.AttackCostPaid()
    end
end

--16: All monsters become Normal Monsters with no effects.
function s.becomeNormal(e, tp)
    local c = e:GetHandler()
    --disable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e1:SetCode(EFFECT_DISABLE)
    Duel.RegisterEffect(e1, tp)
    s.applyNewChallengeReset(e1)
    --type
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e2:SetCode(EFFECT_CHANGE_TYPE)
    e2:SetValue(TYPE_NORMAL)
    Duel.RegisterEffect(e2, tp)
    s.applyNewChallengeReset(e2)
end
table.insert(s.challenges, s.becomeNormal)

--17: Destroy all cards on the field.
function s.destroyAll(e, tp)
    s.destroyFilter(aux.TRUE, LOCATION_ONFIELD)
end
table.insert(s.challenges, s.destroyAll)

--18: Destroy all monsters.
function s.destroyMonster(e, tp)
    s.destroyFilter(aux.TRUE, LOCATION_MZONE)
end
table.insert(s.challenges, s.destroyMonster)

--19: Destroy all Spell and Trap Cards.
function s.destroyBackrow(e, tp)
    s.destroyFilter(aux.TRUE, LOCATION_SZONE)
end
table.insert(s.challenges, s.destroyBackrow)

--20: Destroy all face-up Xyz Monsters.
function s.destroyXyz(e, tp)
    s.destroyFilter(
        function(c)
            return c:IsFaceup() and c:IsType(TYPE_XYZ)
        end,
        LOCATION_MZONE
    )
end
table.insert(s.challenges, s.destroyXyz)

--21: Discard your hand and then draw that many cards.
function s.discardMulligan(e, tp)
    local g = Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
    if #g > 0 then
        Duel.SendtoGrave(g, REASON_RULE + REASON_DISCARD)
        Duel.Draw(tp, #g, REASON_RULE)
    end
    local g2 = Duel.GetFieldGroup(tp, 0, LOCATION_HAND)
    if #g2 > 0 then
        Duel.SendtoGrave(g2, REASON_RULE + REASON_DISCARD)
        Duel.Draw(1 - tp, #g2, REASON_RULE)
    end
end
table.insert(s.challenges, s.discardMulligan)

--22: Everyone draw the bottom card of their Deck.
function s.drawBottom(e, tp)
    local tc = Duel.GetFieldGroup(tp, LOCATION_DECK, 0):GetFirst() --first card in deck is bottom
    if tc then
        Duel.SendtoHand(tc, nil, REASON_RULE + REASON_DRAW)
    end
    local tc2 = Duel.GetFieldGroup(tp, 0, LOCATION_DECK):GetFirst()
    if tc2 then
        Duel.SendtoHand(tc2, nil, REASON_RULE + REASON_DRAW)
    end
end
table.insert(s.challenges, s.drawBottom)

--23: If you have less LP than your opponent, Special Summon one monster from your hand to the field, ignore all Summoning conditions.
function s.loserSpecial(e, tp)
    local p = nil
    if Duel.GetLP(tp) < Duel.GetLP(1 - tp) then
        p = tp
    elseif Duel.GetLP(1 - tp) < Duel.GetLP(tp) then
        p = 1 - tp
    end
    if not p or Duel.GetLocationCount(p, LOCATION_MZONE) <= 0 then
        return
    end
    Duel.Hint(HINT_SELECTMSG, p, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(p, s.spfilter, p, LOCATION_HAND, 0, 1, 1, nil, e, p)
    if #g > 0 then
        Duel.SpecialSummon(g, 0, p, p, true, false, POS_FACEUP)
    end
end
table.insert(s.challenges, s.loserSpecial)

function s.spfilter(c, e, tp)
    return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e, 0, tp, true, false)
end

--24: Players cannot activate Trap Cards. (They could activate their effects.)
function s.noActTrap(e, tp)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetTargetRange(1, 1)
    e1:SetValue(s.aclimit2)
    Duel.RegisterEffect(e1, tp)
    s.applyNewChallengeReset(e1)
end
table.insert(s.challenges, s.noActTrap)

function s.aclimit2(e, re, tp)
    return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
end

--25: Shuffle your Graveyard into your Deck and then put the top 15 cards of your Deck into the Graveyard.
function s.shuffleGrave(e, tp)
    local g = Duel.GetFieldGroup(tp, LOCATION_GRAVE, LOCATION_GRAVE)
    Duel.SendtoDeck(g, nil, 2, REASON_EFFECT)
    Duel.ShuffleDeck(tp)
    Duel.ShuffleDeck(1 - tp)
    Duel.DiscardDeck(tp, 15, REASON_RULE)
    Duel.DiscardDeck(1 - tp, 15, REASON_RULE)
end
table.insert(s.challenges, s.shuffleGrave)

--You must sing your Battle Phase.
--UNIMPLEMENTABLE

--26: Destroy all Continuous Spell and Trap Cards.
function s.destroyCont(e, tp)
    s.destroyFilter(
        function(c)
            return c:IsType(TYPE_CONTINUOUS)
        end,
        LOCATION_SZONE
    )
end
table.insert(s.challenges, s.destroyCont)

--27: Destroy all monsters with 1500 or more ATK.
function s.destroy1500MoreATK(e, tp)
    s.destroyFilter(
        function(c)
            return c:IsAttackAbove(1500)
        end,
        LOCATION_MZONE
    )
end
table.insert(s.challenges, s.destroy1500MoreATK)

--28: Destroy all monsters with 4 or less Levels.
function s.destroyFourLessStar(e, tp)
    s.destroyFilter(
        function(c)
            return c:IsLevelBelow(4)
        end,
        LOCATION_MZONE
    )
end
table.insert(s.challenges, s.destroyFourLessStar)

--29: No monsters can be face-down, flip all face-down monsters to face up and their flip effects are negated.
--TODO: Is there a practical difference between "flip effects negated" and "don't activate flip effects when flipped"?
function s.goFaceUp(e, tp)
    local c = e:GetHandler()
    --cannot mset
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_MSET)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1, 1)
    Duel.RegisterEffect(e1, tp)
    s.applyNewChallengeReset(e1)
    --cannot turn set
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_TURN_SET)
    e2:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    Duel.RegisterEffect(e2, tp)
    s.applyNewChallengeReset(e2)
    local sg = Duel.GetMatchingGroup(s.IsFacedown, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
    if #sg > 0 then
        Duel.ChangePosition(sg, POS_FACEUP_ATTACK, POS_FACEUP_ATTACK, POS_FACEUP_DEFENSE, POS_FACEUP_DEFENSE, true)
    end
end
table.insert(s.challenges, s.goFaceUp)

--Shuffle your Side Deck and then draw from that instead of your Main Deck.
--UNIMPLEMENTABLE

--30: Swap monsters with your opponent. All of them.
function s.swapControl(e, tp)
    local g1 = Duel.GetFieldGroup(tp, LOCATION_MZONE, 0)
    local g2 = Duel.GetFieldGroup(tp, 0, LOCATION_MZONE)
    if #g1 == #g2 then
        Duel.SwapControl(g1, g2)
        return
    end
    --workaround for groups of different sizes
    local p = 1 - tp
    if #g2 > #g1 then
        g1, g2 = g2, g1
        p = tp
    end
    --get a subset of group 1 equal to size of group 2
    local g3 = Group.CreateGroup()
    local tc = g1:GetFirst()
    while #g3 < #g2 do
        g3:AddCard(tc)
        tc = g1:GetNext()
    end
    g1 = g1 - g3
    Duel.SwapControl(g2, g3)
    Duel.GetControl(g1, p)
end
table.insert(s.challenges, s.swapControl)

--31: Turn all monsters face-down. They cannot be flipped up this turn.
function s.goFaceDown(e, tp)
    local g = Duel.GetMatchingGroup(Card.IsCanTurnSet, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
    if #g > 0 then
        Duel.ChangePosition(g, POS_FACEDOWN_DEFENSE)
        --pos limit
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
        e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        e1:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
        e1:SetTarget(aux.TargetBoolFunction(s.IsFacedown))
        e1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(e1, tp)
    end
end
table.insert(s.challenges, s.goFaceDown)

--32: You can only activate cards on your turn.
function s.noActOppTurn(e, tp)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetTargetRange(1, 1)
    e1:SetValue(s.aclimit3)
    Duel.RegisterEffect(e1, tp)
    s.applyNewChallengeReset(e1)
end
table.insert(s.challenges, s.noActOppTurn)

function s.aclimit3(e, re, tp)
    return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.GetTurnPlayer() ~= tp
end

--33: All duelists must discard a card at random.
function s.discardRandomMarik(e, tp)
    local g = Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
    local sg = g:RandomSelect(tp, 1)
    Duel.SendtoGrave(sg, REASON_RULE + REASON_DISCARD)
    local g2 = Duel.GetFieldGroup(1 - tp, LOCATION_HAND, 0)
    local sg2 = g2:RandomSelect(1 - tp, 1)
    Duel.SendtoGrave(sg2, REASON_RULE + REASON_DISCARD)
end
table.insert(s.challenges, s.discardRandomMarik)

--34: For three turns, all monsters have "Jam" added to the ends of their names.
--When a "Jam" monster is destroyed, you can Special Summon it back to the field in Defense Position.
function s.allJam(e, tp)
    local c = e:GetHandler()
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e1:SetCode(EFFECT_ADD_SETCODE)
    e1:SetValue(0x54b)
    e1:SetReset(RESET_PHASE + PHASE_END, 3)
    Duel.RegisterEffect(e1, tp)
    table.insert(s.activeChallenges, e1)
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetOperation(s.jamspop)
    e2:SetReset(RESET_PHASE + PHASE_END, 3)
    Duel.RegisterEffect(e2, tp)
    table.insert(s.activeChallenges, e2)
end
table.insert(s.challenges, s.allJam)

function s.jamspfilter(c, e)
    local p = c:GetControler()
    return c:IsPreviousSetCard(0x54b) and c:IsCanBeSpecialSummoned(e, nil, p, false, false)
end

function s.jamspop(e, tp, eg)
    for tc in aux.Next(eg) do
        local p = tc:GetControler()
        if
            s.jamspfilter(tc, e) and
                (not tc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(p, LOCATION_MZONE) > 0) or
                (tc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(p) > 0) and Duel.SelectYesNo(p, 1075)
         then
            Duel.SpecialSummon(tc, 0, p, p, false, false, POS_FACEUP_DEFENSE)
        end
    end
end

--35: For three turns, duelists can activate trap cards from their hands.
function s.handTrap(e, tp)
    local c = e:GetHandler()
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e1:SetTargetRange(LOCATION_HAND, LOCATION_HAND)
    e1:SetReset(RESET_PHASE + PHASE_END, 3)
    Duel.RegisterEffect(e1, tp)
    table.insert(s.activeChallenges, e1)
end
table.insert(s.challenges, s.handTrap)

--36: By paying 1000 Life Points per monster, players may smite any number of their opponent's monsters
--and send them to the Graveyard.
function s.smite(e, tp)
    local max1 = Duel.GetLP(tp) // 1000
    local dg1 = Duel.SelectMatchingCard(tp, aux.TRUE, tp, 0, LOCATION_MZONE, 0, max1, nil)
    if #dg1 > 0 then
        Duel.PayLPCost(tp, #dg1 * 1000)
        Duel.SendtoGrave(dg1, REASON_RULE)
    end
    local max2 = Duel.GetLP(1 - tp) // 1000
    local dg2 = Duel.SelectMatchingCard(1 - tp, aux.TRUE, 1 - tp, 0, LOCATION_MZONE, 0, max1, nil)
    if #dg2 > 0 then
        Duel.PayLPCost(1 - tp, #dg2 * 1000)
        Duel.SendtoGrave(dg2, REASON_RULE)
    end
end
table.insert(s.challenges, s.smite)

--37: Necrovalley is in effect for three turns. Cards cannot leave the Graveyard for 3 turns.
function s.necrovalley(e, tp)
    local c = e:GetHandler()
    --field
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CHANGE_ENVIRONMENT)
    e1:SetValue(CARD_NECROVALLEY)
    Duel.RegisterEffect(e1, tp)
    table.insert(s.activeChallenges, e1)
    --cannot remove
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_REMOVE)
    e2:SetTargetRange(LOCATION_GRAVE, LOCATION_GRAVE)
    Duel.RegisterEffect(e2, tp)
    table.insert(s.activeChallenges, e2)
    --necro valley
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_NECRO_VALLEY)
    e3:SetTargetRange(LOCATION_GRAVE, LOCATION_GRAVE)
    Duel.RegisterEffect(e3, tp)
    table.insert(s.activeChallenges, e3)
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_NECRO_VALLEY)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetTargetRange(1, 1)
    Duel.RegisterEffect(e4, tp)
    table.insert(s.activeChallenges, e4)
end
table.insert(s.challenges, s.necrovalley)

--38: Choose a monster, a spell, and a trap card from your Graveyard and set them all onto your field.
--Credit to andré for SelectUnselectLoop that handles Fields and Spell/Traps
function s.mimicat(e, tp)
    local mzc = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local szc = Duel.GetLocationCount(tp, LOCATION_SZONE)
    local g = Duel.GetMatchingGroup(s.graveSetFilter, tp, LOCATION_GRAVE, 0, nil, e, tp)
    if #g > 0 and aux.SelectUnselectGroup(g, e, tp, 1, 3, s.rescon(mzc, szc, g), 0) then
        local sg =
            aux.SelectUnselectGroup(g, e, tp, 1, 3, s.rescon(mzc, szc, g),
                1, tp, HINTMSG_SET, s.rescon(mzc, szc, g))
        local sg1 = sg:Filter(Card.IsType, nil, TYPE_MONSTER)
        local sg2 = sg - sg1
        for tc in aux.Next(sg1) do
            --move to field instead of summon to avoid raising adjusts and prevent reponse window
            Duel.MoveToField(tc, tp, tp, LOCATION_MZONE, POS_FACEDOWN_DEFENSE, true)
        end
        for tc in aux.Next(sg2) do
            --ditto, and also avoids core error with Duel.SSet
            Duel.MoveToField(tc, tp, tp, LOCATION_SZONE, POS_FACEDOWN, true)
        end
        Duel.ConfirmCards(1 - tp, sg)
    end
    mzc = Duel.GetLocationCount(1 - tp, LOCATION_MZONE)
    szc = Duel.GetLocationCount(1 - tp, LOCATION_SZONE)
    g = Duel.GetMatchingGroup(s.graveSetFilter, 1 - tp, LOCATION_GRAVE, 0, nil, e, 1 - tp)
    if #g > 0 and aux.SelectUnselectGroup(g, e, 1 - tp, 1, 3, s.rescon(mzc, szc, g), 0) then
        local sg = aux.SelectUnselectGroup(g, e, 1 - tp, 1, 3, s.rescon(mzc, szc, g),
            1, 1 - tp, HINTMSG_SET, s.rescon(mzc, szc, g))
        local sg1 = sg:Filter(Card.IsType, nil, TYPE_MONSTER)
        local sg2 = sg - sg1
        for tc in aux.Next(sg1) do
            Duel.MoveToField(tc, 1 - tp, 1 - tp, LOCATION_MZONE, POS_FACEDOWN_DEFENSE, true)
        end
        for tc in aux.Next(sg2) do
            Duel.MoveToField(tc, 1 - tp, 1 - tp, LOCATION_SZONE, POS_FACEDOWN, true)
        end
        Duel.ConfirmCards(tp, sg)
    end
end
table.insert(s.challenges, s.mimicat)

function s.graveSetFilter(c, e, tp)
    return (c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsSSetable()) or
        (c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e, 0, tp, true, true, POS_FACEDOWN_DEFENSE))
end

function s.rescon(mzc, szc, g)
    return function(sg, e, tp, mg)
        if
            mzc > 0 and g:IsExists(Card.IsType, 1, nil, TYPE_MONSTER) and
                sg:FilterCount(Card.IsType, nil, TYPE_MONSTER) ~= 1
         then
            return false
        elseif mzc == 0 and sg:FilterCount(Card.IsType, nil, TYPE_MONSTER) ~= 0 then
            return false
        end
        local bg = sg:Filter(aux.NOT(Card.IsType), nil, TYPE_MONSTER)
        if szc == 0 then
            if g:IsExists(Card.IsType, 1, nil, TYPE_FIELD) then
                return #bg == 1 and bg:GetFirst():IsType(TYPE_FIELD)
            else
                return #bg == 0
            end
        elseif szc == 1 then
            if #bg > 2 then
                return false
            end
            if g:IsExists(Card.IsType, 1, nil, TYPE_SPELL | TYPE_TRAP) then
                return bg:IsExists(s.raux1, 1, nil, bg, g, true)
            end
        else
            if #bg > 2 then
                return false
            end
            if g:IsExists(Card.IsType, 1, nil, TYPE_SPELL | TYPE_TRAP) then
                return bg:IsExists(s.raux1, 1, nil, bg, g, false) and
                    bg:FilterCount(Card.IsType, nil, TYPE_FIELD) <= 1
            end
        end
        return true
    end
end
function s.raux1(c, bg, g, mfield)
    local bool =
        g:IsExists(s.raux2, 1, c, (TYPE_SPELL | TYPE_TRAP) & (~c:GetType()), not c:IsType(TYPE_FIELD), mfield)
    return (bool and
        bg:IsExists(s.raux2, 1, c, (TYPE_SPELL | TYPE_TRAP) & (~c:GetType()), not c:IsType(TYPE_FIELD), mfield)) or
        (not bool and bg:FilterCount(aux.TRUE, c) == 0)
end
function s.raux2(c, type, field, mfield)
    if type == 0 then
        type = TYPE_SPELL | TYPE_TRAP
    end
    if mfield then
        return c:IsType(type) and ((field and c:IsType(TYPE_FIELD)) or (not field and not c:IsType(TYPE_FIELD)))
    else
        return c:IsType(type)
    end
end

--39: Each duelist must search his or her deck for any card, add it to their hand, and shuffle their deck afterward.
function s.search(e, tp)
    local g = Duel.SelectMatchingCard(tp, aux.TRUE, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_RULE)
        Duel.ConfirmCards(1 - tp, g)
    end
    local g2 = Duel.SelectMatchingCard(1 - tp, aux.TRUE, 1 - tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g2 > 0 then
        Duel.SendtoHand(g2, nil, REASON_RULE)
        Duel.ConfirmCards(tp, g2)
    end
end
table.insert(s.challenges, s.search)

--40: All old rules become no longer in effect, and all players reveal their hands and face-down cards to their opponents.
function s.reset(e, tp)
    for _, e in ipairs(s.activeChallenges) do
        e:Reset()
    end
    s.activeChallenges = {}
    local g = Duel.GetFieldGroup(tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_SZONE, 0):Filter(s.IsFacedown, nil)
    Duel.ConfirmCards(1 - tp, g)
    local g2 = Duel.GetFieldGroup(tp, 0, LOCATION_HAND + LOCATION_MZONE + LOCATION_SZONE):Filter(s.IsFacedown, nil)
    Duel.ConfirmCards(tp, g2)
end
table.insert(s.challenges, s.reset)

--41: Choose a card in your opponent's graveyard and set it to your side of the field.
function s.graveSteal(e, tp)
    local tc = Duel.SelectMatchingCard(tp, s.graveStealFilter, tp, 0, LOCATION_GRAVE, 1, 1, nil, e, tp):GetFirst()
    if tc then
        if tc:IsType(TYPE_MONSTER) then
            Duel.MoveToField(tc2, tp, tp, LOCATION_MZONE, POS_FACEDOWN_DEFENSE, true)
        else
            Duel.MoveToField(tc2, tp, tp, LOCATION_SZONE, POS_FACEDOWN, true)
        end
        Duel.ConfirmCards(1 - tp, tc)
    end
    local tc2 =
        Duel.SelectMatchingCard(1 - tp, s.graveStealFilter,
            1 - tp, 0, LOCATION_GRAVE, 1, 1, nil, e, 1 - tp):GetFirst()
    if tc2 then
        if tc2:IsType(TYPE_MONSTER) then
            Duel.MoveToField(tc2, 1 - tp, 1 - tp, LOCATION_MZONE, POS_FACEDOWN_DEFENSE, true)
        else
            Duel.MoveToField(tc2, 1 - tp, 1 - tp, LOCATION_SZONE, POS_FACEDOWN, true)
        end
        Duel.ConfirmCards(tp, tc2)
    end
end
table.insert(s.challenges, s.graveSteal)

function s.graveStealFilter(c, e, tp)
    return (c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsSSetable() and
        (Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 or c:IsType(TYPE_FIELD))) or
        (c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e, 0, tp, true, true, POS_FACEDOWN_DEFENSE) and
            Duel.GetLocationCount(tp, LOCATION_MZONE) > 0)
end

--42: Each duelist may draw up to two cards, but loses 1000 Life Points for each card he or she chooses to draw.
--The turn player decides how many cards to draw first.
function s.costDraw(e, tp)
    local ct = Duel.AnnounceLevel(tp, 0, math.min(2, Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0)))
    Duel.Draw(tp, ct, REASON_RULE)
    Duel.SetLP(tp, Duel.GetLP(tp) - 1000 * ct)
    local ct = Duel.AnnounceLevel(1 - tp, 0, math.min(2, Duel.GetFieldGroupCount(1 - tp, LOCATION_DECK, 0)))
    Duel.Draw(1 - tp, ct, REASON_RULE)
    Duel.SetLP(1 - tp, Duel.GetLP(1 - tp) - 1000 * ct)
end
table.insert(s.challenges, s.costDraw)

--43: You can only play monsters with an ATK of 1600 or higher.
function s.noSummonLowATK(e, tp)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1, 1)
    e1:SetTarget(s.splimit)
    Duel.RegisterEffect(e1, tp)
    s.applyNewChallengeReset(e1)
    local e2 = e1:Clone()
    e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
    Duel.RegisterEffect(e2, tp)
    s.applyNewChallengeReset(e2)
    local e3 = e1:Clone()
    e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    Duel.RegisterEffect(e3, tp)
    s.applyNewChallengeReset(e3)
end
table.insert(s.challenges, s.noSummonLowATK)

function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
    return not c:IsAttackAbove(1600)
end
