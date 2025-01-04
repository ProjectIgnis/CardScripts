--転轍地点
--Switch Point
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Send monster(s) to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>=3
end
function s.tgfilter(c,p)
	return Duel.IsPlayerCanSendtoGrave(p,c)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,0,LOCATION_MZONE,1,nil,1-tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_MZONE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if #g<3 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc then return end
	Duel.HintSelection(tc,true)
	g:RemoveCard(tc)
	local b1=Duel.IsPlayerCanSendtoGrave(1-tp,tc)
	local b2=g:IsExists(s.tgfilter,1,nil,1-tp)
	local op=Duel.SelectEffect(1-tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	if op then
		Duel.SendtoGrave(op==1 and tc or g,REASON_RULE,PLAYER_NONE,1-tp)
	end
end