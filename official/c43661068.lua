--星に願いを
--Star Light, Star Bright
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function s.filter(c,atk,def)
	return c:IsFaceup() and c:GetLevel()>0 and (c:GetAttack()==atk or c:GetDefense()==def)
end
function s.tfilter(c,tp)
	return c:IsFaceup() and c:GetLevel()>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,c,c:GetAttack(),c:GetDefense())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,tc,tc:GetAttack(),tc:GetDefense())
		local lv=tc:GetLevel()
		local lc=g:GetFirst()
		for lc in aux.Next(g) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL_FINAL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			lc:RegisterEffect(e1)
		end
	end
end
