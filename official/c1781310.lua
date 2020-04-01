--風林火山
--Fuh-Rin-Ka-Zan
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_TOHAND)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.dfilter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsAttribute,ATTRIBUTE_WIND),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsAttribute,ATTRIBUTE_WATER),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsAttribute,ATTRIBUTE_FIRE),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsAttribute,ATTRIBUTE_EARTH),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
		or Duel.IsExistingMatchingCard(s.dfilter2,tp,0,LOCATION_ONFIELD,1,nil)
		or Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>=2
		or Duel.IsPlayerCanDraw(tp,2) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local off=1
	local ops={}
	local opval={}
	if Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) then
		ops[off]=aux.Stringid(id,0)
		opval[off-1]=1
		off=off+1
	end
	if Duel.IsExistingMatchingCard(s.dfilter2,tp,0,LOCATION_ONFIELD,1,nil) then
		ops[off]=aux.Stringid(id,1)
		opval[off-1]=2
		off=off+1
	end
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>=2 then
		ops[off]=aux.Stringid(id,2)
		opval[off-1]=3
		off=off+1
	end
	if Duel.IsPlayerCanDraw(tp,2) then
		ops[off]=aux.Stringid(id,3)
		opval[off-1]=4
		off=off+1
	end
	if off==1 then return end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		Duel.Destroy(g,REASON_EFFECT)
	elseif opval[op]==2 then
		local g=Duel.GetMatchingGroup(s.dfilter2,tp,0,LOCATION_ONFIELD,nil)
		Duel.Destroy(g,REASON_EFFECT)
	elseif opval[op]==3 then
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(1-tp,2)
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	elseif opval[op]==4 then
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
