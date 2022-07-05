--風魔の波動
--Fuhma Wave
--Scripted by Hel
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 monster on the field with the same attribute as targeted monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.tgfilter(c)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.desfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
end
function s.desfilter(c,tc)
	return c:IsFaceup() and c:IsAttribute(tc:GetAttribute()) and not c:IsCode(tc:GetCode())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tc)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsFaceup() and tc:IsRelateToEffect(e)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tc)
	if #g>0 then
		Duel.HintSelection(g,true)
		Duel.Destroy(g,REASON_EFFECT)
	end
end