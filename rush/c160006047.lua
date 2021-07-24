-- 体力増強剤ストロングZ Tairyoku Zoukyou Zai Strong Z (Strength Enhancement Drug Strong Z/Strong Z/Energy Drink Z)

local s,id=GetID()
function s.initial_effect(c)
	--Gain LP equal to sum of the targeted monsters' Level
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.recfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:GetLevel()>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.recfilter),tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.recfilter),tp,LOCATION_MZONE,0,1,1,nil)
	local lvl=0
	Duel.HintSelection(g)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		lvl=lvl+(tc:GetLevel()*100)
	end
	Duel.Recover(tp,lvl,REASON_EFFECT)
end