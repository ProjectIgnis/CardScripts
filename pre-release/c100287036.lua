-- Ｂａｔｔｌｅ Ｒｏｙａｌ Ｍｏｄｅ－Ｊｏｉｎｉｎｇ
-- Battle Royal Mode - Joining
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Activate by targeting 1 monster
	aux.AddPersistentProcedure(c,PLAYER_ALL,aux.FilterFaceupFunction(Card.IsType,TYPE_EFFECT))
	-- Cannot be destroyed by battle the first two times
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCountLimit(2)
	e1:SetTarget(aux.PersistentTargetFilter)
	e1:SetValue(function(_,_,r) return r&REASON_BATTLE==REASON_BATTLE end)
	c:RegisterEffect(e1)
	-- Destroying player gains 2000 LP
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(s.lpop)
	c:RegisterEffect(e2)
	-- Special Summon 1 Level 4 or lower monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(function(_,_,_,ep) return Duel.IsTurnPlayer(1-ep) end)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and eg:IsContains(tc) and tc:IsReason(REASON_BATTLE) then
		Duel.Recover(tc:GetReasonPlayer(),2000,REASON_EFFECT)
	end
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e)
		or not Duel.IsExistingMatchingCard(s.spfilter,ep,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,ep)
		or not Duel.SelectYesNo(ep,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SELECTMSG,ep,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(ep,s.spfilter,ep,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,ep)
	if #sg>0 and Duel.SpecialSummon(sg,0,ep,ep,false,false,POS_FACEUP)>0 then
		Duel.SetLP(ep,Duel.GetLP(ep)-2000)
	end
end