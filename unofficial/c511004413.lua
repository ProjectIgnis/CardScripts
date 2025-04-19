--Ｘエクシーズ
--Cross Xyz
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and Duel.IsExistingTarget(s.filter2,tp,LOCATION_MZONE,0,1,c,e,tp,c)
end
function s.filter2(c,e,tp,mc)
	return c:IsFaceup() and c:HasLevel() and c:IsLevel(mc:GetRank())
		and Duel.IsExistingMatchingCard(s.filter3,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,mc)
end
function s.filter2chk(c,e,tp,mc)
	return s.filter1(mc,e,tp) and s.filter2(c,e,tp,mc)
end
function s.filter3(c,e,tp,mc,xc)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetValue(xc:GetRank())
	e1:SetReset(RESET_CHAIN)
	xc:RegisterEffect(e1)
	local mg=Group.FromCards(mc,xc)
	local chk=c:IsXyzSummonable(nil,mg,2,2)
	e1:Reset()
	return chk and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
function s.target(e,tp,eg,ev,ep,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local xc=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	Duel.SelectTarget(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,xc,e,tp,xc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.operation(e,tp,eg,ev,ep,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g~=2 then return end
	local xc=g:GetFirst()
	local mc=g:GetNext()
	if not s.filter2chk(mc,e,tp,xc) then
		xc,mc=mc,xc
	end
	if not s.filter2chk(mc,e,tp,xc) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter3,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mc,xc):GetFirst()
	if tc then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_XYZ_LEVEL)
		e1:SetValue(xc:GetRank())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		xc:RegisterEffect(e1)
		Duel.XyzSummon(tp,tc,Group.FromCards(mc,xc),nil,2,2)
	end
end