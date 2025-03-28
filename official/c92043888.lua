--ドレミコード・フォーマル
--Solfachord Formal
--Scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SOLFACHORD}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and (re:IsMonsterEffect() or re:IsHasType(EFFECT_TYPE_ACTIVATE))
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,nil,SET_SOLFACHORD)
end
function s.disfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.disfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 
		and Duel.GetOperatedGroup():GetFirst():IsLocation(LOCATION_DECK) then
		--Unaffected
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_PENDULUM))
		e1:SetValue(s.efilter)
		e1:SetLabelObject(re)
		e1:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e1,tp)
		--Cannot be destroyed
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetTargetRange(LOCATION_PZONE,0)
		e2:SetValue(s.efilter)
		e2:SetLabelObject(re)
		e2:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e2,tp)
		--Cannot be banished
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_PZONE,0,nil)
		for tc in aux.Next(g) do
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_FIELD)
			e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e3:SetCode(EFFECT_CANNOT_REMOVE)
			e3:SetRange(LOCATION_PZONE)
			e3:SetTargetRange(1,1)
			e3:SetTarget(s.rmlimit)
			e3:SetLabelObject(re)
			e3:SetReset(RESET_CHAIN)
			tc:RegisterEffect(e3)
		end
	end
end
function s.efilter(e,re)
	return re==e:GetLabelObject()
end
function s.rmlimit(e,c,tp,r,re)
	return c:IsLocation(LOCATION_PZONE) and re==e:GetLabelObject()
end