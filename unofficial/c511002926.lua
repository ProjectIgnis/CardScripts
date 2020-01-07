--Gagaga Thunder
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter1(c,tp)
	return c:GetLevel()>0 and c:IsSetCard(0x54) 
		and Duel.IsExistingTarget(s.filter2,tp,LOCATION_MZONE,0,1,c,c:GetLevel())
end
function s.filter2(c,lv)
	return c:GetLevel()>0 and c:GetLevel()~=lv and c:IsSetCard(0x54)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc2=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,tc1,tc1:GetLevel()):GetFirst()
	local lv=0
	if tc1:GetLevel()>tc2:GetLevel() then
		lv=tc1:GetLevel()-tc2:GetLevel()
	else
		lv=tc2:GetLevel()-tc1:GetLevel()
	end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,lv*300)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if #g==2 then
		local tc1=g:GetFirst()
		local tc2=g:GetNext()
		local lv=0
		if tc1:GetLevel()>tc2:GetLevel() then
			lv=tc1:GetLevel()-tc2:GetLevel()
		else
			lv=tc2:GetLevel()-tc1:GetLevel()
		end
		Duel.Damage(1-tp,lv*300,REASON_EFFECT)
	end
end
