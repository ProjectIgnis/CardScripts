--Triangle Gimmick Box
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,e)
	return c:IsType(TYPE_XYZ) and c:IsAbleToRemove() and (not e or not c:IsCanBeEffectTarget(e)) and aux.SpElimFilter(c,true)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsType(TYPE_XYZ)
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetLocationCountFromEx(tp,tp,sg)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,e)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0) 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_REMOVE)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	Duel.BreakEffect()
	if Duel.GetLocationCountFromEx(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		end
	Duel.SpecialSummonComplete()
end
