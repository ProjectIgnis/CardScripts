--Scripted by Eerie Code
--Raidraptor - Satellite Cannon Falcon
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_WINGEDBEAST),8,2)
	c:EnableReviveLimit()
	--Reduce ATK
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
end
function s.cost(e,tp,ep,eg,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.filter(c,e)
	return aux.nzatk(c) and (not e or not c:IsImmuneToEffect(e))
end
function s.atkfilter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_MONSTER)
end
function s.target(e,tp,ep,eg,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) 
		and Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.operation(e,tp,ep,eg,ev,re,r,rp)
	local mg=Duel.GetMatchingGroupCount(s.filter,tp,0,LOCATION_MZONE,nil,e)
	local rc=Duel.GetMatchingGroupCount(s.atkfilter,tp,LOCATION_GRAVE,0,nil)
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_GRAVE,0,nil)
	local ct=g:GetFirst()
	if mg==0 or rc==0 then return end
	repeat
		local code=ct:GetCode()
		Duel.Hint(HINT_CARD,0,code)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local tg=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,e)
		local tc=tg:GetFirst()
		if tc then
			Duel.HintSelection(tg)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-800)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		else return
		end
		rc=rc-1
		ct=g:GetNext()
	until rc<=0 or not Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil,e) 
		or not Duel.SelectYesNo(tp,210)
end
