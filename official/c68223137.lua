--ワンクリウェイ
--One-Kuri-Way
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp)
	local p=c:GetOwner()
	return c:IsType(TYPE_LINK) and c:GetLink()==1 
		and (c:IsAbleToDeck() or (Duel.GetLocationCount(p,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,p)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local p=tc:GetOwner()
		if Duel.GetLocationCount(p,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,p)
			and (not c:IsAbleToDeck() or Duel.SelectYesNo(tp,aux.Stringid(id,0))) then
			Duel.SpecialSummon(tc,0,tp,p,false,false,POS_FACEUP)
		else
			Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
		end
	end
end
