--デモンズ・ゴーレム
--Fiendish Golem
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Banish 1 monster with 2000 or more ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_RED_DRAGON_ARCHFIEND,50078509} --Fiendish Chain
function s.rmfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(2000) and c:IsAbleToRemove()
end
function s.rdafilter(c)
	return c:IsFaceup() and (c:IsCode(CARD_RED_DRAGON_ARCHFIEND)
		or (c:IsType(TYPE_SYNCHRO) and c:IsMonster() and c:ListsCode(CARD_RED_DRAGON_ARCHFIEND)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	e:SetLabel(Duel.GetMatchingGroupCount(s.rdafilter,tp,LOCATION_ONFIELD,0,nil))
end
function s.setfilter(c)
	return c:IsCode(50078509) and c:IsSSetable()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local turn_count=Duel.GetTurnCount()
	--Banish it until the End Phase of the next turn
	local ret_eff=aux.RemoveUntil(tc,nil,REASON_EFFECT,PHASE_END,id,e,tp,aux.DefaultFieldReturnOp,function() return Duel.GetTurnCount()==turn_count+1 end,nil,2)
	if ret_eff and e:GetLabel()>0 and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		--Set 1 "Fiendish Chain" from the Deck or GY
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SSet(tp,g)
		end
	end
end