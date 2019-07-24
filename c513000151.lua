--Speed Spell - High Speed Crash (Anime)
--Ｓｐ－ハイスピード・クラッシュ
--scritped by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.con)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFieldCard(e:GetHandler():GetControler(),LOCATION_SZONE,5)
	return tc and tc:GetCounter(0x91)>1
end
function s.filter(c,card)
	return c:IsDestructable() and Duel.IsExistingTarget(s.filter2,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,card)
end
function s.filter2(c,card)
	return c:IsDestructable() and c~=card
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,0,1,c,c) end  
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_ONFIELD,0,1,1,c,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,g1:GetFirst(),c)
	g1:Merge(g2)
	Duel.Destroy(g1,REASON_EFFECT)
end