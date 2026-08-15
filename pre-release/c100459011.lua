--罰ゲーム「ＧＲＥＥＤ－欲望の幻像－」
--Penalty Game "GREED, the Illusion of Avarice"
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If your opponent added a card(s) from the Deck to the hand this turn, except during the Draw Phase: Inflict 400 damage to your opponent for each card in their hand, then if the total number of cards in their hand, field, and GY is 20 or more, you can banish their entire hand. You can only activate 1 "Penalty Game "GREED, the Illusion of Avarice"" per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.HasFlagEffect(1-tp,id)
	end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_TOHAND|TIMING_CHAIN_END|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--Keep track of cards being added from the Deck to a player's hand, except during the Draw Phase
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_HAND)
		ge1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
			return not Duel.IsDrawPhase()
		end)
		ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			for ec in eg:Iter() do
				if ec:IsPreviousLocation(LOCATION_DECK) then
					Duel.RegisterFlagEffect(ec:GetReasonPlayer(),id,RESET_PHASE|PHASE_END,0,1)
				end
			end
		end)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local total_damage=400*Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if chk==0 then return total_damage>0 end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,total_damage)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local total_damage=400*Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if total_damage>0 and Duel.Damage(1-tp,total_damage,REASON_EFFECT)>0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE)>=20
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		Duel.BreakEffect()
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end