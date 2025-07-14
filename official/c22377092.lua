--トラップホリック
--Trap Holic
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 Spell/Trap you control, and if you do, Set 1 Normal Trap from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={id}
function s.desfilter(c,tp,ft)
	if not c:IsSpellTrap() then return false end
	if c:IsLocation(LOCATION_STZONE) then ft=ft+1 end
	return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,ft>0)
end
function s.setfilter(c,haszone)
	return c:IsNormalTrap() and c:IsSSetable(haszone) and not c:IsCode(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if not c:IsLocation(LOCATION_SZONE) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then ft=ft-1 end
	if chkc then return chkc:IsOnField() and s.desfilter(chkc,tp,ft) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,c,tp,ft) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,c,tp,ft)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,false):GetFirst()
		if sc and Duel.SSet(tp,sc)>0 then
			--It can be activated this turn while you have 3 or more Traps in your GY
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,1))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetCondition(function(e) return Duel.GetMatchingGroupCount(Card.IsTrap,tp,LOCATION_GRAVE,0,nil)>=3 end)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			sc:RegisterEffect(e1)
		end
	end
end