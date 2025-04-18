--ブロックマン
--Blockman
local s,id=GetID()
function s.initial_effect(c)
	--Register when it was placed on the field
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_NO_TURN_RESET)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EVENT_ADJUST)
	e0:SetCountLimit(1)
	e0:SetOperation(s.op)
	c:RegisterEffect(e0)
	--Check for how long it has been on the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_TURN_END)
	e1:SetCondition(s.regcon)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	--Special summon tokens
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={48115278}
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsTurnPlayer(tp) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1,0)
	end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsTurnPlayer(tp)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetFlagEffectLabel(id)
	if not ct then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1,0)
	else
		c:SetFlagEffectLabel(id,ct+1)
	end
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	local ct=e:GetHandler():GetFlagEffectLabel(id)
	if not ct then ct=0 end
	e:SetLabel(ct)
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if e:GetHandler():GetSequence()<5 then ft=ft+1 end
	if chk==0 then
		local ct=e:GetHandler():GetFlagEffectLabel(id)
		if not ct then ct=0 end
		return (ct==0 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) and ft>ct-1
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,1000,1500,4,RACE_ROCK,ATTRIBUTE_EARTH)
	end
	local ct=e:GetLabel()
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct+1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct+1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if ct>0 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>ct
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,1000,1500,4,RACE_ROCK,ATTRIBUTE_EARTH) then
		for i=1,ct+1 do
			local token=Duel.CreateToken(tp,id+1)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e1,true)
		end
		Duel.SpecialSummonComplete()
	end
end