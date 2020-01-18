--ＥＮシャッフル
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x3008,0x1f}
function s.filter1(c,e,tp)
	return c:IsSetCard(0x3008) and c:IsAbleToDeck()
	 and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,e,tp)
end
function s.filter2(c,e,tp)
	return c:IsSetCard(0x1f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsLocation(LOCATION_MZONE) and tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,1,REASON_EFFECT)
		Duel.BreakEffect()
		local dt=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_DECK,0,nil,e,tp)
		if #dt>0 then
			local ed=dt:Select(tp,1,1,nil):GetFirst()
			if Duel.SpecialSummonStep(ed,0,tp,tp,false,false,POS_FACEUP) then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				ed:RegisterEffect(e1,true)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				ed:RegisterEffect(e2,true)
				end
			Duel.SpecialSummonComplete()
		end
	end
end
