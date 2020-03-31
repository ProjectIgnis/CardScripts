--ヴィシャス・クロー
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--atkup
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	--destroy sub
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(s.desreptg)
	e4:SetOperation(s.desrepop)
	c:RegisterEffect(e4)
	--tohand
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_TO_HAND)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
s.listed_names={id}
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=e:GetHandler():GetEquipTarget()
	if chk==0 then return tg and tg:IsReason(REASON_BATTLE) end
	return true
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local exc=e:GetHandler():GetEquipTarget():GetBattleTarget()
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,exc)
	if Duel.Destroy(g,REASON_EFFECT)>0 and Duel.Damage(1-tp,600,REASON_EFFECT)~=0 then
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,2500,2500,7,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP,1-tp) then
			local token=Duel.CreateToken(tp,id+1)
			Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsPreviousLocation(LOCATION_DECK) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_USE_AS_COST)
		e1:SetTargetRange(LOCATION_HAND,0)
		e1:SetTarget(s.limittg)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		Duel.RegisterEffect(e2,tp)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_SSET)
		Duel.RegisterEffect(e3,tp)
	end
end
function s.limittg(e,c)
	return c:IsCode(id)
end
