--ウィスカ・ブリッツクリーク
--Wisca Blitzclique
--scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--If a card(s) was destroyed by your "Blitzclique" card's effect this turn (Quick Effect): You can reveal this card in your hand; Special Summon up to 3 Thunder monsters from your hand, then you can destroy up to that many cards on the field, also you cannot Special Summon Effect Monsters for the rest of this turn, except from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e,tp) return Duel.HasFlagEffect(tp,id) end)
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--Track destroyed cards
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.descheckop)
		Duel.RegisterEffect(ge1,0)
	end)
	--When a monster effect is activated, except in the hand (Quick Effect): You can return 1 other Thunder monster you control to the hand; negate the activation, and if you do, destroy the activating monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_BLITZCLIQUE}
function s.descheckop(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	local rc=re:GetHandler()
	if rc and rc:IsSetCard(SET_BLITZCLIQUE) then
		Duel.RegisterFlagEffect(rp,id,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_THUNDER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_EITHER,LOCATION_ONFIELD)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,math.min(ft,3),nil,e,tp)
		if #g>0 then
			local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			if ct>0 then
				local fg=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
				if #fg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
					local dg=fg:Select(tp,1,ct,nil)
					if #dg>0 then
						Duel.HintSelection(dg)
						Duel.BreakEffect()
						Duel.Destroy(dg,REASON_EFFECT)
					end
				end
			end
		end
	end
	--You cannot Special Summon Effect Monsters for the rest of this turn, except from the hand
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return (c:IsEffectMonster() or c:IsOriginalType(TYPE_EFFECT)) and not c:IsLocation(LOCATION_HAND) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsMonsterEffect() and Duel.IsChainNegatable(ev)
		and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)~=LOCATION_HAND
end
function s.negcostfilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsFaceup() and c:IsAbleToHandAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.negcostfilter,tp,LOCATION_MZONE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.negcostfilter,tp,LOCATION_MZONE,0,1,1,c)
	Duel.HintSelection(g)
	Duel.SendtoHand(g,nil,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=re:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end