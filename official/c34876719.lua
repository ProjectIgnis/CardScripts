--Ｎ・Ａｓ・Ｈ Ｋｎｉｇｈｔ
--N.As.H. Knight
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	--Cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Attach 1 "Number" monster and 1 other monster to itself
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.attcon)
	e2:SetCost(Cost.Detach(2,2,nil))
	e2:SetTarget(s.atttg)
	e2:SetOperation(s.attop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NUMBER}
function s.indcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_NUMBER),0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.attcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.attfilter1(c,e)
	local no=c.xyz_number
	return no and no>=101 and no<=107 and c:IsSetCard(SET_NUMBER) and c:IsType(TYPE_XYZ) and not c:IsImmuneToEffect(e)
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.attfilter1,tp,LOCATION_EXTRA,0,1,nil,e)
		and e:GetHandler():IsType(TYPE_XYZ) end
end
function s.attfilter2(c,e)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN) and not c:IsImmuneToEffect(e)
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local exg=Duel.SelectMatchingCard(tp,s.attfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e)
	if #exg==0 then return end
	Duel.Overlay(c,exg)
	--Attach 1 other face-up monster
	local g=Duel.GetMatchingGroup(s.attfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,c,e)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if not tc then return end
		Duel.HintSelection(tc,true)
		Duel.BreakEffect()
		Duel.Overlay(c,tc,true)
	end
end