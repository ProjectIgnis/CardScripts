--Decoy Baby
--scripted by andré
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter1(c,tp)
	return c:IsFaceup() and c:GetCounter(0x1107)~=0 and Duel.IsExistingMatchingCard(s.filter2,tp,0,LOCATION_MZONE,1,nil,c:GetRace())
end
function s.filter2(c,rc)
	return c:IsFaceup() and c:IsRace(rc)
end
function s.target(e,tp,eg,ev,ep,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.filter1(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_SZONE,0,1,nil,tp) 
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter1,tp,LOCATION_SZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ev,ep,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local g=Duel.SelectMatchingCard(tp,s.filter2,tp,0,LOCATION_MZONE,1,1,nil,tc:GetRace())
		local tc2=g:GetFirst()
		if tc2 then
			Duel.HintSelection(g)
			Duel.MoveToField(tc2,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			tc2:AddCounter(0x1107,1)
		end
	end
end
