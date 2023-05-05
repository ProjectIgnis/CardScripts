--ギミック・パペット－ベビーフェイス
--Gimmick Puppet Princess
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon monster that destroyed this card by battle
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local t=Duel.GetAttackTarget()
	--Special Summon effect
	if c==a then
		local e2=Effect.CreateEffect(c)
		e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e2:SetType(EFFECT_TYPE_IGNITION)
		e2:SetRange(LOCATION_GRAVE)
		e2:SetLabelObject(t)
		e2:SetCondition(s.spcon)
		e2:SetCost(aux.bfgcost)
		e2:SetOperation(s.spop)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD-RESET_TOGRAVE)
		c:RegisterEffect(e2)
	end
	if c==t then
		local e2=Effect.CreateEffect(c)
		e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e2:SetType(EFFECT_TYPE_IGNITION)
		e2:SetRange(LOCATION_GRAVE)
		e2:SetLabelObject(a)
		e2:SetCondition(s.spcon)
		e2:SetCost(aux.bfgcost)
		e2:SetOperation(s.spop)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD-RESET_TOGRAVE)
		c:RegisterEffect(e2)
	end
end
function s.filter(c,tc,e,tp)
	return c==tc and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcon(e,c)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	local tc=e:GetLabelObject()
	if c==nil then return true end
	return Duel.GetLocationCount(1-c:GetControler(),LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.filter,c:GetControler(),0,LOCATION_GRAVE,1,nil,tc,e,tp) 
end
function s.opera(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	if tc and tc:IsLocation(LOCATION_GRAVE) then
		Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
	end
end
