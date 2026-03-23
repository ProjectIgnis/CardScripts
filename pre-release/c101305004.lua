--グリフォー
--Gurifoh
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--(Quick Effect): You can discard this card, then activate 1 of these effects;
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfDiscard)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--For the Ritual Summon of exactly 1 Level 8 Ritual Monster with a card effect that requires use of monsters, this card can be used as the entire Tribute
	Ritual.AddWholeLevelTribute(c,aux.FilterBoolFunction(Card.IsLevel,8))
end
s.listed_names={CARD_RITUAL_OF_LIGHT_AND_DARKNESS}
function s.setfilter(c)
	return (c:IsQuickPlaySpell() or c:IsTrap()) and c:ListsCode(CARD_RITUAL_OF_LIGHT_AND_DARKNESS) and c:IsSSetable()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=true
	local b2=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(0)
	elseif op==2 then
		e:SetCategory(CATEGORY_SET)
		Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local c=e:GetHandler()
	if op==1 then
		--● The next battle or effect damage you take this turn will become 0
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.damval)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	elseif op==2 then
		--● Set 1 Quick-Play Spell or Trap that mentions "Ritual of Light and Darkness" from your Deck. It can be activated this turn
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if sc and Duel.SSet(tp,sc)>0 then
			local eff_code=sc:IsQuickPlaySpell() and EFFECT_QP_ACT_IN_SET_TURN or EFFECT_TRAP_ACT_IN_SET_TURN
			--It can be activated this turn
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(aux.Stringid(id,4))
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
			e2:SetCode(eff_code)
			e2:SetReset(RESETS_STANDARD_PHASE_END)
			sc:RegisterEffect(e2)
		end
	end
end
function s.damval(e,re,val,r,rp,rc)
	if r&(REASON_BATTLE|REASON_EFFECT)>0 then
		Duel.Hint(HINT_CARD,0,id)
		e:Reset()
		return 0
	end
	return val
end